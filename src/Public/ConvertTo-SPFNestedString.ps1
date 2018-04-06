function ConvertTo-SPFNestedString {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(ValueFromPipeline)]
        [MailTools.Security.SPF.SPFRecord[]]
        $InputObj
    )

    begin {
        function IndentRow ([int]$i) {
            $Output = for ($n = 0 ; $i -gt $n ; $i--) {
                ' |'
            }
            '|' + (-join $Output) + ' '
        }

        function DisplayObject ([System.Object]$Obj) {
            $Rows = $Obj.Value.Split(' ')

            foreach ($Row in $Rows) {
                switch -Regex ($Row) {
                    "^a$" { (IndentRow $Obj.Level) + $Row ; DisplayObject ($Objects | Where { $_.Name -eq 'a' -and $_.Level -eq ($Obj.Level + 1) }) }
                    "^mx$" {
                        (IndentRow $Obj.Level) + $Row
                        $MXRow = DisplayObject ($Objects | Where { $_.Name -eq 'mx' -and $_.Level -eq ($Obj.Level + 1) })
                        [regex]$IPRegex = "(?:\d{1,3}\.){3}\d{1,3}"
                        if ($MXRow -notmatch $IPRegex) {
                            $MXRow
                            (IndentRow ($Obj.Level + 2)) + (($Objects | Where { $_.Name -eq ($MXRow.Split(' ')[-1]) }).Value)
                        } else {
                            $MXRow
                        }
                    }
                    "ip(?:4|6):.*" { (IndentRow $Obj.Level) + $Row }
                    "include:.*" { (IndentRow $Obj.Level) + $Row ; DisplayObject ($Objects | Where { $_.Name -eq $Row.Split(':')[-1] }) }
                    "^v\=.*" { continue }
                    default { (IndentRow $Obj.Level) + $Row }
                }
            }
        }

        $Script:Objects = @()
    }

    process {
        $Objects += $InputObj
    }

    end {
        try {
            $RootObject = $Objects | Where { $_.Level -eq 0 }
            '----------------------------------------'
            'Domain:     ' + $RootObject.Name
            'SPF Record: ' + $RootObject.Value
            '----------------------------------------'
            DisplayObject $RootObject
            '----------------------------------------'
            $Lookups = @('include','a','mx','ptr','exists')
            'DNS Lookup Count: ' + (((-join $Objects.Value).Split(' ').Split(':') | Where { $_ -in $Lookups }).count) + ' out of 10'
            '----------------------------------------'
        }
        catch {
            $PSCmdlet.WriteError($PSItem)
        }
    }
}