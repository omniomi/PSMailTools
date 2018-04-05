function ReturnSPFRecursive {
    [CmdletBinding()]
    param (
        # Domain name to retrieve SPF record for
        [Parameter()]
        [String]
        $Name,

        # Record String
        [Parameter()]
        [String]
        $Record,

        # Track Recursion
        [Parameter()]
        [Int]
        $Level = 0
    )

    try {
        $Level = $Level++

        if ($Name -and -not($Record)) {
            $Record = ReturnSPF $Name
        }

        $Mechanisms = $Record.Split(' ') | Where { $_ -notlike "ip*" }

        $Output = [PSCustomObject]@{
            Name  = $Name
            Value = $Record
            Level = $Level
        }
        $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF_Record')
        $Output

        foreach ($Mechanism in $Mechanisms) {
            switch -Regex ($Mechanism) {
                "^a$" {
                    $Output = [PSCustomObject]@{
                        Name  = 'a'
                        Value = ((Resolve-DnsName $Name -Type A).IPAddress)
                        Level = ($Level + 1)
                    }
                    $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF_Record')
                    $Output
                }
                "^mx$" {
                    $MX = ((Resolve-DnsName $Name -Type MX).NameExchange)
                    $Output = [PSCustomObject]@{
                        Name = 'mx'
                        Value = $MX
                        Level = ($Level + 1)
                    }
                    $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF_Record')
                    $Output

                    [regex]$IPRegex = "(?:\d{1,3}\.){3}\d{1,3}"
                    foreach ($MXS in $MX) {
                        if ($MXS -notmatch $IPRegex) {
                            $Output = [PSCustomObject]@{
                                Name = $MXS
                                Value = (ResolveMX $MXS)
                                Level = ($Level + 2)
                            }
                            $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF_Record')
                            $Output
                        }
                    }
                }
                "(?:include|redirect):.*"  {
                    ReturnSPFRecursive -Name $_.Split(':')[-1] -Record (ReturnSPF $_.Split(':')[-1]) -Level ($Level + 1)
                }
            }
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}