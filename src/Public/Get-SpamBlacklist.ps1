# src\Public\Get-SpamBlacklist.ps1
function Get-SpamBlacklist {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [alias('IpAddr')]
        [string]$Name,

        [parameter()]
        [switch]$ShowAll
    )

    $Blacklists = @(
        'cbl.abuseat.org',
        'ex.dnsbl.org',
        'in.dnsbl.org',
        'ips.backscatterer.org',
        'b.barracudacentral.org',
        'rbl.interserver.net',
        'bl.mailspike.net',
        'images.rbl.msrbl.net',
        'phishing.rbl.msrbl.net',
        'combined.rbl.msrbl.net',
        'virus.rbl.msrbl.net',
        'spam.rbl.msrbl.net',
        'abuse.rfc-clueless.org',
        'bogusmx.rfc-clueless.org',
        'dsn.rfc-clueless.org',
        'elitist.rfc-clueless.org',
        'fulldom.rfc-clueless.org',
        'postmaster.rfc-clueless.org',
        'whois.rfc-clueless.org',
        'dul.dnsbl.sorbs.net',
        'web.dnsbl.sorbs.net',
        'dnsbl.sorbs.net',
        'spam.dnsbl.sorbs.net',
        'http.dnsbl.sorbs.net',
        'socks.dnsbl.sorbs.net',
        'smtp.dnsbl.sorbs.net',
        'zombie.dnsbl.sorbs.net',
        'misc.dnsbl.sorbs.net',
        'bl.spamcannibal.org',
        'bl.spamcop.net',
        'fresh.spameatingmonkey.net',
        'fresh10.spameatingmonkey.net',
        'fresh15.spameatingmonkey.net',
        'uribl.spameatingmonkey.net',
        'urired.spameatingmonkey.net',
        'xbl.spamhaus.org',
        'zen.spamhaus.org',
        'pbl.spamhaus.org',
        'sbl.spamhaus.org',
        'noptr.spamrats.com',
        'dyna.spamrats.com',
        'spam.spamrats.com',
        'psbl.surriel.com'
    )

    if ($Name -match "(?:\d{1,3}\.){3}\d{1,3}") {
        $CheckIp = $Name
    } else {
        try {
            $Lookup = ResolveDns $Name A -ErrorAction Stop
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
        if ($Lookup -match "(?:\d{1,3}\.){3}\d{1,3}") {
            $CheckIp = $Lookup
        } else {
            $Exception = New-Object System.ArgumentException ('Cannot determine a valid IP from input {0}' -f $Name)
            $ErrCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
            $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'CannotDetermineIP',$ErrCategory,$Name
            $PSCmdlet.ThrowTerminatingError($ErrRecord)
        }
    }

    $IpR = $CheckIp -replace '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','$4.$3.$2.$1'

    foreach  ($Blacklist in $Blacklists) {
        $Rbl = Resolve-DnsName ($IpR + '.' + $Blacklist) -DnsOnly -ErrorAction SilentlyContinue
        if ($RBl) {
            [pscustomobject]@{
                Blacklist = $Blacklist
                OnList    = $true
                Message   = (-join (Resolve-DnsName ($IpR + '.' + $Blacklist) -Type txt -ErrorAction SilentlyContinue).Strings)
            }
        } elseif (-Not($Rbl) -and $ShowAll) {
            [pscustomobject]@{
                Blacklist = $Blacklist
                OnList    = $false
                Message   = $null
            }
        }
    }
}