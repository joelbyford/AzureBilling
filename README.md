# AzureBilling
An **UNOFFICIAL** repo with scripts to help simplify gathering Azure billing data.    

## Pre-Requisites
- **PowerShell AZ Module** - Must have the PowerShell AZ module installed.  Please see the [Microsoft Docs](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps) on how to install this.  
- **Install the Az.CostManagement Module** Install this by calling simply calling `Install-Module Az.CostManagement` from the PowerShell prompt.

### Using Service Principal
If using a service Principal, the following are required as well:
- **Service Principal** - Create a service Principal with contributor role in any subscription where the export is being created.  See the following to learn how to create Service Principals: https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
- **Contributor Role** - Creating exports currently requires subscription-level contributor rights.  

### Using existing Login Context
Alternatively, you may modify the scripts to instead use current logged in context instead of using a service Principal. Simply login using `Connect-AzAccount` before calling the script and remove/comment out everything in the `*.ps1` between:
```
# ------ START - REMOVE THIS IF NOT USING A SERVICE Principal ----------
and
# ------ END - REMOVE THIS IF NOT USING A SERVICE Principal ----------
```

## Usage for Quarterly Report
Simply make a call to the `QtrExport.ps1` file with the following parameters:
- `Tenant` - The Azure Tenant ID
- `SubsFile` - A Comma delimited list of subscriptions (see `subs.data` as an example).
- `SvcPrincipalName` - The Service Principal with AT LEAST CONTRIBUTOR rights to allow calling the script.
- `SvcPrincipalPass` - The "secret" generated for the Service Principal.
- `StartYear` - The first year for the export.
- `NumYears` - The number of years to generate an export for (e.g. 2 years with the start date as 2018 would yield 2018 & 2019 exports).
- `ExportName` - The prefix for the exported files that will be combined with the year and quarter number (e.g. `MyExports` will result in exports named `MyExport-2018-1` for the first quarter of 2018).
- `StorageAccountName` - The EXISTING storage account where the export will be stored.  
- `ResourceGroupName` - The EXISTING resource group where the storage account resides.
- `ContainerName` - The EXISTING Blob container in which the exports will be placed.

### Example Call
```
./QtrExport.ps1 -Tenant xxxx-xxx-xxxxxxxx -SubsFile subs.data -SvcPrincipalName yyy-yyyyy-yyyy -SvcPrincipalPass SomeSecretStringGoesHere -StartYear 2018 -NumYears 2 -ExportName "QtrlyExport" -StorageAccountName "byfordexports" -ResourceGroupName "rgDoNotDeleteDemos" -ContainerName "exports"
```

### IMPORTANT - Quarterly Report CLEANUP
Please remember to **REMOVE CONTRIBUTOR ROLE** from the service Principal created for this export after the script has been successfully run.