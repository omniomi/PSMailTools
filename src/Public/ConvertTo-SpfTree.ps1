
# src\Public\ConvertTo-SpfTree.ps1
function ConvertTo-SpfTree {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateScript({
            if ($_ -is [MailTools.Security.SPF.Recursive]) {
                $true
            } else {
                $Exception = New-Object System.ArgumentException ('This command only accepts output from Resolve-SpfRecord.')
                $ErrCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'WrongSpfObject',$ErrCategory,$null
                throw $ErrRecord
            }
        })]
        [MailTools.Security.SPF.SPFRecord[]]
        $InputObj
    )

    begin {
        $Script:Objects = New-Object 'System.Collections.Generic.List[System.Object]'

        function Indent ([int]$i) {
            $Out = foreach ($n in 0..$i) {
                ' |'
            }

            -join $Out
        }

        function PrintRow ([System.Object]$InputObj) {
            $Name  = $InputObj.Name
            $Value = $InputObj.Value
            $Level = $InputObj.Level

            (Indent $Level) + ' ' + $Name

            $Mechanisms = $Value.Split(' ')

            foreach ($Mech in $Mechanisms) {
                switch -Regex ($Mech) {
                    "^ip(?:4|6):.*" {
                        (Indent ($Level + 1)) + ' ' + $Mech
                    }

                    "^(?:include|redirect).*" {
                        $Nested = $Objects | Where-Object { $_.Name -eq $Mech -and $_.Level -eq ($Level + 1) }
                        PrintRow $Nested
                    }

                    "^(?:a|mx)" {
                        $Nested = $Objects | Where-Object { $_.Name -eq $Mech -and $_.Level -eq ($Level + 1) }
                        PrintRow $Nested
                    }

                    "^.all$" {
                        (Indent ($Level + 1)) + ' ' + $Mech
                    }
                    "^v=spf1$" { continue }
                    default { (Indent ($Level + 1)) + ' ' + $Mech }
                }
            }

        }
    }

    process {
        $Objects.Add($InputObj)
    }

    end {
        try {
            if ($Objects.count -ge 1) {
                '----------------------------------------'
                'Domain:     ' + $Objects[0].Name
                'SPF Record: ' + $Objects[0].Value
                '----------------------------------------'
                PrintRow $Objects[0]
                '----------------------------------------'
                $Lookups = @('include','a','mx','ptr','exists')
                'DNS Lookup Count: ' + (((-join $Objects.Value).Split(' ').Split(':') | Where { $_ -in $Lookups }).count) + ' out of 10'
                '----------------------------------------'
            }
        }
        catch {
            $PSCmdlet.WriteError($PSItem)
        }
    }
}