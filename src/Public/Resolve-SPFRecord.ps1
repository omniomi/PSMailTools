# src\Public\Resolve-SpfRecord.ps1
function Resolve-SpfRecord {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType('MailTools.Security.SPF.Recursive')]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Default')]
        [Alias('Domain')]
        [String]
        $Name,

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ParameterSetName='InputObj')]
        [MailTools.Security.SPF.SPFRecord[]]
        $InputObj
    )

    process {
        try {
            if ($InputObj) {
                $IsName = $InputObj.name
                $Record = $InputObj.Value
            } else {
                $IsName = $Name
                $Record = ReturnSPF $Name
            }

            PrintItem $IsName $Record

        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}