param([string]$Tenant, [string]$Subscription, [string]$SvcPrincipleName, [string]$SvcPrinciplePass, [string]$BillingPeriodName)

# Convert the service principle password to a Secure String
# and create a Credential object with the Service Princple information for use in connecting to Azure
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential
$Password = ConvertTo-SecureString -String $SvcPrinciplePass -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SvcPrincipleName, $Password

# Connect to Azure
# https://docs.microsoft.com/en-us/powershell/module/az.accounts/Connect-AzAccount
Connect-AzAccount -Tenant $Tenant -Subscription $Subscription -Credential $Credential -ServicePrincipal

# Get the pricesheet for a specific date (e.g. 202106-1)
Get-AzConsumptionPriceSheet -BillingPeriodName $BillingPeriodName