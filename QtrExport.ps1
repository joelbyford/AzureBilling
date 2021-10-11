param([string]$Tenant, [string]$SvcPrincipalName, [string]$SvcPrincipalPass, [int]$StartYear, [int]$NumYears, [string]$ExportName, [string]$StorageAccountName, [string]$ResourceGroupName, [string]$ContainerName, [string]$SubsFile, [string]$Region)
# Tenant             - The Tenant where the service principal exists
# SvcPrincipalName   - The ClientID of the service principal
# SvcPrincipalPass   - The Secret generated for the Service Principal
# StartYear          - Starting year for the export. (e.g. 2018)
# NumYears           - The number of years to export (e.g. 3 years would be 2018, 2019 & 2020)
# ExportName         - Prefix of the export which will be concatonated with the year and quarter (e.g. MyExport-2018-1)
# StorageAccountName - The name of the NEW Storage Account to be created in each subscription to store exports.
# ResourceGroupName  - The Resouce Group where the NEW Storage Account will be located.
# ContainerName      - The NEW Blob container where the exports will be sent by the export process.
# Region             - Region in which the new storage account will be created (e.g. "uswest")
# SubsFile           - The comma separated file where all subscriptions are listed.
# IMPORTANT - CHANGE THE SKU LATER IN THIS FILE BASED ON YOUR NEEDS

$subscriptions = Get-Content $SubsFile -Delimiter ","
$startDates = @("-01-01T00:00:00Z", "-04-01T00:00:00Z", "-07-01T00:00:00Z", "-10-01T00:00:00Z")
$endDates = @("-03-31T23:59:59Z", "-06-30T23:59:59Z", "-09-30T23:59:59Z", "-12-31T23:59:59Z")

# Loop through the subscriptoins
For ($i=0; $i -lt $subscriptions.Length; $i++)
{
    Write-Output $subscriptions[$i]
    # --------------------------------------------------------------------
    # ------ START - REMOVE THIS IF NOT USING A SERVICE Principal --------
    # --------------------------------------------------------------------

    # Convert the service Principal password to a Secure String
    # and create a Credential object with the Service Princple information for use in connecting to Azure
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential
    $Password = ConvertTo-SecureString -String $SvcPrincipalPass -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SvcPrincipalName, $Password

    # Connect to Azure
    # https://docs.microsoft.com/en-us/powershell/module/az.accounts/Connect-AzAccount
    Connect-AzAccount -Tenant $Tenant -Subscription $Subscriptions[$i] -Credential $Credential -ServicePrincipal
    
    # --------------------------------------------------------------------
    # ------ END - REMOVE THIS IF NOT USING A SERVICE Principal ----------
    # --------------------------------------------------------------------

    # Create a new storage account to store the exports in
    # https://docs.microsoft.com/en-us/powershell/module/az.storage/New-azStorageAccount
    
    # **********************************************
    # IMPORTANT - CHANGE THE SKU BASED ON YOUR NEEDS
    # **********************************************
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Region -SkuName Standard_GRS

    Write-Output "New Storage Account Created"

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
            & ./NewExport.ps1 -Tenant $Tenant -Subscription $subscriptions[$i] -StartDate $startDate -EndDate $endDate -ExportName $name -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -ContainerName $ContainerName -Region $Region -StartImmediately $True
            
            # Send something out to the console to see whats going on
            $statusText = "Created Export for " + $subscriptions[$i] + " " + $startDate + " " + $endDate
            Write-Output $statusText
        }
    }
}