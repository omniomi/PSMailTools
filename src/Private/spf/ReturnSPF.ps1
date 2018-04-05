function ReturnSPF {
    [CmdletBinding()]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [Alias('Domain')]
        [String]
        $Name,

        # DNS server to query
        [Parameter()]
        [String]
        $Server
    )

    try {
        $ResolveParameters = @{
            Name        = $Name
            Type        = 'TXT'
            DnsOnly     = $true
            ErrorAction = 'Stop'
        }
        if ($Server) {
            ResolveParameters.Server = $Server
        }

        # Query for all TXT records
        $TXTRecords = Resolve-DnsName @ResolveParameters

        # Select SPF record(s) from all TXT records.
        $SPFRecords = $TXTRecords | Where { $_.Strings -like "v=spf1*" } | Select @{n='String';e={-join $_.Strings}}

        $Output = foreach ($String in $SPFRecords) {
            $String.String
        }

        return $Output

    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}