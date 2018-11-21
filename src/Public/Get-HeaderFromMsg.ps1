function Get-HeaderFromMsg {
    [CmdletBinding()]
    param (
        # Specifies a path to msg file.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Path",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to msg file.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    process {
        try {
            $Outlook = New-Object -ComObject Outlook.Application -ErrorAction Stop
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        try {
            $Message = $Outlook.CreateItemFromTemplate((get-Item $Path).FullName)
            $Header  = $Message.PropertyAccessor.GetProperty("http://schemas.microsoft.com/mapi/proptag/0x007D001E")
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        $Message.Close(0)
        $Header
    }
}
