param([string]$Tenant, [string]$SvcPrincipalName, [string]$SvcPrincipalPass, [int]$StartYear, [int]$NumYears, [string]$ExportName, [string]$StorageAccountName, [string]$ResourceGroupName, [string]$ContainerName, [string]$SubsFile)

$subscriptions = Get-Content $SubsFile -Delimiter ","
$startDates = @("-01-01T00:00:00Z", "-04-01T00:00:00Z", "-07-01T00:00:00Z", "-10-01T00:00:00Z")
$endDates = @("-03-31T23:59:59Z", "-06-30T23:59:59Z", "-09-30T23:59:59Z", "-12-31T23:59:59Z")

#$StartYear = 2018
#$NumYears = 3

# Loop through the subscriptoins
For ($i=0; $i -lt $subscriptions.Length; $i++)
{
    Write-Output $subscriptions[$i]

    For ($year=0; $year -lt $NumYears; $year++)
    {
        $currentYear = $StartYear + $year
        Write-Output $currentYear

        For ($qtr=0; $qtr -lt 4; $qtr++)
        {
            # Create a date string dynamically
            $startDate = "" + $currentYear + $startDates[$qtr]
            $endDate = "" + $currentYear + $endDates[$qtr]

            # Make the quarter 1-based for ease of reading
            $q = $qtr + 1

            # Create an export name unique for each year and quarter
            $name = $ExportName + "-" + $currentYear + "-" + $q
            
            # Call the new export script and start it immediately
            & ./NewExport.ps1 -Tenant $Tenant -Subscription $subscriptions[$i] -SvcPrincipalName $SvcPrincipalName -SvcPrincipalPass $SvcPrincipalPass -StartDate $startDate -EndDate $endDate -ExportName $name -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -ContainerName $ContainerName -StartImmediately $True
            
            # Send something out to the console to see whats going on
            $statusText = "Created Export for " + $subscriptions[$i] + " " + $startDate + " " + $endDate
            Write-Output $statusText
        }
    }
}