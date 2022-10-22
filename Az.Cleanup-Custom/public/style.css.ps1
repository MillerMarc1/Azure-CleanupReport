# Function that returns the css used by the email table
function Get-CSS {
    $css = @"
    h1 {
        font-family: Arial, Helvetica, sans-serif;
        color: #000000;
        font-size: 28px;
    }
 
    h2 {
        font-family: Arial, Helvetica, sans-serif;
        color: #000000;
        font-size: 18px;
    }
       
    table {
        font-size: 14px;
        border-width: 1px;
        border-style: solid;
        border-color: black;
        border-collapse: collapse;
        font-family: Arial, Helvetica, sans-serif;
    }
       
    td {
        padding: 3px;
        margin: 0px;
        border-style: solid;
        border-color: black;
        border-width: 1px;
    }
       
    th {
        background: #008AD7;
        font-size: 16px;
        text-transform: uppercase;
        padding: 3px;
        vertical-align: middle;
        border-style: solid;
        border-color: black;
        border-collapse: collapse;
        border-width: 1px;
    }
 
    #CreationDate {
        font-family: Arial, Helvetica, sans-serif;
        color: #008AD7;
        font-size: 12px;
    }
 
    .ColName {
        font-weight: bold;
    }
 
    .StoppedVM {
        color: red;
        background-color: white;
        font-size: 12px;
        font-weight: 400px;
        padding: 3px;
        margin: 0px;
        border-style: solid;
        border-color: black;
        border-width: 1px;
    }
"@
    $css = "<style>" + $css + "</style>"
 
    return $css
}