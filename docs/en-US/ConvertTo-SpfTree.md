---
external help file: PSMailTools-help.xml
Module Name: PSMailTools
online version: https://github.com/omniomi/PSMailTools/blob/master/docs/en-US/ConvertTo-SPFTree.md
schema: 2.0.0
---

# ConvertTo-SpfTree

## SYNOPSIS
Converts an SPFRecord object to a hierarchy tree for easy visualization.

## SYNTAX

```
ConvertTo-SpfTree [[-InputObj] <SPFRecord[]>] [<CommonParameters>]
```

## DESCRIPTION
Converts the output of Resolve-SPFRecord to a hierarchy tree for easy visualization and sharing.

## EXAMPLES

### Example 1
```
PS C:\> Resolve-SPFRecord google.com | ConvertTo-SPFTree
----------------------------------------
Domain:     google.com
SPF Record: v=spf1 include:_spf.google.com ~all
----------------------------------------
| include:_spf.google.com
| | include:_netblocks.google.com
| | | ip4:64.233.160.0/19
| | | ip4:66.102.0.0/20
| | | ip4:66.249.80.0/20
| | | ip4:72.14.192.0/18
| | | ip4:74.125.0.0/16
| | | ip4:108.177.8.0/21
| | | ip4:173.194.0.0/16
| | | ip4:209.85.128.0/17
| | | ip4:216.58.192.0/19
| | | ip4:216.239.32.0/19
| | | ~all
| | include:_netblocks2.google.com
| | | ip6:2001:4860:4000::/36
| | | ip6:2404:6800:4000::/36
| | | ip6:2607:f8b0:4000::/36
| | | ip6:2800:3f0:4000::/36
| | | ip6:2a00:1450:4000::/36
| | | ip6:2c0f:fb50:4000::/36
| | | ~all
| | include:_netblocks3.google.com
| | | ip4:172.217.0.0/19
| | | ip4:172.217.32.0/20
| | | ip4:172.217.128.0/19
| | | ip4:172.217.160.0/20
| | | ip4:172.217.192.0/19
| | | ip4:108.177.96.0/19
| | | ~all
| | ~all
| ~all
----------------------------------------
DNS Lookup Count: 4 out of 10
----------------------------------------
```

Displays a simple hierarchy tree for the provided recursive SPF record.

## PARAMETERS

### -InputObj
Output from Resolve-SPFRecord

```yaml
Type: SPFRecord[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String[]

## NOTES

## RELATED LINKS

