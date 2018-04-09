# PSMailTools

PowerShell tools for postmasters.

NOTE: This project isn't far enough along yet to be in production. If you'd like to contribute, please send a pull request!

## Installing and Running

1. [Download the latest PSMailTools.zip](https://github.com/omniomi/PSMailTools/releases/latest).
2. Unpack to `$env:USERPROFILE\Documents\WindowsPowerShell\Modules`.
3. In a new PowerShell window run `Import-Module PSMailTools`.

## Requirements

This module requires the DnsClient module from MicroSoft and uses the `Resolve-DnsName` cmdlet. A future version will remove this requirement. 
