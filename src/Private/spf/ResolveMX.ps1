filter ResolveMX {
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]
        $Name
    )

    foreach ($Server in $Name) {
        (Resolve-DnsName $Server -Type A).IPAddress
    }
}