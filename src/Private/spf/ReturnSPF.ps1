function ReturnSPF {
    [CmdletBinding()]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [String]
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
            $Exception = New-Object System.Data.ObjectNotFoundException ("The domain {0} has no SPF records." -f $Name)
            $ErrCategory = [System.Management.Automation.ErrorCategory]::ObjectNotFound
            $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'NoSpfRecord',$ErrCategory,$Name
            $PSCmdlet.ThrowTerminatingError($ErrRecord)
        }

        $Output = foreach ($String in $SPFRecords) {
            $String.String
        }

        return $Output

    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}