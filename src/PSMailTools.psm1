# --------------------------- Load Loose Files ----------------------------
#
$ModuleScriptFiles = @(Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -Recurse  | Where-Object { $_.Name -notlike "*.ps1xml" } )

foreach ($ScriptFile in $ModuleScriptFiles) {
    try {
       Write-Verbose "Loading script file $($ScriptFile.Name)"
        . $ScriptFile.FullName
    }
    catch {
       Write-Error "Error loading script file $($ScriptFile.FullName)"
    }
}

# --------------------------- Public Functions ----------------------------
#
