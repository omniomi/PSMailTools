# Dot source this script in any Pester test script that requires the module to be imported.

$ModuleManifestName = 'PSMailTools.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"

if (!$SuppressImportModule) {
    # -Scope Global is needed when running tests from inside of psake, otherwise
    # the module's functions cannot be found in the PSMailTools\ namespace
    Import-Module $ModuleManifestPath -Scope Global
}

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='MockDnsReturns')]
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
