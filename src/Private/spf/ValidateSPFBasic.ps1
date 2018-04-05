function ValidateSPFBasic {
    [cmdletbinding()]
    param(
        [String]
        $DomainName = 'Unspecified',

        [String]
        $SPFRecord
    )

    $Output = [PSCustomObject]@{
        Name = $DomainName
    }

    try {
        if (-not($SPFRecord)) {
            $SPFRecord = ReturnSPF $DomainName
        }
        $Output | Add-Member RecordFound $true
        $Output | Add-Member Value $SPFRecord
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    if ($SPFRecord -match $SPFRegex) {
        $Output | Add-Member FormatIsValid $true
    } else {
        $Output | Add-Member FormatIsValid $false
    }

    $Output.psobject.TypeNames.Insert(0,'MailTools.Security.SPF.Validation_Basic')
    return $Output
}