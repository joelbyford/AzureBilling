param([string]$Tenant, [string]$SvcPrincipalName, [string]$SvcPrincipalPass, [string]$SubsFile, [string]$ExportName)

$subscriptions = Get-Content $SubsFile -Delimiter ","

# Loop through the subscriptoins
For ($i=0; $i -lt $subscriptions.Length; $i++)
{
    
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
    Connect-AzAccount -Tenant $Tenant -Subscription $subscriptions[$i] -Credential $Credential -ServicePrincipal

    # --------------------------------------------------------------------
    # ------ END - REMOVE THIS IF NOT USING A SERVICE Principal ----------
    # --------------------------------------------------------------------

    $scope = "subscriptions/" + $subscriptions[$i]
    $exports = Get-AzCostManagementExport -Scope $scope
    
    # Ensure at least one export exists per account
    $exportExists = $false

    Write-Output $subscriptions[$i]

    #Loop through the exports 
    foreach ($export in $exports) {
        #Extract the base name of the report
        $firstDashLoc = $export.Name.IndexOf("-")

        # if no dash is in the name, it's not our export, skip
        if ($firstDashLoc -ne -1) {

            $namePrefix = $export.Name.Substring(0,$firstDashLoc)
            
            # if the name doesn't match our export ExportName parameter, 
            # it's not our export, skip.
            if ($namePrefix -eq $ExportName) {
                # Found one
                $exportExists = $true

                # Output the subs name
                $subShortName = $subscriptions[$i].Substring(0,8) + "... - "
                Write-Host $subShortName -NoNewline
                # Output the report name
                Write-Host $export.Name -NoNewline 

                # verifty execution completed
                $executionHistory = Get-AzCostManagementExportExecutionHistory -ExportName $export.Name -Scope $scope
                
                # Loop through executions and verify at least one is completed
                $completed = $false
                foreach ($execution in $executionHistory) {
                    if ($execution.Status -eq "Completed") {
                        $completed = $true
                    }
                }

                if ($completed) {
                    Write-Host "Complete" -ForegroundColor Green -NoNewline
                } else {
                    Write-Host  "Incomplete" -ForegroundColor Red -NoNewline
                }

                # Line break
                Write-Output ""
            }
        }
       
        
        
    }

    # Check to ensure at least one export existed
    if ($exportExists -ne $true)
    {
        Write-Host "No Export Exists" -ForegroundColor Red
    }

}
