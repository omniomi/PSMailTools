function ResolveDns {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$Name,

        [parameter(Mandatory)]
        [ValidateSet('txt','mx','a','ptr')]
        [string]$Type
    )

    try {
        if ($Name -match "[^=:]+(?:=|:).*") {
            $Name = $Name.Split(':=')[1]
        }

        $Exception = New-Object System.ComponentModel.Win32Exception ("{0} : DNS name does not exist" -f $Name)
        $ErrCategory = [System.Management.Automation.ErrorCategory]::ResourceUnavailable
        $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'ResolveDnsName',$ErrCategory,($Name + ':' + $Type )

        $DnsRecords = Resolve-DnsName $Name -Type $Type -Verbose:$false | Where-Object { $_.Section -ne 'Additional' }

        foreach ($DnsRecord in $DnsRecords) {
            switch ($Type) {
                'mx'  {
                    if ($DnsRecord.NameExchange) {
                        $DnsRecord.NameExchange
                    } else {
                        $PSCmdlet.ThrowTerminatingError($ErrRecord)
                    }
                }
                'a'   {
                    if($DnsRecord.IPAddress) {
                        $DnsRecord.IPAddress
                    } else {
                        $PSCmdlet.ThrowTerminatingError($ErrRecord)
                    }
                }
                'txt' {
                    if ($DnsRecord.Strings) {
                        -join $DnsRecord.Strings
                    } else {
                        $PSCmdlet.ThrowTerminatingError($ErrRecord)
                    }
                }
                'ptr' {
                    if ($DnsRecord.NameHost) {
                        $DnsRecord.NameHost
                    } else {
                        $PSCmdlet.ThrowTerminatingError($ErrRecord)
                    }
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}