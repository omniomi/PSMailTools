function Get-SPFRecord {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [Alias('Domain')]
        [String[]]
        $Name,

        # DNS server to query
        [Parameter()]
        [String]
        $Server,

        # Resolve record mechanisms recursivly
        [Parameter()]
        [Switch]
        $Recurse
    )

    begin {
        if ($Server) {
            $ServerParamater = @{
                Server = $Server
            }
        }
    }

    process {
        foreach ($DomainName in $Name) {
            if (-not($Recurse)) {
                try {
                    $SPFRecord = ReturnSPF $DomainName @ServerParamater
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($PSItem)
                }

                # Handle multiple records. (Not valid as per RFC 7208 s3.2)
                $FinalOutput = foreach ($Record in $SPFRecord) {
                    $AllQualifier = $Record | ResolveQualifier

                    $Output = [PSCustomObject]@{
                        Domain   = $DomainName
                        Value    = $Record
                        Length   = $Record.Length
                        FailMode = $AllQualifier
                    }
                    $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF_Record')
                    $Output
                }

                return $FinalOutput
            } else {
                $AllRecords = ReturnSPFRecursive $DomainName @ServerParamater

                foreach ($Record in $AllRecords) {
                    $AllQualifier = $Record.Value | ResolveQualifier

                    $Output = [PSCustomObject]@{
                        Domain   = $Record.Domain
                        Value    = $Record.Value
                        Length   = $Record.Value.Length
                        FailMode = $AllQualifier
                    }
                    $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF_Record')
                    return $Output
                }
            }
        }
    }
}