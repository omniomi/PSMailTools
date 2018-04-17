function PrintItem {
    [cmdletbinding()]
    [outputtype([System.String[]])]
    param(
        [String]$Name,
        [String]$Value,
        [int]$Level = 0
    )

    OutRecord $Name $Value $Level

    $Mechanisms = $Value.Split(' ')
    foreach ($Item in $Mechanisms) {
        PrintChild $Name $Item $Level
    }
}