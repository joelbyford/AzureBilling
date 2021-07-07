param([string]$Tenant, [string]$Subscription, [string]$SvcPrincipleName, [string]$SvcPrinciplePass, [datetime]$StartDate, [datetime]$EndDate)

# Convert the service principle password to a Secure String
# and create a Credential object with the Service Princple information for use in connecting to Azure
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential
$Password = ConvertTo-SecureString -String $SvcPrinciplePass -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SvcPrincipleName, $Password

# Connect to Azure
# https://docs.microsoft.com/en-us/powershell/module/az.accounts/Connect-AzAccount
Connect-AzAccount -Tenant $Tenant -Subscription $Subscription -Credential $Credential -ServicePrincipal

# Get the Hourly Usage for specified period of time
# https://docs.microsoft.com/en-us/powershell/module/az.billing/get-usageaggregates
Get-UsageAggregates -ReportedStartTime $StartDate -ReportedEndTime $EndDate -AggregationGranularity 'Hourly' | Out-File -FilePath .\Usage.txt

# Clean up the output to make it readable as a tab-delimited file
# Need to skip the first 2 rows as it has an extra 'Usage:' row we don't want
# Save results to a file like 'yyyy-mm-dd-usage.txt'
$filename = '.\' + $StartDate.Year + '-' + $StartDate.Month + '-' + $StartDate.Day + '-usage.txt'
(Get-Content Usage.txt).trim() | Select-Object -Skip 2 | Out-File -FilePath $filename
