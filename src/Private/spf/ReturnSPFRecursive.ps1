function ReturnSPFRecursive {
    [CmdletBinding()]
    [OutputType('MailTools.Security.SPF.Recursive')]
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
        $Parent
    )

    try {
        if ($Name -and -not($Record)) {
            $Record = ReturnSPF $Name
        }

        $Mechanisms = $Record.Split(' ') | Where { $_ -notlike "ip*" }

        # ID Initialize
        if (-not($RecursiveID)) {
            $Script:RecursiveID = 1
        }
        if ($Parent) {
            $Parent = $Parent
        } else {
            $Parent = 0
        }

        [MailTools.Security.SPF.Recursive]@{
            Name  = $Name
            Value = $Record
            ID = $RecursiveID
            Parent = $Parent
        }
        $Parent = $RecursiveID
        $RecursiveID++

        foreach ($Mechanism in $Mechanisms) {
            switch -Regex ($Mechanism) {
                "^a.*" {
                    if ($_ -match [regex]"^a$") {
                        $ARec = ((Resolve-DnsName $Name -Type A).IPAddress)
                        $AName = 'a'
                    } elseif ($_ -match [regex]"^a:.*") {
                        $ADomain = $_.Split(':')[-1]
                        $ARec = ((Resolve-DnsName $ADomain -Type A).IPAddress)
                        $AName = 'a:' + $ADomain
                    }

                    foreach ($ARecord in $ARec) {
                        [MailTools.Security.SPF.Recursive]@{
                            Name = $AName
                            Value = $ARecord
                            ID = $RecursiveID
                            Parent = $Parent
                        }
                        $RecursiveID++
                    }
                }
                "^mx.*" {
                    if ($_ -match [regex]"^mx$") {
                        $MX = ((Resolve-DnsName $Name -Type MX).NameExchange)
                        $MXName = 'mx'
                    } elseif ($_ -match [regex]"^mx:.*") {
                        $MXDomain = $_.Split(':')[-1]
                        $MX = ((Resolve-DnsName $MXDomain -Type MX).NameExchange)
                        $MXName = 'mx:' + $MXDomain
                    }

                    foreach ($MXRecord in $MX) {
                        [MailTools.Security.SPF.Recursive]@{
                            Name = $MXName
                            Value = $MXRecord
                            ID = $RecursiveID
                            Parent = $Parent
                        }
                        $MXParent = $RecursiveID
                        $RecursiveID++

                        if ($MXRecord -notmatch [regex]"(?:\d{1,3}\.){3}\d{1,3}") {
                            [MailTools.Security.SPF.Recursive]@{
                                Name = $MXRecord
                                Value = (ResolveMX $MXRecord)
                                ID = $RecursiveID
                                Parent = $MXParent
                            }
                            $RecursiveID++
                        }
                    }
                }
                "include:.*"  {
                    $Recursion = ReturnSPFRecursive -Name $_.Split(':')[-1] -Record (ReturnSPF $_.Split(':')[-1]) -Parent $Parent
                    $RecursiveID = ($Recursion[-1].Id) + 1
                    $Recursion
                }
                "redirect=.*"  {
                    $Recursion = ReturnSPFRecursive -Name $_.Split('=')[-1] -Parent $Parent
                    $RecursiveID = ($Recursion[-1].Id) + 1
                    $Recursion
                }
            }
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}