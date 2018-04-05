function Get-SPFRecord {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [Alias('Name')]
        [String[]]
        $Domain
    )

    process {
        foreach ($DomainName in $Domain) {
            try {
                $SPFRecord = ReturnSPF $DomainName
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }

            # Handle multiple records. (Not valid as per RFC 7208 s3.2)
            $FinalOutput = foreach ($Record in $SPFRecord) {
                $AllQualifier = $Record | ResolveQualifier

                $Output = [PSCustomObject]@{
                    Name   = $DomainName
                    Value    = $Record
                    Length   = $Record.Length
                    FailMode = $AllQualifier
                }
                $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF_Record')
                $Output
            }

            return $FinalOutput
        }
    }
}