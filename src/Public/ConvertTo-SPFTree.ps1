function ConvertTo-SPFTree {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(ValueFromPipeline)]
        [MailTools.Security.SPF.SPFRecord[]]
        $InputObj
    )

    begin {
        $Script:Objects = @()

        function CalculateIndent ($Obj) {
            $Script:IndentTable = @{}
            foreach ($Row in $Obj) {
                if ($Row.Parent -eq 1) {
                    $IndentTable.Add($Row.Id,1)
                } else {
                    $n = ($IndentTable[$Row.Parent] + 1)
                    $IndentTable.Add($Row.Id,$n)
                }
            }
        }

        function IndentRow ($Id) {
            $Indent = $IndentTable[$Id]

            $Output = for ($i = 0 ; $i -lt $Indent ; $i++) {
                '| '
            }

            -join $Output
        }

        function DisplayObject ($Obj) {
            $Rows = $Obj.Value.Split(' ').ToLower()

            foreach ($Row in $Rows) {
                switch -Regex ($Row) {
                    "^a.*" {
                        (IndentRow $Obj.Id) + $Row
                        $AObjects = ($Objects | Where { $_.Name -match [regex]"^a.*" -and $_.Parent -eq $Obj.Id })

                        foreach ($AObj in $AObjects) {
                            DisplayObject $AObj
                        }
                    }
                    "^mx$" {
                        (IndentRow $Obj.Id) + $Row
                        $MXObj = ($Objects | Where { $_.Name -eq 'mx' -and $_.Parent -eq $Obj.Id })
                        $MXRow = DisplayObject $MXObj
                        $MXRow

                        if ($MXRow -notmatch [regex]"(?:\d{1,3}\.){3}\d{1,3}") {
                            $Nested = ($Objects | Where { $_.Parent -eq $MXObj.Id })
                            DisplayObject $Nested
                        }

                    }
                    "^mx:.*" {
                        (IndentRow $Obj.Id) + $Row
                        $MXObjs = ($Objects | Where { $_.Name -like "mx:*" -and $_.Parent -eq $Obj.Id })

                        foreach ($MXObj in $MXObjs ) {
                            $MXRow = DisplayObject $MXObj
                            $MXRow

                            if ($MXRow -notmatch [regex]"(?:\d{1,3}\.){3}\d{1,3}") {
                                $Nested = ($Objects | Where { $_.Parent -eq $MXObj.Id })
                                DisplayObject $Nested
                            }
                        }
                    }
                    "ip(?:4|6):.*" { (IndentRow $Obj.Id) + $Row }
                    "include:.*" { (IndentRow $Obj.Id) + $Row ; DisplayObject ($Objects | Where { $_.Name -eq $Row.Split(':')[-1] }) }
                    "redirect=.*" { (IndentRow $Obj.Id) + $Row ; DisplayObject ($Objects | Where { $_.Name -eq $Row.Split('=')[-1] }) }
                    "^v\=.*" { continue }
                    default { (IndentRow $Obj.Id) + $Row }
                }
            }
        }
    }

    process {
        $Objects += $InputObj
    }

    end {
        try {
            $RootObject = $Objects | Where { $_.Id -eq 1 }
            '----------------------------------------'
            'Domain:     ' + $RootObject.Name
            'SPF Record: ' + $RootObject.Value
            '----------------------------------------'
            CalculateIndent ($Objects | Where { $_.Id -ne 1 })
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