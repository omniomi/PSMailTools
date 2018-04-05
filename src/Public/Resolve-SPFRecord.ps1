function Resolve-SPFRecord {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [String[]]
        $Domain
    )

    process {
        foreach ($DomainName in $Domain) {
            try {
                $Record = ReturnSPF $DomainName
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }

            try {
                ReturnSPFRecursive -Name $DomainName -Record $Record
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
}