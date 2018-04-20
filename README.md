# PSMailTools

|Master   |  Development | v0.2.0 |
|:------:|:------:|:------:|
|[![Build status](https://ci.appveyor.com/api/projects/status/github/omniomi/psmailtools?branch=master&svg=true)](https://ci.appveyor.com/project/omniomi/master/branch/master)|[![Build status](https://ci.appveyor.com/api/projects/status/github/omniomi/psmailtools?branch=development&svg=true)](https://ci.appveyor.com/project/omniomi/master/branch/development)|[![Build status](https://ci.appveyor.com/api/projects/status/github/omniomi/psmailtools?branch=v0.2.0&svg=true)](https://ci.appveyor.com/project/omniomi/master/branch/v0.2.0)|

PowerShell tools for postmasters.

> _NOTE: This project is still in early development and you may encounter strange bugs and non-descript error messages. Keep an eye out for regular updates and improvements of the existing functionality and later the release of new tools. If you'd like to contribute, please send a pull request!_

Release Notes: [ReleaseNotes.md](ReleaseNotes.md)

## Installing and Running

1. [Download the latest PSMailTools.zip](https://github.com/omniomi/PSMailTools/releases/latest).
2. Unpack to `$env:USERPROFILE\Documents\WindowsPowerShell\Modules`.
3. In a new PowerShell window run `Import-Module PSMailTools`.

### Requirements

This module requires the [DnsClient](https://docs.microsoft.com/en-us/powershell/module/dnsclient/) module from MicroSoft and uses the `Resolve-DnsName` cmdlet. A future version will remove this dependency.

## Documentation

* [About PSMailTools](/docs/en-US/about_PSMailTools.help.md)
* [Cmdlet List](/docs/en-US/PSMailTools.md)

## License

This project is [licensed under the MIT License](LICENSE.txt).
