[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

InModuleScope PSMailTools {
    Describe "Get-SPFRecord" {
        Context "Normal Operation" {
            Mock ReturnSPF -ModuleName PSMailTools {
                return 'v=spf1 a mx include:_spf.example.com ~all'
            }

            It "Does not return any errors." {
                { Get-SPFRecord example.com } | Should Not Throw
            }

            It "Returns a MailTools.Security.SPF.SPFRecord" {
                Get-SPFRecord example.com | Should BeOfType [MailTools.Security.SPF.SPFRecord]
            }
        }

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

            It "Displays a warning when there is more than one record on a domain." {
                ((Get-SPFRecord example.com) 3>&1) -match "more than one SPF record" | Should Be $true
            }

            It "Returns multiple records on the same domain correctly." {
                (Get-SPFRecord example.com -WarningAction SilentlyContinue).Count | Should be 2
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
}