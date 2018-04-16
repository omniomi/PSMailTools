---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version:
schema: 2.0.0
---

# Get-SpamBlacklist

## SYNOPSIS
Search a number of spam blacklists for an IP or hostname.

## SYNTAX

```
Get-SpamBlacklist [-CheckIp] <String> [-ShowAll] [<CommonParameters>]
```

## DESCRIPTION
Checks a list of common spam blacklists for a specified IP or hostname.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-SpamBlacklist -CheckIp 10.25.110.1

Blacklist              OnList Message
---------              ------ -------
b.barracudacentral.org   True Client host blocked using Barracuda Reputation, see http://www.barracudanetworks.com/reputation/?r=1&ip=10.25.110.1
dnsbl.sorbs.net          True Currently Sending Spam See: http://www.sorbs.net/lookup.shtml?10.25.110.1
spam.dnsbl.sorbs.net     True Spam Received See: http://www.sorbs.net/lookup.shtml?10.25.110.1
bl.spamcop.net           True Blocked - see http://www.spamcop.net/bl.shtml?10.25.110.1
dyna.spamrats.com        True SPAMRATS IP Addresses See: http://www.spamrats.com/bl?10.25.110.1
psbl.surriel.com         True Listed in PSBL, see http://psbl.org/listing?ip=10.25.110.1
```

Checks the blacklists for the ip 10.25.110.1. Use `-ShowAll` to show all blacklists including those that do not include the IP.

## PARAMETERS

### -CheckIp
IP Address to search for in blacklists.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowAll
Show all blacklists even if they do not contain a match for the search.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
