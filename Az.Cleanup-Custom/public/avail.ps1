<#
.SYNOPSIS
    Get-EmptyAvailSets returns Availability Sets that have no Virtual Machines.
 
.DESCRIPTION
    The function Get-EmptyAvailSets is part of the Az.Cleanup-Custom PS module. This function searches availability sets within a subscription and returns all availability sets that have no VMs.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-EmptyAvailabilitySet-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-EmptyAvailSets -subName "MySub".
 
.OUTPUTS
    The function Get-EmptyAvailSets returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-EmptyAvailSets {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-EmptyAvailabilitySet-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "EmptyAvailabilitySet"
    $col1 = New-Object System.Data.DataColumn Name
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn Location
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
 
    $availSets = Get-AzAvailabilitySet | Where-Object {$_.VirtualMachinesReferences.Count -eq 0}
    $total = $availSets.Count
   
    foreach ($availSet in $availSets) {
        $name = $availSet.Name
        $rgName = $availSet.ResourceGroupName
        $location = $availSet.Location
       
        #Add metrics to table
        $row = $table.NewRow()
        $row.Name = $name
        $row.ResourceGroupName = $rgName
        $row.Location = $location
        $table.Rows.Add($row)
    }
   
    $table | Export-Csv -path $logFile -NoTypeInformation
 
    # Creates HTML code
    $html = ""
    $html += $table | ConvertTo-Html -Property Name,ResourceGroupName,Location -Fragment
 
    if ($total -eq 0) {
        $body = "<br/><h2>There are no empty availability sets.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>Location</th>', '<th class="ColName">Location</th>'
       
        $body = "<br/><h2>Empty availability sets:</h2><h3>Total empty A.S.: $total</h3>" + $html
    }
 
    return $body, $logFile
}    