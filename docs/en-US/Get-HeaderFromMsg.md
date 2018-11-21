---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version: 
schema: 2.0.0
---

# Get-HeaderFromMsg

## SYNOPSIS
Extract the raw header from a .msg file. \[Requires Outlook on the system\]

## SYNTAX

```
Get-HeaderFromMsg [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Uses libraries available in Outlook to extract the raw message source from a .msg file and returns the full header.

If Outlook is not installed on the system where the command is run it will return an error.

## EXAMPLES

### Example 1
```
PS C:\> Get-HeaderFromMsg -Path ".\RE: Your Inquiry.msg"
```

## PARAMETERS

### -Path
Path to msg file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath

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

### System.String

## NOTES

## RELATED LINKS

