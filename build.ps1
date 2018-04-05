#Requires -Modules psake
[cmdletbinding()]
param(
    [ValidateSet('Build','Test','BuildHelp','Install','Clean','Analyze','Publish','ExportPublicFunctions')]
    [string[]]$Task = 'Build'
)

Import-Module psake;Import-Module Pester;Import-Module PSScriptAnalyzer
Invoke-psake -buildFile "$PSScriptRoot\build.psake.ps1" -taskList $Task -Verbose:$VerbosePreference