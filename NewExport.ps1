param([string]$Tenant, [string]$Subscription, [string]$SvcPrincipalName, [string]$SvcPrincipalPass, [datetime]$StartDate, [datetime]$EndDate, [string]$ExportName, [string]$StorageAccountName, [string]$ResourceGroupName, [string]$ContainerName, [Boolean]$StartImmediately)
# ***************************IMPORTANT*****************************************
# Service Principal needs to have `Contributor` role.
# Must Install the Az.CostManagement module (Install-Module Az.CostManagement).
# *****************************************************************************

# ------ START - REMOVE THIS IF NOT USING A SERVICE Principal ----------
# Convert the service Principal password to a Secure String
# and create a Credential object with the Service Princple information for use in connecting to Azure
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential
$Password = ConvertTo-SecureString -String $SvcPrincipalPass -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SvcPrincipalName, $Password

# Connect to Azure
# https://docs.microsoft.com/en-us/powershell/module/az.accounts/Connect-AzAccount
Connect-AzAccount -Tenant $Tenant -Subscription $Subscription -Credential $Credential -ServicePrincipal
# ------ END - REMOVE THIS IF NOT USING A SERVICE Principal ----------

# Create a new export
# https://docs.microsoft.com/en-us/powershell/module/az.costmanagement/new-azcostmanagementexport?view=azps-6.4.0

New-AzCostManagementExport -Scope "subscriptions/$($Subscription)" `
-Name $ExportName `
-DefinitionTimeframe "Custom" `
-TimePeriodFrom $StartDate `
-TimePeriodTo $EndDate `
-Format "Csv" `
-DestinationResourceId "/subscriptions/$($Subscription)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Storage/storageAccounts/$($StorageAccountName)" `
-DestinationContainer $ContainerName `
-DestinationRootFolderPath "ad-hoc" `
-DefinitionType "Usage" `
-DatasetGranularity "Daily"

Write-Output "Export Created!"

if ($StartImmediately) {
    # Get the bearer token
    $context= Get-AzContext

    $token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account,
    $context.Environment, 
    $context.Tenant.Id.ToString(), 
    $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null).AccessToken

    # Call the REST API
    # https://docs.microsoft.com/en-us/rest/api/cost-management/exports/execute
    $headers=@{
        "Authorization"= "Bearer " + $token;
        }

    $url="https://management.azure.com/subscriptions/$($Subscription)/providers/Microsoft.CostManagement/exports/$($ExportName)/run?api-version=2020-06-01"

    $result=Invoke-RestMethod -Method Post -Uri $url -Headers $headers -ContentType "application/json" -UseBasicParsing
    Write-Output "Export Started!"
    Write-Output $result

}
