Import-Module MicrosoftTeams
Connect-MicrosoftTeams

$outputArray = @()

# Find all teams with no owner assigned
$listOfTeamsWithNoOwner = Get-UnifiedGroup | Where-Object {([array](Get-UnifiedGroupLinks -Identity $_.Id -LinkType Owners)).Count -eq 0} `
        | Select Id, DisplayName, ManagedBy, WhenCreated

# Add a default owner to all teams without an owner
foreach($team in $listOfTeamsWithNoOwner) { 
    # Write-Host "Warning! The following group has no owner:" $team.DisplayName
    Add-UnifiedGroupLinks -Identity $team.Id -LinkType Owners -Links 'defaultowner@domain.com'
} 

# Get a list of all teams
$listOfTeams = Get-Team
foreach($team in $listOfTeams)
{
    # Write-Output "Finding all owners of team name: $team.DisplayName"
    $listOfOwners = Get-TeamUser -GroupId $team.GroupId -Role Owner

    # If there is only one owner in the group
    if($listOfOwners.Length -eq 1)
    {
        # and the owner is the default owner
        if($listOfOwners[0][0] -eq "defaultowner@domain.com")
        {
            # Write-Output "Default owner found for $team.DisplayName"
            # Populate object array needed to export to csv
            $outputArray += New-Object PsObject -Property @{
                'TeamName' = $team.DisplayName
            }
        }
    }
}

# Save list to csv
if($outputArray.Length -ne 0)
{
    Write-Output 'Exporting report...'
    $outputArray | Export-Csv -Path 'C:\report.csv'
    Write-Output 'Done!'
}
