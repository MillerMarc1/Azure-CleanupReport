<#
.SYNOPSIS
    Get-NoNicNsgs returns Network Security Groups that do not have any subnets or Network Interfaces associated with them.
 
.DESCRIPTION
    The function Get-NoNicNsgs is part of the Az.Cleanup-Custom PS module. This function searches Network Security Groups within a subscription and returns all Network Security Groups that do not have a subnet or a NIC associated with them.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-NSGsWithoutNIC-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-NoNicNsgs -subName "MySub".
 
.OUTPUTS
    The function Get-NoNicNsgs returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-NoNicNsgs {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-NSGsWithoutNIC-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "NSGsWithoutNIC"
    $col1 = New-Object System.Data.DataColumn Name
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn Location
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
 
    $nsgs = Get-AzNetworkSecurityGroup | Where-Object {("" -eq $_.NetworkInterfaces) -and ("" -eq $_.Subnets)}
    $total = $nsgs.Count
 
    foreach ($nsg in $nsgs) {
        $name = $nsg.Name
        $rgName = $nsg.ResourceGroupName
        $location = $nsg.Location
 
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
        $body = "<br/><h2>There are no Network Security Groups without any NICs or Subnets.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>Location</th>', '<th class="ColName">Location</th>'
 
        $body = "<br/><h2>Network Security Groups without any NICs or Subnets:</h2><h3>Total: $total</h3>" + $html
    }
 
    return $body, $logFile
}