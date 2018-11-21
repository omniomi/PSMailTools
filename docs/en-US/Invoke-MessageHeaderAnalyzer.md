---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version: 
schema: 2.0.0
---

# Invoke-MessageHeaderAnalyzer

## SYNOPSIS
Convert an email message header to objects.

## SYNTAX

### Content (Default)
```
Invoke-MessageHeaderAnalyzer [-Header] <String> [<CommonParameters>]
```

### Path
```
Invoke-MessageHeaderAnalyzer [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Functions similar to message header analyzers available on the web but locally in PowerShell.

Will show the path the email took as well as each item in the message's header as filterable properties.

## EXAMPLES

### Example 1
```
PS C:\> Invoke-MessageHeaderAnalyzer -Path '.\header.txt'
```

## PARAMETERS

### -Header
A multiline string containing the message header.

```yaml
Type: String
Parameter Sets: Content
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to one or more message headers as text files.

```yaml
Type: String[]
Parameter Sets: Path
Aliases: PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

