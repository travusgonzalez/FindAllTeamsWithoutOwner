Import-Module MicrosoftTeams
Connect-MicrosoftTeams

$listOfTeamsWithNoOwner = @()
$listOfTeams = Get-Team

foreach($team in $listOfTeams)
{
    # Write-Output "Finding all owners of team name: $team.DisplayName"
    $listOfOwners = Get-TeamUser -GroupId $team.GroupId -Role Owner

    if($listOfOwners.Length -eq 0)
    {
        # Write-Output "No owners found for $team.DisplayName"
        # Populate object array needed to export to csv
        $listOfTeamsWithNoOwner += New-Object PsObject -Property @{
            'TeamName' = $team.DisplayName
        }
    }
}

# Save list to csv
if($listOfTeamsWithNoOwner.Length -ne 0)
{
    Write-Output 'Exporting report...'
    $listOfTeamsWithNoOwner | Export-Csv -Path 'C:\report.csv'
    Write-Output 'Done!'
}
