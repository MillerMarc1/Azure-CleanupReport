<#
.SYNOPSIS
    Get-NotAssociatedPubIps returns Public IPs that are not associated to anything.
 
.DESCRIPTION
    The function Get-NotAssociatedPubIps is part of the Az.Cleanup-Custom PS module. This function searches all Public IP addresses within a subscription and returns all Public IPs that do not have any resource associated with them.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-PublicIps-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-NotAssociatedPubIps -subName "MySub".
 
.OUTPUTS
    The function Get-NotAssociatedPubIps returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-NotAssociatedPubIps {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-PublicIPs-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "notUsedPublicIPs"
    $col1 = New-Object System.Data.DataColumn Name
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn Location
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
   
 
    # TODO: If a NAT gateway is associated with a public IP, it will be listed in this report
    # - Understand why -> differences between what is returned by API vs PS Commandlet
    # - Tool check for NAT Gatway -> use API?
   
    $pubIps = Get-AzPublicIpAddress | Where-Object {$null -eq $_.IpConfiguration}
    $total = $pubIps.Count
 
    foreach ($pubIp in $pubIps) {
        $name = $pubIp.Name
        $rgName = $pubIp.ResourceGroupName
        $location = $pubIp.Location
       
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
        $body = "<br/><h2>There are no Public IPs without any association.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>Location</th>', '<th class="ColName">Location</th>'
   
        $body = "<br/><h2>Public IPs with no association:</h2><h3>Total: $total </h3>" + $html
    }
 
    return $body, $logFile
}