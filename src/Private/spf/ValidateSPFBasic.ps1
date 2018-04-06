function ValidateSPFBasic {
    [cmdletbinding()]
    param(
        [String]
        $DomainName = 'Unspecified',

        [String]
        $SPFRecord
    )

    $Output = New-Object -TypeName MailTools.Security.SPF.Validation_Basic
    $Output.Name = $DomainName

    try {
        if (-not($SPFRecord)) {
            $SPFRecord = ReturnSPF $DomainName
        }
        $Output.RecordFound = $true
        $Output.Value = $SPFRecord
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    if ($SPFRecord -match $SPFRegex) {
        $Output.FormatIsValid = $true
    } else {
        $Output.FormatIsValid = $false
    }

    return $Output
}