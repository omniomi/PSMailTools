---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version: https://github.com/omniomi/PSMailTools/blob/master/docs/en-US/Get-DMARCRecord.md
schema: 2.0.0
---

# Get-DmarcRecord

## SYNOPSIS
Return the DMARC record associated with the specified domain.

## SYNTAX

```
Get-DmarcRecord [-Name] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Will return the DMARC record for the specified domain and the allow cross-domain record if applicable for the rua/ruf values.

## EXAMPLES

### Example 1
```
PS C:\> Get-DMARCRecord google.com

Name       Path              Value
----       ----              -----
google.com _dmarc.google.com v=DMARC1; p=reject; rua=mailto:mailauth-reports@google.com
```

Returns the DMARC record for the specified domain

### Example 2
```
PS C:\> Get-DMARCRecord gmail.com

Name       Path                                Value
----       ----                                -----
gmail.com  _dmarc.gmail.com                    v=DMARC1; p=none; sp=quarantine; rua=mailto:mailauth-reports@google.com
google.com gmail.com._report._dmarc.google.com v=DMARC1
```

Returns both the DMARC record for the specified domain and the record allow cross-domain rua when applicable.

## PARAMETERS

### -Name
The domain name to query for DMARC.

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

### System.String[]

## OUTPUTS

### MailTools.Security.DMARC.DMARCRecord

## NOTES

## RELATED LINKS
