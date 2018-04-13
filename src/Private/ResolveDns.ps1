function ResolveDns {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$Name,

        [parameter(Mandatory)]
        [ValidateSet('txt','mx','a','ptr')]
        [string]$Type
    )

    try {
        if ($Name -match "[^=:]+(?:=|:).*") {
            $Name = $Name.Split(':=')[1]
        }

        $DnsRecords = Resolve-DnsName $Name -Type $Type -Verbose:$false

        foreach ($DnsRecord in $DnsRecords) {
            switch ($Type) {
                'mx'  {
                    if ($DnsRecord.NameExchange) {
                        $DnsRecord.NameExchange
                    }
                }
                'a'   {
                    $DnsRecord.IPAddress
                }
                'txt' {
                    -join $DnsRecord.Strings
                }
                'ptr' {
                    if ($DnsRecord.NameHost) {
                        $DnsRecord.NameHost
                    }
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}