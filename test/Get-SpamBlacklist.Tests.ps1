[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

InModuleScope -ModuleName PSMailTools {
    Describe "Resolve-SpfRecord" {
        Mock -Verifiable Resolve-DnsName -ModuleName PSMailTools {
            $MockDnsReturns = @(
                # A records
                @{ Name = 'example.com' ; Type = 'a' ; Result = @{ IPAddress = '10.10.80.80' } },

                # Blacklist Entires
                @{ Name = '80.80.10.10.spam.dnsbl.sorbs.net' ; Type = 'a' ; Result = @{ IPAddress = '127.0.0.2' } },
                @{ Name = '80.80.10.10.dyna.spamrats.com'    ; Type = 'a' ; Result = @{ IPAddress = '127.0.0.2' } },

                # TXT Records
                @{ Name = '80.80.10.10.spam.dnsbl.sorbs.net' ; Type = 'txt' ; Result = @{ Strings = [string[]]'Currently Sending Spam See: http://www.sorbs.net/lookup.shtml?10.10.80.80' } },
                @{ Name = '80.80.10.10.dyna.spamrats.com'    ; Type = 'txt' ; Result = @{ Strings = [string[]]'SPAMRATS IP Addresses See: http://www.spamrats.com/bl?153.149.230.14' } }
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
            }
        }

        Context "Normal Operation" {
            it "Does not throw any errors" {
                { Get-SpamBlacklist 10.10.80.80 } | Should Not Throw
                { Get-SpamBlacklist example.com } | Should Not Throw
            }

            it "Correctly identifies spamlists by IP" {
                (Get-SpamBlacklist 10.10.80.80).Count | Should Be 2
            }

            it "Correctly identifies spamlists by hostname" {
                (Get-SpamBlacklist example.com).Count | Should Be 2
            }
        }
    }
}