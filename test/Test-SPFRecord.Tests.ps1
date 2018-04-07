[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='SuppressImportModule')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

InModuleScope PSMailTools {
    Describe "Test-SPFRecord"{
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
