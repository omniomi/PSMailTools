[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

InModuleScope -ModuleName PSMailTools {
    Describe "ConvertTo-SPFTree" {
        $Record = @'
"Level","Name","Value","All"
"0","example.com","v=spf1 a mx ip4:10.10.88.81 ip4:10.11.99.91 include:_spf.google.com ~all","~all"
"1","a","10.10.88.81",""
"1","mx","ASPMX2.GOOGLEMAIL.com ALT2.ASPMX.L.GOOGLE.com ASPMX3.GOOGLEMAIL.com ASPMX.L.GOOGLE.com ALT1.ASPMX.L.GOOGLE.com",""
"2","ASPMX2.GOOGLEMAIL.com","209.85.147.26",""
"2","ALT2.ASPMX.L.GOOGLE.com","64.233.176.26",""
"2","ASPMX3.GOOGLEMAIL.com","64.233.176.26",""
"2","ASPMX.L.GOOGLE.com","74.125.28.26",""
"2","ALT1.ASPMX.L.GOOGLE.com","209.85.147.26",""
"1","include:_spf.google.com","v=spf1 include:_netblocks.google.com include:_netblocks2.google.com include:_netblocks3.google.com ~all","~all"
"2","include:_netblocks.google.com","v=spf1 ip4:64.233.160.0/19 ip4:66.102.0.0/20 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:74.125.0.0/16 ip4:108.177.8.0/21 ip4:173.194.0.0/16 ip4:209.85.128.0/17 ip4:216.58.192.0/19 ip4:216.239.32.0/19 ~all","~all"
"2","include:_netblocks2.google.com","v=spf1 ip6:2001:4860:4000::/36 ip6:2404:6800:4000::/36 ip6:2607:f8b0:4000::/36 ip6:2800:3f0:4000::/36 ip6:2a00:1450:4000::/36 ip6:2c0f:fb50:4000::/36 ~all","~all"
"2","include:_netblocks3.google.com","v=spf1 ip4:172.217.0.0/19 ip4:172.217.32.0/20 ip4:172.217.128.0/19 ip4:172.217.160.0/20 ip4:172.217.192.0/19 ip4:108.177.96.0/19 ~all","~all"
'@

        $ExpectedOutput = @(
            '----------------------------------------'
            'Domain:     example.com'
            'SPF Record: v=spf1 a mx ip4:10.10.88.81 ip4:10.11.99.91 include:_spf.google.com ~all'
            '----------------------------------------'
            ' | example.com'
            ' | | a'
            ' | | | 10.10.88.81'
            ' | | mx'
            ' | | | ASPMX2.GOOGLEMAIL.com'
            ' | | | | 209.85.147.26'
            ' | | | ALT2.ASPMX.L.GOOGLE.com'
            ' | | | | 64.233.176.26'
            ' | | | ASPMX3.GOOGLEMAIL.com'
            ' | | | | 64.233.176.26'
            ' | | | ASPMX.L.GOOGLE.com'
            ' | | | | 74.125.28.26'
            ' | | | ALT1.ASPMX.L.GOOGLE.com'
            ' | | | | 209.85.147.26'
            ' | | ip4:10.10.88.81'
            ' | | ip4:10.11.99.91'
            ' | | include:_spf.google.com'
            ' | | | include:_netblocks.google.com'
            ' | | | | ip4:64.233.160.0/19'
            ' | | | | ip4:66.102.0.0/20'
            ' | | | | ip4:66.249.80.0/20'
            ' | | | | ip4:72.14.192.0/18'
            ' | | | | ip4:74.125.0.0/16'
            ' | | | | ip4:108.177.8.0/21'
            ' | | | | ip4:173.194.0.0/16'
            ' | | | | ip4:209.85.128.0/17'
            ' | | | | ip4:216.58.192.0/19'
            ' | | | | ip4:216.239.32.0/19'
            ' | | | | ~all'
            ' | | | include:_netblocks2.google.com'
            ' | | | | ip6:2001:4860:4000::/36'
            ' | | | | ip6:2404:6800:4000::/36'
            ' | | | | ip6:2607:f8b0:4000::/36'
            ' | | | | ip6:2800:3f0:4000::/36'
            ' | | | | ip6:2a00:1450:4000::/36'
            ' | | | | ip6:2c0f:fb50:4000::/36'
            ' | | | | ~all'
            ' | | | include:_netblocks3.google.com'
            ' | | | | ip4:172.217.0.0/19'
            ' | | | | ip4:172.217.32.0/20'
            ' | | | | ip4:172.217.128.0/19'
            ' | | | | ip4:172.217.160.0/20'
            ' | | | | ip4:172.217.192.0/19'
            ' | | | | ip4:108.177.96.0/19'
            ' | | | | ~all'
            ' | | | ~all'
            ' | | ~all'
            '----------------------------------------'
            'DNS Lookup Count: 6 out of 10'
            '----------------------------------------'
        )

        $RecursiveSpf = foreach ($Row in ($Record | ConvertFrom-Csv)) {
            [MailTools.Security.SPF.Recursive]$Row
        }

        it "Does's throw any errors." {
            { $RecursiveSpf | ConvertTo-SpfTree } | Should Not Throw
        }

        it "Correctly formats the output of Resolve-SpfRecord" {
            $x = $RecursiveSpf | ConvertTo-SpfTree
            (-join $x) | Should Be (-join $ExpectedOutput)
        }

        it "Throws an error if piped the wrong object type" {
            $x = [MailTools.Security.SPF.SpfRecord]@{ Name = 'Example.com' ; Value = 'v=spf1 a mx ip4:10.10.88.81 ip4:10.11.99.91 include:_spf.google.com ~all'} | ConvertTo-SpfTree 2>&1
            $x.exception -like "*This command only accepts output from Resolve-SpfRecord*" | Should Be $true
        }
    }
}