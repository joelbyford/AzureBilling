# AzureBilling
An **UNOFFICIAL** repo with scripts to help simplify gathering Historical Azure billing data.  This includes two major pieces:

## Part 1 - Generates All Exports
The `QtrExport.ps1` file takes and dynamically creates new quarterly exports for each subscription in a comma separated subscriptions file.  

## Part 2 - Download All Exports
Additionally, the `DownloadAll.ps1` file allows for looping through all the exports created  

## Optional - Validate All Exports
A script to simply validate that at least one export for each subscription has been created and run is provided  in the `ValidateExports.ps1` file. 

---------

## Pre-Requisites
### **Option 1** - Use GitHub Codespace which is pre-configured with all of the powershell modules and prerequisites.
### **Option 2** - Configure on your own machine.
- **PowerShell AZ Module** - Must have the PowerShell AZ module installed.  Please see the [Microsoft Docs](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps) on how to install this.  
- **Install the Az.CostManagement Module** Install this by calling simply calling `Install-Module Az.CostManagement` from the PowerShell prompt.

### Using Service Principal
The repo is built assuming the usage of a Service Principal.  If using that service Principal, the following are required as well:
- **Service Principal** - Create a service Principal with contributor role in any subscription where the export is being created.  See the following to learn how to create Service Principals: https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
- **Contributor Role** - Creating exports currently requires subscription-level contributor rights.  

### Using existing Login Context
Alternatively, you may modify the scripts to instead use current logged in context instead of using a service Principal. Simply login using `Connect-AzAccount` before calling the script and remove/comment out everything in the `*.ps1` between:
```
# ------ START - REMOVE THIS IF NOT USING A SERVICE Principal ----------
and
# ------ END - REMOVE THIS IF NOT USING A SERVICE Principal ----------
```
----------
## Step 1 - Usage for Quarterly Report
Simply make a call to the `QtrExport.ps1` file with the following parameters:
- `Tenant` - The Azure Tenant ID
- `SubsFile` - A Comma delimited list of subscriptions (see `subs.data` as an example).
- `SvcPrincipalName` - The Service Principal with AT LEAST CONTRIBUTOR rights to allow calling the script.
- `SvcPrincipalPass` - The "secret" generated for the Service Principal.
- `StartYear` - The first year for the export.
- `NumYears` - The number of years to generate an export for (e.g. 2 years with the start date as 2018 would yield 2018 & 2019 exports).
- `ExportName` - The prefix for the exported files that will be combined with the year and quarter number (e.g. `MyExports` will result in exports named `MyExport-2018-1` for the first quarter of 2018).
- `StorageAccountName` - The NEW storage account where the export will be stored.  
- `ResourceGroupName` - The EXISTING resource group where the storage account resides.
- `ContainerName` - The NEW or EXISTING Blob container in which the exports will be placed.

### Example Quarterly Export Call
```
./QtrExport.ps1 -Tenant xxxx-xxx-xxxxxxxx -SubsFile subs.data -SvcPrincipalName yyy-yyyyy-yyyy -SvcPrincipalPass SomeSecretStringGoesHere -StartYear 2018 -NumYears 2 -ExportName "QtrlyExport" -StorageAccountName "exports" -ResourceGroupName "rgExports" -ContainerName "exports" -Region westus
```
----------

## Step 2 - Usage for Downloading All Reports from All Subscriptions (call after the above)
Simply call the `DownloadAll.ps1` file with the following parameters:
- `Tenant` - The Tenant where the service principal exists
- `SvcPrincipalName` - The ClientID of the service principal
- `SvcPrincipalPass` - The Secret generated for the Service Principal
- `StorageAccountName` - The name of the Storage Account created in each subscription when the QtrExport.ps1 was first called.
- `ResourceGroupName` - The Resource Group where the Storage Account is located in each subscription when the QtrExport.ps1 was first called.
- `ContainerName` - The Blob container where the exports were sent when the QtrExport.ps1 was previously called.
- `SubsFile` - The comma separated file where all subscriptions are listed.
- `DestinationPath` - The destination on your local computer where the .csv files will be downloaded.

### Example Download All Reports Call
```
./DowloadAll.ps1 -Tenant xxxx-xxx-xxxxxxxx -SubsFile subs.data -SvcPrincipalName yyy-yyyyy-yyyy -SvcPrincipalPass SomeSecretStringGoesHere -StorageAccountName "exports" -ResourceGroupName "rgExports" -ContainerName "exports" -DestinationPath "c:/temp"
```
-------

## Optional - Validating Reports Run from Subscription List (call after the QtrExport.ps1)
Simply call the `ValidateExports.ps1` file with the following parameters:
- `Tenant` - The Tenant where the service principal exists
- `SvcPrincipalName` - The ClientID of the service principal
- `SvcPrincipalPass` - The Secret generated for the Service Principal
- `SubsFile` - The comma separated file where all subscriptions are listed.
- `ExportName` - The prefix for the exported files that was be combined with the year and quarter number (e.g. `MyExports` called in the QtrExport.ps1 file resulted in exports named `MyExport-2018-1` for the first quarter of 2018).

### Example Download All Reports Call
```
./ValidateExports.ps1 -Tenant xxxx-xxx-xxxxxxxx -SubsFile subs.data -SvcPrincipalName yyy-yyyyy-yyyy -SvcPrincipalPass SomeSecretStringGoesHere -ExportName QtrRpt
```
-----------

# IMPORTANT - Quarterly Report CLEANUP
Please remember to **REMOVE CONTRIBUTOR ROLE** from the service Principal created for this export after the script has been successfully run.