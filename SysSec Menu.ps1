#secdevlocal@vsphere.local:tallclub25


function Show-Menu {
    param (
        [string]$Title = 'SysSec Homework Autograder'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "================ Made by Griffin Refol ====================="
    
    Write-Host "Homework 1: Press '1' for this option."
    Write-Host "Homework 2: Press '2' for this option."
    Write-Host "Homework 2: Press '3' for this option."
    Write-Host "Q: Press 'Q' to quit."
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
      '1' {
    .\SysSecHomework1.ps1
    } '2' {
    .\SysSec Homework 2.ps1
    } '3' {
    .\SysSec Homework 3.ps1
    }
    }
    if ($selection -ne 'Q') {
        pause
    }
 }
 until ($selection -eq 'Q')
