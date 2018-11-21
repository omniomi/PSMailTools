---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version: https://github.com/omniomi/PSMailTools/blob/master/docs/en-US/Resolve-SPFRecord.md
schema: 2.0.0
---

# Resolve-SpfRecord

## SYNOPSIS
Return an SPF record recursively.

## SYNTAX

### Default (Default)
```
Resolve-SpfRecord [-Name] <String> [<CommonParameters>]
```

### InputObj
```
Resolve-SpfRecord -InputObj <SPFRecord[]> [<CommonParameters>]
```

## DESCRIPTION
Follows any lookup (a, mx, include, redirect) mechanisms included in a given SPF record recursively to show all includes.

## EXAMPLES

### Example 1
```
PS C:\> Resolve-SPFRecord google.com

Name                   Value
----                   -----
google.com             v=spf1 include:_spf.google.com ~all
_spf.google.com        v=spf1 include:_netblocks.google.com include:_netblocks2.google.com include:_netblocks3.google.com ~all
_netblocks.google.com  v=spf1 ip4:64.233.160.0/19 ip4:66.102.0.0/20 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:74.125.0.0/16 ip4:108.177.8.0/21 ip4:173.194.0.0/16 ip4:209.85.128.0/17 ip4:216.58.192.0/19 ip4:216.239.32.0/19 ~all
_netblocks2.google.com v=spf1 ip6:2001:4860:4000::/36 ip6:2404:6800:4000::/36 ip6:2607:f8b0:4000::/36 ip6:2800:3f0:4000::/36 ip6:2a00:1450:4000::/36 ip6:2c0f:fb50:4000::/36 ~all
_netblocks3.google.com v=spf1 ip4:172.217.0.0/19 ip4:172.217.32.0/20 ip4:172.217.128.0/19 ip4:172.217.160.0/20 ip4:172.217.192.0/19 ip4:108.177.96.0/19 ~all
```

Recursively display all lookups for a given domain name

### Example 2
```
PS C:\> Get-SPFRecord google.com | Resolve-SPFRecord

Name                   Value
----                   -----
google.com             v=spf1 include:_spf.google.com ~all
_spf.google.com        v=spf1 include:_netblocks.google.com include:_netblocks2.google.com include:_netblocks3.google.com ~all
_netblocks.google.com  v=spf1 ip4:64.233.160.0/19 ip4:66.102.0.0/20 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:74.125.0.0/16 ip4:108.177.8.0/21 ip4:173.194.0.0/16 ip4:209.85.128.0/17 ip4:216.58.192.0/19 ip4:216.239.32.0/19 ~all
_netblocks2.google.com v=spf1 ip6:2001:4860:4000::/36 ip6:2404:6800:4000::/36 ip6:2607:f8b0:4000::/36 ip6:2800:3f0:4000::/36 ip6:2a00:1450:4000::/36 ip6:2c0f:fb50:4000::/36 ~all
_netblocks3.google.com v=spf1 ip4:172.217.0.0/19 ip4:172.217.32.0/20 ip4:172.217.128.0/19 ip4:172.217.160.0/20 ip4:172.217.192.0/19 ip4:108.177.96.0/19 ~all
```

Pipe the results of Get-SPFRecord to follow lookups.

## PARAMETERS

### -InputObj
Pipe the output from Get-SpfRecord to Resolve-SpfRecord.

```yaml
Type: SPFRecord[]
Parameter Sets: InputObj
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Root domain name from which to start the recursive lookup.

```yaml
Type: String
Parameter Sets: Default
Aliases: Domain

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### MailTools.Security.SPF.Recursive[]

## NOTES

## RELATED LINKS

