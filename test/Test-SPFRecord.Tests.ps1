[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

InModuleScope PSMailTools {
    Describe "Test-SPFRecord"{
        Mock -Verifiable Resolve-DnsName -ModuleName PSMailTools {
            $MockDnsReturns = @(
                # SPF Records
                ## Valid SPF Records/Chains
                @{ Name = 'example.com'        ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a mx include:_spf1.example.com ~all' } },
                @{ Name = '_spf1.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 ip4:10.23.08.86 include:_spf2.example.com include:_spf3.example.com -all' } },
                @{ Name = '_spf2.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 ip4:10.221.89.0/24 ip4:10.225.0.0/16 ip4:10.156.131.0/24 ip4:10.179.89.0/28 -all' } },
                @{ Name = '_spf3.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 ip4:10.10.54.65 ip4:10.15.184.12 ip4:10.224.65.55 -all' } },
                @{ Name = 'incamx.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 mx:example.com a:example.com ip4:10.224.65.55 ~all' } },
                @{ Name = 'overten.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 mx:example.com a:example.com include:example.com include:incamx.example.com  ~all' } },

                ## PTR Records
                @{ Name = 'ptr.example.com'    ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a mx ptr -all' } },
                @{ Name = 'ptr2.example.com'   ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a mx ptr:example.com -all' } },
                ## Redirect
                @{ Name = 'rdrct.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 redirect=example.com' } },
                ## Invalid records
                @{ Name = 'inva.example.com'   ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a ~all' } },
                @{ Name = 'invmx.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 mx ~all' } },
                @{ Name = 'invinc.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 include:_doesntexist.example.com ?all' } },
                @{ Name = 'invfmt.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 include: example.com all' } },

                # MX Records
                @{ Name = 'example.com'        ; Type = 'mx'  ; Result = @( @{ NameExchange = 'mail1.example.com' }, @{ NameExchange = 'mail2.example.com' } ) },

                # A records
                @{ Name = 'example.com'        ; Type = 'a'   ; Result = @{ IPAddress = '10.10.80.80' } },
                @{ Name = 'mail1.example.com'  ; Type = 'a'   ; Result = @{ IPAddress = '10.10.25.25' } },
                @{ Name = 'mail2.example.com'  ; Type = 'a'   ; Result = @{ IPAddress = '10.10.25.26' } },

                # PTR Records
                @{ Name = '10.11.11.1'         ; Type = 'ptr' ; Result = @{ NameHost = 'example.com' } },
                @{ Name = '10.11.11.2'         ; Type = 'ptr' ; Result = @{ NameHost = 'ptr.example.com' } }
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

        Context "Normal Operation" {
            it "Does not throw any errors" {
                { Test-SpfRecord example.com } | Should Not Throw
            }

            it "Correctly validates a specified SPF record" {
                $x = Test-SpfRecord example.com

                $X.RecordFound      | Should Be $true
                $X.FormatIsValid    | Should Be $true
                $X.ValidUdpLength   | Should Be $true
                $X.ValidLookupCount | Should Be $true
                $X.LookupCount      | Should Be 5
            }
        }

        Context "Invalid Records" {
            it "Identifies a record with formatting errors" {
                { Test-SpfRecord invfmt.example.com } | Should Throw
            }

            it "Identifies a record with invalid lookups" {
                { Test-SpfRecord invinc.example.com } | Should Throw
            }

            it "Identifies records that exceed 10 lookups" {
                $X = Test-SpfRecord overten.example.com
                $X.LookupCount | Should Be 11
                $X.ValidLookupCount | Should Be $false
            }
        }

        Context "-FindIp" {
            it "Finds the specified IP in explicit ip4: mechanisms" {
                { Test-SpfRecord example.com -FindIp '10.23.08.86' } | Should Be $true
            }

            it "Finds the specified IP in ip4: blocks (ipaddr/mask)" {
                { Test-SpfRecord example.com -FindIp '10.221.89.111' } | Should Be $true
            }

            it "Finds the specified IP in mx records" {
                { Test-SpfRecord example.com -FindIp '10.10.25.26' } | Should Be $true
            }

            it "Finds the specified IP in a records" {
                { Test-SpfRecord example.com -FindIp '10.10.80.80' } | Should Be $true
            }

            it "Finds the specified IP in ptr records" {
                { Test-SpfRecord ptr.example.com -FindIp '10.11.11.2' } | Should Be $true
            }
        }

        Context "MailTools.Security.SPF.Validation" {
            $EvalTrue  = [MailTools.Security.SPF.Validation]@{ Name = 'example.com' ; Value = 'v=spf1 a mx include:_spf.example.com ~all' ; LookupCount = '9' }
            $EvalFalse = [MailTools.Security.SPF.Validation]@{ Name = 'example.com' ; Value = 'v=spf1 a mx include:_spf.example.com include:_spf2.example.com include:_spf3.example.com include:_spf4.example.com include:_spf5.example.com include:_spf6.example.com include:_spf7.example.com include:_spf8.example.com include:_spf9.example.com include:_spf10.example.com ~all' ; LookupCount = '12' }

            It ".ValidUDPLength equals [true] when the SPF record is <= 250 chars." {
                $EvalTrue.ValidUDPLength | Should Be $true
            }

            It ".ValidUDPLength equals [false] when the SPF record is > 250 chars." {
                $EvalFalse.ValidUDPLength | Should Be $false
            }

            It ".ValidLookupCount equals [true] when the SPF record has <= 10 lookups." {
                $EvalTrue.ValidLookupCount | Should Be $true
            }

            It ".ValidLookupCount equals [false] when the SPF record has > 10 lookups." {
                $EvalFalse.ValidLookupCount | Should Be $false
            }
        }
    }
}
