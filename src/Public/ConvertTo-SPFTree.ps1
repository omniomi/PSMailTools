function ConvertTo-SPFTree {
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
                        # Show 'mx' once
                        (IndentRow $Obj.Level) + $Row

                        # Handle multiple MX records. Should be one level below current SPF record and name equal to 'mx'.
                        $MXRows = $Objects | Where { $_.Name -eq 'mx' -and $_.Level -eq ($Obj.Level + 1) }

                        foreach ($MXRow in $MXRows) {
                            $MXRowDisplay = DisplayObject $MXRow
                            [regex]$IPRegex = "(?:\d{1,3}\.){3}\d{1,3}"
                            if ($MXRowDisplay -notmatch $IPRegex) {
                                $MXRowDisplay
                                (IndentRow ($Obj.Level + 2)) + (($Objects | Where { $_.Name -eq ($MXRowDisplay.Split(' ')[-1]) }).Value)
                            } else {
                                $MXRowDisplay
                            }
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