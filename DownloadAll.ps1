param([string]$Tenant, [string]$SvcPrincipalName, [string]$SvcPrincipalPass, [string]$StorageAccountName, [string]$ResourceGroupName, [string]$ContainerName, [string]$SubsFile, [string]$DestinationPath)
# Tenant             - The Tenant where the service principal exists
# SvcPrincipalName   - The ClientID of the service principal
# SvcPrincipalPass   - The Secret generated for the Service Principal
# StorageAccountName - The name of the Storage Account created in each subscription when the QtrExport.ps1 was first called.
# ResourceGroupName  - The Resource Group where the Storage Account is located in each subscription when the QtrExport.ps1 was first called.
# ContainerName      - The Blob container where the exports were sent when the QtrExport.ps1 was previously called.
# SubsFile           - The comma separated file where all subscriptions are listed.
# DestinationPath    - The destination on your local computer where the .csv files will be downloaded. 

$subscriptions = Get-Content $SubsFile -Delimiter ","
Write-Output $subscriptions

# Loop through the subscriptoins
For ($i=0; $i -lt $subscriptions.Length; $i++)
{
    # List out the sub
    Write-Output $subscriptions[$i]

    & ./DownloadSubExports.ps1 -Tenant $Tenant -Subscription $subscriptions[$i] -SvcPrincipalName $SvcPrincipalName -SvcPrincipalPass $SvcPrincipalPass -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ContainerName $ContainerName -DestinationPath $DestinationPath 
}