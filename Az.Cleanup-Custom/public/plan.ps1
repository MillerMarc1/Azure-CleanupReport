<#
.SYNOPSIS
    Get-NoAppPlans returns App service plans with no apps.
 
.DESCRIPTION
    The function Get-NoAppPlans is part of the Az.Cleanup-Custom PS module. This function searches all App Service Plans witin the subscription and returns any App Service Plans that do not have any Apps.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-NotUsedAppServicePlan-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-NoAppPlans -subName "MySub".
 
.OUTPUTS
    The function Get-NoAppPlans returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-NoAppPlans {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-NotUsedAppServicePlan-" + $date + ".CSV"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "NoAppsInAppServicePlan"
    $col1 = New-Object System.Data.DataColumn Name
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn Kind
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
 
    $appServicePlans = Get-AzAppServicePlan | Where-Object {$_.NumberOfSites -eq 0}
    $total = $appServicePlans.Count
   
    foreach ($appServicePlan in $appServicePlans) {
        $name = $appServicePlan.Name
        $kind = $appServicePlan.Kind
        $id = $appServicePlan.Id
        $id = $id.substring($id.IndexOf('resourceGroups')+15)
        $rgName = $id.substring(0, $id.IndexOf('/'))
 
        # Add metrics to table
        $row = $table.NewRow()
        $row.Name = $name
        $row.ResourceGroupName = $rgName
        $row.Kind = $kind
        $table.Rows.Add($row)
    }
   
    $table | Export-Csv -path $logFile -NoTypeInformation
 
    # Creates HTML code
    $html = ""
    $html += $table | ConvertTo-Html -Property Name,ResourceGroupName,Kind -Fragment
 
    if ($total -eq 0) {
        $body = "<br/><h2>There are no App service plans without any apps.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>Kind</th>', '<th class="ColName">Kind</th>'
 
        $body = "<br/><h2>App service plans without any apps:</h2><h3>Total empty AS-plans: $total</h3>" + $html
    }
 
    return $body, $logFile
}