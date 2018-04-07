function Get-SPFRecord {
    [CmdletBinding()]
    [OutputType('MailTools.Security.SPF.SPFRecord')]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('Domain')]
        [String[]]
        $Name
    )

    process {
        foreach ($DomainName in $Name) {
            try {
                $SPFRecord = ReturnSPF $DomainName
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }

            # Handle multiple records. (Not valid as per RFC 7208 s3.2)
            $FinalOutput = foreach ($Record in $SPFRecord) {
                [MailTools.Security.SPF.SPFRecord]@{
                    Name  = $DomainName
                    Value = $Record
                }
            }

            if ($FinalOutput.Count -gt 1) {
                $PSCmdlet.WriteWarning("The domain {0} has more than one SPF record. This is a violation of RFC 7208 s3.2 and may cause SPF to fail." -f $DomainName)
            }

            return $FinalOutput
        }
    }
}