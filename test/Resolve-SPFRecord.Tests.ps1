[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

Describe "Resolve-SpfRecord" {
    Mock -Verifiable Resolve-DnsName -ModuleName PSMailTools {
        $MockDnsReturns = @(
            # SPF Records
            ## Valid SPF Records/Chains
            @{ Name = 'example.com'        ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a mx include:_spf1.example.com ~all' } },
            @{ Name = '_spf1.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 ip4:10.23.08.86 include:_spf2.example.com include:_spf3.example.com -all' } },
            @{ Name = '_spf2.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 ip4:10.221.89.0/24 ip4:10.225.0.0/16 ip4:10.156.131.0/24 ip4:10.179.89.0/28 -all' } },
            @{ Name = '_spf3.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 ip4:10.10.54.65 ip4:10.15.184.12 ip4:10.224.65.55 -all' } },
            @{ Name = 'incamx.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 mx:example.com a:example.com ip4:10.224.65.55 ~all' } },
            ## PTR Records
            @{ Name = 'ptr.example.com'    ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a mx ptr -all' } },
            @{ Name = 'ptr2.example.com'   ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a mx ptr:example.com -all' } },
            ## Redirect
            @{ Name = 'rdrct.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 redirect=example.com' } },
            ## Invalid records
            @{ Name = 'inva.example.com'   ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 a ~all' } },
            @{ Name = 'invmx.example.com'  ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 mx ~all' } },
            @{ Name = 'invinc.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 include:_doesntexist.example.com ?all' } },
            @{ Name = 'invfmt.example.com' ; Type = 'txt' ; Result = @{ Strings = [string[]]'v=spf1 include: example.com ?all' } },

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

    Context "Valid records" {
        it "Doesn't throw any errors" {
            { Resolve-SpfRecord -Name _spf3.example.com } | Should Not Throw
            Assert-MockCalled -CommandName Resolve-DnsName -Times 1 -ParameterFilter { $Name -eq '_spf3.example.com' } -ModuleName PSMailTools -Scope It
        }

        $X = Resolve-SpfRecord -Name example.com

        it "Follows records recursively" {
            $X.Count | Should Be 8
        }

        it "Correctly assigns nesting levels" {
            -join $X.Level | Should Be '01122122'
        }

        it "Follows redirects recursively" {
            $Redirect = Resolve-SpfRecord -Name rdrct.example.com
            $Redirect.Count | Should Be 9
            -join $Redirect.Level | Should Be '012233233'
        }

        it "Skips the first lookup when passed an object with name and value" {
            $X = @{Name = '_spf3.example.com' ; Value = 'v=spf1 ip4:10.10.54.65 ip4:10.15.184.12 ip4:10.224.65.55 -all' } | Resolve-SpfRecord
            $X.Count | Should Be 1
            $X.Level | Should Be 0
            Assert-MockCalled -CommandName Resolve-DnsName -Times 0 -ModuleName PSMailTools -Scope It
        }
    }

    Context "Invalid records" {

    }
}
