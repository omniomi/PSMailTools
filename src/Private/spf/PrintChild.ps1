function PrintChild {
    param(
        [String]$Name,
        [String]$Value,
        [int]$Level
    )

    try {
        if ($Value -match '^(?:a|mx)$') {
            $SearchName   = $Name
            $Type         = $Value
            $SearchMethod = 'dns'
        } elseif ($Value -match '^(?:a|mx):.*$') {
            $SearchName   = $Value.Split(':')[1]
            $Type         = $Value.Split(':')[0]
            $SearchMethod = 'dns'
        } elseif ($Value -match '^(?:include:|redirect=).*$') {
            $SearchName   = $Value.Split(':=')[1]
            $SearchMethod = 'spf'
        } else {
            continue
        }

        if ($SearchMethod -eq 'dns') {
            $DnsResults = ResolveDns $SearchName -Type $Type
            $NextLevel = $DnsResults -join ' '
        } elseif ($SearchMethod -eq 'spf') {
            $NextLevel = ReturnSpf $SearchName
        }

        if ($NextLevel) {
            PrintItem $Value $NextLevel ($Level + 1)
        }

        if ($Type -eq 'mx') {
            foreach ($MXRec in $DnsResults) {
                if ($MXRec -notmatch "(?:\d{1,3}\.){3}\d{1,3}") {
                    $Resolved = ResolveDns $MXRec -Type A
                    PrintItem $MXRec $Resolved ($Level + 2)
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}