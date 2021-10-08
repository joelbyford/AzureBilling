param([string]$Tenant, [string]$Subscription, [string]$SvcPrincipalName, [string]$SvcPrincipalPass, [string]$BillingPeriodName)

# Convert the service Principal password to a Secure String
# and create a Credential object with the Service Princple information for use in connecting to Azure
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential
$Password = ConvertTo-SecureString -String $SvcPrincipalPass -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SvcPrincipalName, $Password

# Connect to Azure
# https://docs.microsoft.com/en-us/powershell/module/az.accounts/Connect-AzAccount
Connect-AzAccount -Tenant $Tenant -Subscription $Subscription -Credential $Credential -ServicePrincipal

# Get the pricesheet for a specific date (e.g. 202106-1)
# https://docs.microsoft.com/en-us/powershell/module/az.billing/get-azconsumptionpricesheet
Get-AzConsumptionPriceSheet -BillingPeriodName $BillingPeriodName