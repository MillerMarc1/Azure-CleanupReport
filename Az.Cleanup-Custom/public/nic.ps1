<#
.SYNOPSIS
    Get-UnattachedNic returns NICs that are not attached.
 
.DESCRIPTION
    The function Get-UnattachedNic is part of the Az.Cleanup-Custom PS module. This function searches NICs within a subscription and returns all NICs that are not attached to anything.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-UnattachedNic-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-UnattachedNic -subName "MySub".
 
.OUTPUTS
    The function Get-UnattachedNic returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-UnattachedNic {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-UnattachedNic-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "UnattachedNics"
    $col1 = New-Object System.Data.DataColumn Name
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn Location
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
 
    $nics = Get-AzNetworkInterface | Where-Object {$null -eq $_.VirtualMachine}
    $total = $nics.Count
 
    foreach ($nic in $nics) {
        $name = $nic.Name
        $rgName = $nic.ResourceGroupName
        $location = $nic.Location
       
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
        $body = "<br/><h2>There are no Unattached NICs.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>Location</th>', '<th class="ColName">Location</th>'
 
        $body = "<br/><h2>Unattached NICs:</h2><h3>Total: $total</h3>" + $html
    }
 
    return $body, $logFile
}