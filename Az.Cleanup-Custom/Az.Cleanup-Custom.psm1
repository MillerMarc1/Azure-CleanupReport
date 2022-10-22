# Load functions contained within the public folder
Get-ChildItem "$PSScriptRoot\public" -ErrorAction Stop | ForEach-Object {
    . $_.FullName
}