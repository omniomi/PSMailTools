# src\Public\Get-DmarcRecord.ps1
function Get-DmarcRecord {
    [CmdletBinding()]
    [OutputType('MailTools.Security.DMARC.DMARCRecord')]
    param (
        # Domain name to retrieve DMARC record for
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('Domain')]
        [String[]]
        $Name
    )

    process {
        foreach ($DomainName in $Name) {
            if ($DomainName -like "_dmarc.*") {
                $DMARCDomain = $DomainName
                $DomainName  = $DomainName.Replace('_dmarc.','')
            } else {
                $DMARCDomain = '_dmarc.' + $DomainName
            }

            $DMARCRecord = ResolveDns -Name $DMARCDomain -Type TXT -ErrorAction SilentlyContinue | Where-Object { $_ -like "v=DMARC1*" }

            if ($DMARCRecord.Count -eq 0) {
                $Exception = New-Object System.Management.Automation.ItemNotFoundException ("The domain {0} has no DMARC records." -f $DMARCDomain)
                $ErrCategory = [System.Management.Automation.ErrorCategory]::ObjectNotFound
                $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'NoDmarcRecord',$ErrCategory,$DMARCDomain
                $PSCmdlet.ThrowTerminatingError($ErrRecord)
            }

            foreach ($Record in $DMARCRecord) {
                [MailTools.Security.DMARC.DMARCRecord]@{
                    Name  = $DomainName
                    Path  = $DMARCDomain
                    Value = $Record
                } | Tee-Object -Variable Output

                if ($null -ne $Output.rua) {
                    $RUADomain = $Output.rua.Split('@')[-1]
                }
                if ($null -ne $RUADomain -and $RUADomain -ne $DomainName) {
                    $AllowDomainPath = $DomainName + '._report._dmarc.' + $RUADomain
                    $AllowRecord = ResolveDns -Name $AllowDomainPath -Type TXT -ErrorAction SilentlyContinue | Where-Object { $_ -like "v=DMARC1*" }

                    if (-not($AllowRecord)) {
                        $Exception = New-Object System.Management.Automation.ItemNotFoundException ("The domain {0} is sending reports to the domain {1} which does not have a valid record to allow this at {2}." -f $DMARCDomain,$RUADomain,$AllowDomainPath)
                        $ErrCategory = [System.Management.Automation.ErrorCategory]::ObjectNotFound
                        $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'NoOutsideDomainRecord',$ErrCategory,$AllowDomainPath
                        $PSCmdlet.WriteError($ErrRecord)
                    }

                    [MailTools.Security.DMARC.DMARCRecord]@{
                        Name  = $RUADomain
                        Path  = $AllowDomainPath
                        Value = $AllowRecord
                    }

                }
            }
        }
    }
}