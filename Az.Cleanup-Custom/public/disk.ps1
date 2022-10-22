<#
.SYNOPSIS
    Get-UnattachedDisks returns disks that are in an unattached state.
 
.DESCRIPTION
    The function Get-UnattachedDisks is part of the Az.Cleanup-Custom PS module. This function searches disks within a subscription and returns all disks that are unattached.
 
.PARAMETER subName
    This parameter is used to name the .csv file returned by the function. For example $subName = "MySub" results in a csv file named "MySub-UnattachedDisks-DATE.csv".
 
.EXAMPLE
    $body, $logFile = Get-UnattachedDisks -subName "MySub".
 
.OUTPUTS
    The function Get-UnattachedDisks returns $body and $logFile. $body includes the HTML to be used in the email report and $logFile is the path of the csv file.
#>
 
function Get-UnattachedDisks {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory, Position=0)]
        [string] $subName  
    )
 
    #Get the date and report variable formatting
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = $subName + "-UnattachedDisks-" + $date + ".CSV"
 
    # $2DaysAgoTemp = (Get-Date).AddDays(-2)
    # $2DaysAgo = Get-Date($2DaysAgoTemp) -Format "yyyy-MM-dd"
 
    # $yesterdayTemp = (Get-Date).AddDays(-1)
    # $yesterday = Get-Date($yesterdayTemp) -Format "yyyy-MM-dd"
 
    #Create a table for CSV file
    $table = New-Object System.Data.DataTable "UnattachedDisks"
    $col1 = New-Object System.Data.DataColumn DiskName
    $col2 = New-Object System.Data.DataColumn ResourceGroupName
    $col3 = New-Object System.Data.DataColumn Sku
    $col4 = New-Object System.Data.DataColumn Size_GB
    $col5 = New-Object System.Data.DataColumn DateCreated
    $col6 = New-Object System.Data.DataColumn OwnerTag
    $col7 = New-Object System.Data.DataColumn VmTag
    # $col8 = New-Object System.Data.DataColumn Cost
    $col9 = New-Object System.Data.DataColumn State
    $table.Columns.Add($col1)
    $table.Columns.Add($col2)
    $table.Columns.Add($col3)
    $table.Columns.Add($col4)
    $table.Columns.Add($col5)
    $table.Columns.Add($col6)
    $table.Columns.Add($col7)
    # $table.Columns.Add($col8)
    $table.Columns.Add($col9)
 
    $disks = Get-AzDisk | Where-Object {$_.DiskState -eq "Unattached"}
    $total = $disks.Count
    $totalGB = 0
    # $totalCost = 0
 
    for ($i = 0; $i -lt $disks.Count; $i++) {
        $diskName = $disks[$i].Name
        $resourceGroupName = $disks[$i].ResourceGroupName
        $sku = $disks[$i].Sku.Name
        $size = $disks[$i].DiskSizeGB
        $state = $disks[$i].DiskState
        $dateCreated = $disks[$i].TimeCreated
        $ownerTag = $disks[$i].Tags['Owner']
        $VmTag = $disks[$i].Tags['VM_Name']
 
        # $cost = 0
        # try {
        #     Get-AzConsumptionUsageDetail -StartDate $2DaysAgo -EndDate $yesterday -ResourceGroup $resourceGroupName -InstanceName $diskName | Select-Object -Property PretaxCost | ForEach-Object { $cost += $_.PretaxCost }
        # } catch {
        #     Write-Error "Unable to retrieve disk costs."
        # }
 
        # $totalCost += $cost
        $totalGB += $size
 
        #Add metrics to table
        $row = $table.NewRow()
        $row.DiskName = $diskName
        $row.ResourceGroupName = $resourceGroupName
        $row.Sku = $sku
        $row.Size_GB = $size
        $row.DateCreated = $dateCreated
        $row.OwnerTag = $ownerTag
        $row.VmTag = $VmTag
        # $row.Cost = $cost
        $row.State = $state
        $table.Rows.Add($row)
    }
 
    $table | Export-Csv -path $logFile -NoTypeInformation
 
    # Creates HTML code
    $html = ""
    # $html += $table | ConvertTo-Html -Property DiskName,ResourceGroupName,Sku,Size_GB,DateCreated,OwnerTag,VmTag,Cost,State -Fragment
    $html += $table | ConvertTo-Html -Property DiskName,ResourceGroupName,Sku,Size_GB,DateCreated,OwnerTag,VmTag,State -Fragment
 
    if ($total -eq 0) {
        $body = "<br/><h2>There are no unattached disks.</h2>"
        $logFile = $null
    } else {
        $html = $html -replace '<th>DiskName</th>', '<th>Disk Name</th>'
        $html = $html -replace '<th>ResourceGroupName</th>', '<th class="ColName">Resource Group Name</th>'
        $html = $html -replace '<th>Sku</th>', '<th class="ColName">Sku</th>'
        $html = $html -replace '<th>Size_GB</th>', '<th class="ColName">Size (GB)</th>'
        $html = $html -replace '<th>DateCreated</th>', '<th class="ColName">Date Created</th>'
        $html = $html -replace '<th>OwnerTag</th>', '<th class="ColName">Owner Tag</th>'
        $html = $html -replace '<th>VmTag</th>', '<th class="ColName">VM Tag</th>'
        # $html = $html -replace '<th>Cost</th>', '<th class="ColName">Cost (Last 30 Days)</th>'
        $html = $html -replace '<th>State</th>', '<th class="ColName">State</th>'
 
        # $body = "<br/><h2>Unattached disks:</h2><h3>Total unattached disks: $total</h3><h3>Total GB: $totalGB</h3><h3>Total Cost: $totalCost</h3>" + $html
        $body = "<br/><h2>Unattached disks:</h2><h3>Total unattached disks: $total</h3><h3>Total GB: $totalGB</h3>" + $html
    }
 
    return $body, $logFile
}
