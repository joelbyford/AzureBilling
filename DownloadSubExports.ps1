param([string]$Tenant, [string]$Subscription, [string]$SvcPrincipalName, [string]$SvcPrincipalPass, [string]$ResourceGroupName, [string]$StorageAccountName, [string]$ContainerName, [string]$DestinationPath)
# *************************************************
# Download all export blobs from a single subscription
# *************************************************
# * PLEASE SEE DownloadAll.ps1 for the main loop. *
# *************************************************

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
Connect-AzAccount -Tenant $Tenant -Subscription $Subscription -Credential $Credential -ServicePrincipal

# --------------------------------------------------------------------
# ------ END - REMOVE THIS IF NOT USING A SERVICE Principal ----------
# --------------------------------------------------------------------

# Get the storage account keys from the given storage account (authenticated by the context of the logged in user)
# https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageaccountkey
$UniqueSaName = ($StorageAccountName + $subscriptions[$i].Substring(0,4)).ToLower()
$UniqueRgName = $ResourceGroupName + $subscriptions[$i].Substring(0,4)
$SaKeys = (Get-AzStorageAccountKey -ResourceGroupName $UniqueRgName -AccountName $UniqueSaName).Value

# Get the context to the right Storage Account
# https://docs.microsoft.com/en-us/powershell/module/az.storage/new-azstoragecontext
$Context = New-AzStorageContext -StorageAccountName $UniqueSaName -StorageAccountKey $SaKeys[0]

# Get a list of the blobs in the container
# https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageblob
$Blobs = Get-AzStorageBlob -Container $ContainerName -Context $Context

# Loop through each blob in the container
foreach ($Blob in $Blobs) {
    # Save/Download them locally
    # https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageblobcontent
    Get-AzStorageBlobContent -Container $ContainerName -Blob $Blob.Name -Destination $DestinationPath -Context $Context
}
