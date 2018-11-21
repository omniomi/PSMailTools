Function Invoke-MessageHeaderAnalyzer {
    [cmdletbinding(DefaultParameterSetName='Content')]
    [alias("Invoke-MHA")]
    param(
        #
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Content",
                   ValueFromPipeline=$True)]
        [string]
        $Header,

        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Path",
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one or more message headers.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Content') {
            $Text = $Header
        } else {
            $Text = Get-Content $Path -Raw
        }

        ReceivedPath $Header
    }
}
