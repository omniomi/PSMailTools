function ReturnSPF {
    [CmdletBinding()]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string]
        $Name
    )

    try {
        $ResolveParameters = @{
            Name        = $Name
            Type        = 'TXT'
            DnsOnly     = $true
            ErrorAction = 'Stop'
        }

        # Query for all TXT records
        $TXTRecords = Resolve-DnsName @ResolveParameters

        # Select SPF record(s) from all TXT records.
        $SPFRecords = $TXTRecords | Where { $_.Strings -like "v=spf1*" } | Select @{n='String';e={-join $_.Strings}}

        if ($SPFRecords.Count -eq 0) {
            $Exception = New-Object System.Management.Automation.ItemNotFoundException ("The domain {0} has no SPF record." -f $Name)
            $ErrCategory = [System.Management.Automation.ErrorCategory]::ResourceUnavailable
            $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'NoSpfRecord',$ErrCategory,$Name
            $PSCmdlet.ThrowTerminatingError($ErrRecord)
        }

        foreach ($String in $SPFRecords) {
            $String.String
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}