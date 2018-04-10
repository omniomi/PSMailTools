# src\Public\Resolve-SPFRecord.ps1
function Resolve-SPFRecord {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType('MailTools.Security.SPF.Recursive')]
    param (
        # Domain name to retrieve SPF record for
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Default')]
        [Alias('Domain')]
        [String[]]
        $Name,

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ParameterSetName='InputObj')]
        [MailTools.Security.SPF.SPFRecord[]]
        $InputObj
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'InputObj') {
            foreach ($Obj in $InputObj) {
                try {
                    ReturnSPFRecursive -Name $Obj.Name -Record $Obj.Value
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($PSItem)
                }
            }
        } else {
            foreach ($DomainName in $Name) {
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
}