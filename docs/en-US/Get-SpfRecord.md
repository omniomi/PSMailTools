---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version: https://github.com/omniomi/PSMailTools/blob/master/docs/en-US/Get-SPFRecord.md
schema: 2.0.0
---

# Get-SpfRecord

## SYNOPSIS
Get the SPF record defined on the specified domain name.

## SYNTAX

```
Get-SpfRecord [-Name] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Returns any TXT records on the domain starting with v=spf1.

## EXAMPLES

### Example 1
```
PS C:\> Get-SPFRecord google.com

Name       Value
----       -----
google.com v=spf1 include:_spf.google.com ~all
```

Returns the SPF record for the specified domain.

## PARAMETERS

### -Name
The domain name for which to retrieve the SPF record.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Domain

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### MailTools.Security.SPF.SPFRecord[]

## NOTES

## RELATED LINKS

