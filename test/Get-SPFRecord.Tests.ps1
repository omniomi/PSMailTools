[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

InModuleScope PSMailTools {

    Context "Multiple SPF Records" {
        Mock Resolve-DnsName {
            [Microsoft.DnsClient.Commands.DnsRecord_TXT]@{
                name = 'example.com'
                strings = 'v=spf1','a','mx','-all'
            }
            [Microsoft.DnsClient.Commands.DnsRecord_TXT]@{
                name = 'example.com'
                strings = 'v=spf1','a','mx','-all'
            }
        }

        It "Returns multiple records on the same domain correctly." {
            (Get-SPFRecord example.com).Count | Should be 2
        }

        It "Displays a waring when there is more than one record on a domain." {
            ((Get-SPFRecord example.com) 3>&1) -match "more than one SPF record" | Should Be $true
        }
    }

    Context "Error Checking" {
        Mock Resolve-DnsName {
            [Microsoft.DnsClient.Commands.DnsRecord_TXT]@{
                name = 'example.com'
                strings = $null
            }
        }

        It "Error when no record found." {
            { Get-SPFRecord example.com } | Should Throw
        }
    }
}