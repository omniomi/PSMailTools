---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version: https://github.com/omniomi/PSMailTools/blob/master/docs/en-US/Test-SPFRecord.md
schema: 2.0.0
---

# Test-SpfRecord

## SYNOPSIS
Check the validity of an SPF record.

## SYNTAX

```
Test-SpfRecord [[-Name] <String>] [[-Value] <String>] [-FindIP <String>] [<CommonParameters>]
```

## DESCRIPTION
Check the validity of either a provided plain text SPF record or a live SPF record on a provided domain.

Basic: A basic check will ensure only a single SPF record is present, that it is formatted correctly, and that it is within the maximum length restrictions.

## EXAMPLES

### Example 1
```
PS C:\> Test-SPFRecord google.com

   Name: google.com

Value         : v=spf1 include:_spf.google.com ~all
RecordFound   : True
FormatIsValid : True
ValidLength   : True
```

### Example 2
```
PS C:\> Test-SPFRecord -Record 'v=spf1 include:_spf.google.com ~all'

   Name: Unspecified

Value         : v=spf1 include:_spf.google.com ~all
RecordFound   : True
FormatIsValid : True
ValidLength   : True
```

### Example 3
```
PS C:\> Test-SPFRecord google.com -FindIP 172.217.128.0
True
```

## PARAMETERS

### -FindIP
Search for an IPv4 address recursively within a domain's SPF record.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
A domain name to perform SPF validation on.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Domain

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Value
A plain text record to validate.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Record

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### MailTools.Security.SPF.Validation_Basic

## NOTES

## RELATED LINKS
