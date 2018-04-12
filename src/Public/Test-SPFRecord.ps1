# src\Public\Test-SPFRecord.ps1
function Test-SPFRecord {
    [CmdletBinding()]
    [OutputType('MailTools.Security.SPF.Validation')]
    param (
        # Test by domain name
        [Parameter(Position=0,
                   ValueFromPipelineByPropertyName)]
        [Alias('Domain')]
        [String]
        $Name,

        # Test by record value
        [Parameter(Position=1,
                   ValueFromPipelineByPropertyName)]
        [Alias('Record')]
        [String]
        $Value,

        [Parameter(ParameterSetName='FindIP')]
        [validatescript({
            ([System.Net.IPAddress]$_).AddressFamily -eq 'InterNetwork'
        })]
        [string]
        $FindIP
    )

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'FindIP' {
                    $RecursiveSPF = Resolve-SPFRecord $Name -Verbose:$false
                    $IPAddresses = ($RecursiveSPF.Value -join ' ').Split(' ') | Where-Object { $_ -match [regex]"^(?:ip4:.*|(?:\d+\.){3}\d+)" }

                    $Match = $false

                    foreach ($IP in $IPAddresses) {
                        $CurrentRecord = $RecursiveSPF | Where-Object { $_.Value.Split(' ') -contains $IP }

                        if ($IP -match [regex]"[^\/]+\/\d{1,2}") {
                            $Match = IPInRange $FindIP $IP.Split(':')[1]

                            if ($Match) { break }
                        } else {
                            if ($IP -like "ip4*") { $IPAddr = $IP.Split(':')[1] }
                            else { $IPAddr = $IP }

                            if ($IPAddr -eq $FindIP) {
                                $Match = $true
                                break
                            }
                        }
                    }

                    if ($Match) {
                        Write-Verbose ("Found IP in the SPF record for {4}`n`n`t`tName: {0}`n`t`tValue: {1}`n`t`t{2} matches {3}`n`nUse 'Resolve-SPFRecord {4}' to view the location of this record." -f $CurrentRecord.Name,$CurrentRecord.Value,$IP,$FindIP,$Name)
                    }

                    $Match
                }
                default {
                    if (-not($Name) -and -not($Value)) {
                        $Exception = New-Object System.ArgumentException ('You must specify a domain name or plain-text SPF record to validate.')
                        $ErrCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                        $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'NoDmarcRecord',$ErrCategory,$null
                        $PSCmdlet.ThrowTerminatingError($ErrRecord)
                    }

                    $ValidationParams = @{}
                    if ($Name) { $ValidationParams.Name = $Name }
                    if ($Value) { $ValidationParams.SPFRecord = $Value }

                    ValidateSPF @ValidationParams
                }
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}