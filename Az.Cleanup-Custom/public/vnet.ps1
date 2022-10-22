<#
.SYNOPSIS
    Get-NoDeviceVnets returns Vnets that have no connected devices.
 
.DESCRIPTION
    The function Get-NoDeviceVnets is part of the Az.Cleanup-Custom PS module. This function searches subnets within each Vnet and returns all Vnets that have no connected devices.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-VnetNoDevices-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-NoDeviceVnets -subName "MySub".
 
.OUTPUTS
    The function Get-NoDeviceVnets returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-NoDeviceVnets {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-VnetNoDevices-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "VnetNoDevices"
    $col1 = New-Object System.Data.DataColumn Name
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn Location
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
   
    $vnets = Get-AzVirtualNetwork
    $total = 0
 
    foreach ($vnet in $vnets) {
        $name = $vnet.Name
        $rgName = $vnet.ResourceGroupName
        $location = $vnet.Location
 
        $vnetInfo = Get-AzVirtualNetwork -Name $name -ResourceGroupName $rgName -ExpandResource 'subnets/ipConfigurations'
        $connectedDevices = 0
   
        foreach ($subnet in $vnetInfo.Subnets) {
            $connectedDevices += $subnet.IpConfigurations.Count
        }
 
        if ($connectedDevices -eq 0) {
            $total++
           
            #Add metrics to table
            $row = $table.NewRow()
            $row.Name = $name
            $row.ResourceGroupName = $rgName
            $row.Location = $location
            $table.Rows.Add($row)
        }
    }
 
 
    $table | Export-Csv -path $logFile -NoTypeInformation
 
    # Creates HTML code
    $html = ""
    $html += $table | ConvertTo-Html -Property Name,ResourceGroupName,Location -Fragment
 
    if ($total -eq 0) {
        $body = "<br/><h2>There are no Vnets without any connected devices.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>Location</th>', '<th class="ColName">Location</th>'
 
        $body = "<br/><h2>Vnets without connected devices:</h2><h3>Total Vnets without any devices: $total</h3>" + $html
    }
 
    return $body, $logFile
}