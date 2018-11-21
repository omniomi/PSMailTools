function ReceivedPath {
    [cmdletbinding()]
    [OutputType('MailTools.Message.Source.Received')]
    param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Content",
                   ValueFromPipeline=$True)]
        [string]
        $Header
    )

    [regex]$RegEx = '(?mi)^Received: (?:.*\n\s+.*)+(?!^\p{L})'
    $ReceivedRegex = '^Received:\sfrom\s(?<from>.+)?\sby\s(?<by>.+)?\swith\s(?<with>.+)?;\s(?<date>.+)'

    $MatchedItems = $Header | Select-String -Pattern $RegEx -AllMatches
    [array]::Reverse($MatchedItems.Matches)

    $Hop = 0
    $Out = @(foreach ($Item in $MatchedItems.Matches) {
        $ReceivedString = $Item.Value -replace "`n", " " -replace "`r", " " -replace "`t", " " -replace "\s{2,}", " "
        $null = $ReceivedString -match $ReceivedRegex
        $From = $Matches['from']
        $By = $Matches['by']
        $Timestamp = Get-Date $Matches['date'] -Format u

        if ($Hop -ge 1) {
            $HopLength = New-TimeSpan $PreviousHop $Timestamp.ToString()
        }
        else {
            $HopLength = '*'
        }

        switch -wildcard ($Matches['with']) {
            "SMTP*" { $With = 'SMTP' }
            "ESMTP*" { $With = 'ESMTP' }
            "HTTPS *" { $With = 'HTTPS' }
            "HTTP *" { $With = 'HTTP' }
            default {
                $What = $Matches['with']
                if ($Matches['with'] -match "(?:\p{L}|\s)\(.+") {
                    $With = $What -replace "(.+\))?\s.+", '$1'
                }
                    else {
                        $With = $What
                    }
                }
            }

            [MailTools.Message.Source.Received]@{
                Hop       = $Hop
                Delay     = $HopLength
                From      = $From
                By        = $By
                With      = $With
                Timestamp = $Timestamp
            }
            $Hop++
            $PreviousHop = $Timestamp
        })

    $Out
}
