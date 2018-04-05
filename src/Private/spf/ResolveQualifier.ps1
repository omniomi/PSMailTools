filter ResolveQualifier {
    param (
        [Parameter(ValueFromPipeline)]
        [String]
        $Record
    )

    $Record = -join $Record

    switch -Regex ($Record) {
        ".\~all$" { 'SoftFail' }
        ".\+all$" { 'AllowAll' }
        ".\-all$" { 'HardFail' }
        ".\?all$" { 'Neutral'  }
        default   { 'Invalid'  }
    }
}