param([string]$Tenant, [string]$Subscription, [string]$SvcPrincipleName, [string]$SvcPrinciplePass, [string]$ExportName)
# ***************************IMPORTANT******************************
# Service Principle needs to have `CostManagementContributor` role
# ******************************************************************


# Convert the service principle password to a Secure String
# and create a Credential object with the Service Princple information for use in connecting to Azure
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential
$Password = ConvertTo-SecureString -String $SvcPrinciplePass -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SvcPrincipleName, $Password

# Connect to Azure
# https://docs.microsoft.com/en-us/powershell/module/az.accounts/Connect-AzAccount
Connect-AzAccount -Tenant $Tenant -Subscription $Subscription -Credential $Credential -ServicePrincipal

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

Write-Output $result