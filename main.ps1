Import-Module -Name "Az.Cleanup-Custom"
 
# Logging into Azure account
Disable-AzContextAutosave | Out-Null
Connect-AzAccount -Identity | Out-Null
$subId = (Get-AzSubscription).Id
$subName = "{Subscription Name to be included in email}"
 
$mainBody = "<h1>Hello,</h1>"
$subject = $subName + " Cleanup Report"
 
$unattachedDisksBody, $unattachedDisksLogFile = Get-UnattachedDisks -subName $subName
$powerdOffVMsBody, $poweredOffVMsLogFile = Get-PoweredOffVMs -subName $subName -subId $subId
$emptyAvailBody, $emptyAvailLogFile = Get-EmptyAvailSets -subName $subName
$emptyRgBody, $emptyRgLogFile = Get-EmptyRgs -subName $subName
$planNoAppBody, $planNoAppLogFile = Get-NoAppPlans -subName $subName
$nsgNoNicBody, $nsgNoNicLogFile = Get-NoNicNsgs -subName $subName
$vnetNoDevBody, $vnetNoDevLogFile = Get-NoDeviceVnets -subName $subName
$pubIpNotAssociatedBody, $pubIpNotAssociatedLogFile = Get-NotAssociatedPubIps -subName $subName
$nicBody, $nicLogFile = Get-UnattachedNic -subName $subName
 
$body = ""
$body = $mainBody + $unattachedDisksBody + $powerdOffVMsBody + $emptyAvailBody + $emptyRgBody + $planNoAppBody + $nsgNoNicBody + $vnetNoDevBody + $pubIpNotAssociatedBody + $nicBody
 
$attachmentArr = @(
    $unattachedDisksLogFile,
    $poweredOffVMsLogFile,
    $emptyAvailLogFile,
    $emptyRgLogFile,
    $planNoAppLogFile,
    $nsgNoNicLogFile,
    $vnetNoDevLogFile,
    $pubIpNotAssociatedLogFile,
    $nicLogFile
)
 
$filesToSend  = New-Object System.Collections.ArrayList
 
foreach ($file in $attachmentArr) {
    if ($null -ne $file) {
        $filesToSend.Add($file) | Out-Null
    }
}
 
$css = Get-CSS
$postContent = "<p id='CreationDate'>Creation Date: $(Get-Date -Format "MM/dd/yyyy hh:mm tt")</p>"
$body = $css + $body + $postContent
 
# Mailbox credentials
$keyVaultSecret = Get-AzKeyVaultSecret -VaultName "{KeyVault Name}" -Name "{Secret Name}" -AsPlainText
 
#Send email notification
$azureAccountName ="{email}@{email}.com"
$azurePassword = ConvertTo-SecureString $keyVaultSecret -AsPlainText -Force
 
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)
 
Send-MailMessage -To '{email}@{email}.com' -Subject $subject -Body $body -Attachments $filesToSend -UseSsl -Port {Port} -SmtpServer 'smtp.{SMTP Server}.com' -From $azureAccountName -BodyAsHtml -Credential $psCred
 
# Delete Files Created (May be useful if testing or running on-prem)
# foreach ($file in $attachmentArr) {
#     if ($null -ne $file) {
#         Remove-Item -Path $file -Force
#     }
# }