function OutRecord {
    param(
        [String]$Name,
        [String]$Value,
        [int]$Level = 0
    )

    [MailTools.Security.SPF.Recursive]@{
        Name  = $Name
        Value = $Value
        Level = $Level
    }

}