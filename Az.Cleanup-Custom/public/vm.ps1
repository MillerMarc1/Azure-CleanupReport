<#
.SYNOPSIS
    Get-PoweredOffVMs returns Virtual Machines that are not running.
 
.DESCRIPTION
    The function Get-PoweredOffVMs is part of the Az.Cleanup-Custom PS module. This function searches all Virtual Machines within a subscription and returns the VMs that are not running. This can include VMs that are stopped or deallocated.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-PoweredOffVMs-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-PoweredOffVMs -subName "MySub".
 
.OUTPUTS
    The function Get-PoweredOffVMs returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-PoweredOffVMs {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName ,
        [Parameter (Mandatory, Position=1)]
        [string] $subId  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-PoweredOffVMs-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "PoweredOffVMs"
    $col1 = New-Object System.Data.DataColumn Name
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn TimeCreated
    $col4 = New-Object System.Data.DataColumn Status
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
    $table.Columns.Add($col4)
 
    $token = (Get-AzAccessToken).Token
    $headers = @{Authorization="Bearer $token"}
 
    $vms = Get-AzVM
    $total = 0
    foreach ($vm in $vms) {
        try {
            $vmStatus = Get-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Status
 
            if (!($vmStatus.Statuses | Where-Object Code -Like "PowerState/running")) {
                $total++
                $name = $vmStatus.Name
                $rgName = $vmStatus.ResourceGroupName
                $status = $vmStatus.Statuses[1].Code
 
                $uri = "https://management.azure.com/subscriptions/" + $subId + "/resourceGroups/" + $rgName + "/providers/Microsoft.Compute/virtualMachines/" + $name + "?$expand=createdTime&api-version=2021-11-01"
 
                $response = Invoke-RestMethod -Uri $uri -Method 'GET' -Headers $headers
                $timeCreated = $response.properties.timeCreated
 
                #Add metrics to table
                $row = $table.NewRow()
                $row.Name = $name
                $row.ResourceGroupName = $rgName
                $row.TimeCreated = $timeCreated
                $row.Status = $status
                $table.Rows.Add($row)
            }            
        } catch {
            "The VM is currently being deleted"
        }
    }
 
    $table | Export-Csv -path $logFile -NoTypeInformation
 
    # Creates HTML code
    $html = ""
    $html += $table | ConvertTo-Html -Property Name,ResourceGroupName,TimeCreated,Status -Fragment
 
    if ($total -eq 0) {
        $body = "<br/><h2>There are no powered off VMs.</h2>"
        $logFile =$null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>TimeCreated</th>', '<th class="ColName">Time Created</th>'
        $html = $html -replace '<th>Status</th>', '<th class="ColName">Status</th>'
 
        $html = $html -replace '<td>PowerState/stopped</td>', '<th class="StoppedVM">PowerState/stopped</th>'
 
        $body = "<br/><h2>Powered off VMs:</h2><h3>Total powered off VMs: $total</h3>" + $html
    }
 
    return $body, $logFile
}