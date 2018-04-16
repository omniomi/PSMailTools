[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

InModuleScope PSMailTools {
    Describe "Get-DmarcRecord" {
        Mock -Verifiable Resolve-DnsName -ModuleName PSMailTools {
            $MockDnsReturns = @(
                # SPF Records
                ## Valid SPF Records/Chains
                @{ Name = '_dmarc.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=DMARC1; p=none; rua=mailto:dmarc-reports@example.com; ruf=mailto:dmarc-forensic-reports@example.com' } },
                @{ Name = '_dmarc.example.org' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=DMARC1; p=none; rua=mailto:dmarc-reports@example.com; ruf=mailto:dmarc-forensic-reports@example.com' } },
                @{ Name = '_dmarc.example.net' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=DMARC1; p=none; rua=mailto:dmarc-reports@example.com; ruf=mailto:dmarc-forensic-reports@example.com' } },
                @{ Name = 'example.org._report._dmarc.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=DMARC1' } }
            )

            $Output = ($MockDnsReturns | Where-Object {$_.Type -eq $Type -and $_.Name -eq $Name } ).Result
            if ($Output) {
                return $Output
            } elseif (-not($Output) -and $Name -in $MockDnsReturns.Name) {
                return @{
                    Name              = $Name
                    Type              = 'SOA'
                    TTL               = 3000
                    Section           = 'Authority'
                    PrimaryServer     = 'dns.example.com'
                    NameAdministrator = 'noc.dns.example.com'
                    SerialNumber      = 111111111

                }
            } else {
                $Exception = New-Object System.ComponentModel.Win32Exception ("{0} : DNS name does not exist (mocked)" -f $Name)
                $ErrCategory = [System.Management.Automation.ErrorCategory]::ResourceUnavailable
                $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'NoDmarcRecord',$ErrCategory,$Name
                throw $ErrRecord
            }
        }

        Context "Valid Record" {
            it "Does not throw any errors" {
                { Get-DmarcRecord example.com } | Should Not throw
            }

            it "Correctly returns the DMARC record" {
                $X = Get-DmarcRecord example.com
                $X.Path  | Should Be '_dmarc.example.com'
                $X.Value | Should Be 'v=DMARC1; p=none; rua=mailto:dmarc-reports@example.com; ruf=mailto:dmarc-forensic-reports@example.com'
                $X.p     | Should Be 'none'
                $X.rua   | Should Be 'dmarc-reports@example.com'
                $X.ruf   | Should Be 'dmarc-forensic-reports@example.com'
            }
        }

        Context "Valid record with cross-domain RUA" {
            it "Retrievs the _report._dmarc. record whe a cross-domain rua is detected" {
                $X = Get-DmarcRecord example.org
                $X.Count    | Should Be 2
                $X[1].Path  | Should Be 'example.org._report._dmarc.example.com'
                $X[1].Value | Should Be 'v=DMARC1'
                Assert-MockCalled -CommandName Resolve-DnsName -Times 2 -ModuleName PSMailTools -Scope It
            }
        }

        Context "Error handling" {
            it "Throws an error when no DMARC record is found" {
                { Get-DmarcRecord example.edu } | Should Throw
            }
            it "Throws an error with cross-domain RUA and no _report._dmarc. record" {
                { Get-DmarcRecord example.net } | Should Throw
            }
        }

        Context "MailTools.Security.DMARC.DMARCRecord" {
            it "Correctly splits the record into parts" {
                $X = [MailTools.Security.DMARC.DMARCRecord]@{ Name = 'example.com' ; Path = '_dmarc.example.com' ; Value = 'v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@example.com;ruf=mailto:postmaster@example.com;sp=reject;adkim=s;aspf=r'}

                $x.Name  | Should Be 'example.com'
                $x.Path  | Should Be '_dmarc.example.com'
                $x.Value | Should Be 'v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@example.com;ruf=mailto:postmaster@example.com;sp=reject;adkim=s;aspf=r'
                $x.p     | Should Be 'reject'
                $x.pct   | Should Be '100'
                $x.rua   | Should Be 'postmaster@example.com'
                $x.ruf   | Should Be 'postmaster@example.com'
                $x.sp    | Should Be 'reject'
                $x.adkim | Should Be 's'
                $x.aspf  | Should Be 'r'
            }
        }
    }
}