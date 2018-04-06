function ReturnSPFRecursive {
    [CmdletBinding()]
    [OutputType([MailTools.Security.SPF.Recursive])]
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

        [MailTools.Security.SPF.Recursive]@{
            Name  = $Name
            Value = $Record
            Level = $Level
        }

        foreach ($Mechanism in $Mechanisms) {
            switch -Regex ($Mechanism) {
                "^a$" {
                    $Output = [MailTools.Security.SPF.Recursive]@{
                        Name  = 'a'
                        Value = ((Resolve-DnsName $Name -Type A).IPAddress)
                        Level = ($Level + 1)
                    }
                }
                "^mx$" {
                    $MX = ((Resolve-DnsName $Name -Type MX).NameExchange)
                    $Output = [MailTools.Security.SPF.Recursive]@{
                        Name = 'mx'
                        Value = $MX
                        Level = ($Level + 1)
                    }

                    [regex]$IPRegex = "(?:\d{1,3}\.){3}\d{1,3}"
                    foreach ($MXS in $MX) {
                        if ($MXS -notmatch $IPRegex) {
                            [MailTools.Security.SPF.Recursive]@{
                                Name = $MXS
                                Value = (ResolveMX $MXS)
                                Level = ($Level + 2)
                            }
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