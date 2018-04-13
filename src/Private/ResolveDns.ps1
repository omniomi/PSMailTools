function ResolveDns {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$Name,

        [parameter(Mandatory)]
        [ValidateSet('txt','mx','a')]
        [string]$Type
    )

    try {
        $DnsRecords = Resolve-DnsName $Name -Type $Type

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
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}