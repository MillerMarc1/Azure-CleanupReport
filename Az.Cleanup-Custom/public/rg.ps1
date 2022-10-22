<#
.SYNOPSIS
    Get-EmptyRgs returns Resource Groups that do not have any resources in them.
 
.DESCRIPTION
    The function Get-EmptyRgs is part of the Az.Cleanup-Custom PS module. This function searches all Resource Groups within a subscription and returns the Resource Groups that do not have any Resources in them.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-EmptyRG-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-EmptyRgs -subName "MySub".
 
.OUTPUTS
    The function Get-EmptyRgs returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-EmptyRgs {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-EmptyRG-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "EmptyRG"
    $col1 = New-Object System.Data.DataColumn ResourceGroupName
    $col2 = New-Object System.Data.DataColumn Location
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
 
    $rgs = Get-AzResourceGroup
 
    $total = 0
    foreach ($rg in $rgs) {
        $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName
 
        if ($null -eq $resources) {
            $name = $rg.ResourceGroupName
            $location = $rg.Location
            $total++
           
            # Add metrics to table
            $row = $table.NewRow()
            $row.ResourceGroupName = $name
            $row.Location = $location
            $table.Rows.Add($row)
        }
    }
   
    $table | Export-Csv -path $logFile -NoTypeInformation
 
    # Creates HTML code
    $html = ""
    $html += $table | ConvertTo-Html -Property ResourceGroupName,Location -Fragment
 
    if ($total -eq 0) {
        $body = "<br/><h2>There are no Empty Resource Groups.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th>Resource Group Name</th>'
        $html = $html -replace '<th>Location</th>', '<th class="ColName">Location</th>'
 
        $body = "<br/><h2>Empty Resource Groups:</h2><h3>Total empty RGs: $total</h3>" + $html  
    }
 
    return $body, $logFile
}