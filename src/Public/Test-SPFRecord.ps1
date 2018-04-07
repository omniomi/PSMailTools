function Test-SPFRecord {
    [CmdletBinding(DefaultParameterSetName='Name')]
    [OutputType('MailTools.Security.SPF.Validation')]
    param (
        # Test by domain name
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Name')]
        [Alias('Domain')]
        [String]
        $Name,

        # Test by record value
        [Parameter(Mandatory,
                   ParameterSetName='Value')]
        [Alias('Record')]
        [String]
        $Value,

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ParameterSetName='Object')]
        [MailTools.Security.SPF.SPFRecord]
        $InputObj,

        # Basic Validation
        [Parameter(ParameterSetName='Value')]
        [Parameter(ParameterSetName='Name')]
        [Parameter(ParameterSetName='Object')]
        [Switch]
        $Basic
    )

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'Value' {
                    foreach ($Record in $Value) {
                        ValidateSPF -SPFRecord $Record
                    }
                }
                'Name' {
                    foreach ($DomainName in $Name) {
                        ValidateSPF $DomainName
                    }
                }
                'Object' {
                        ValidateSPF $InputObj.Name $InputObj.Value
                }
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}