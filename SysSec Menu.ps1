$menuOptions = @("Homework 1", "Homework 2", "Homework 3", "Quit")
$selectedIndex = 0

Clear-Host
Write-Host "================ SysSec Homework Autograder ================"
Write-Host "================ Made by Griffin Refol ====================="
while ($selectedIndex -ne ($menuOptions.Count - 1)) {
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        if ($i -eq $selectedIndex) {
            Write-Host("--> $($menuOptions[$i])")
        } else {
            Write-Host("  $($menuOptions[$i])")
        }
    }

    $key = [Console]::ReadKey().Key
    switch ($key) {
        'DownArrow' {
            Clear-Host
            Write-Host "================ SysSec Homework Autograder ================"
            Write-Host "================ Made by Griffin Refol ====================="
            if ($selectedIndex -lt ($menuOptions.Count - 1)) {
                $selectedIndex++
            }
        }
        'UpArrow' {
            Clear-Host
            Write-Host "================ SysSec Homework Autograder ================"
            Write-Host "================ Made by Griffin Refol ====================="
            if ($selectedIndex -gt 0) {
                $selectedIndex--
            }
        }
        'Enter' {
            break
        }
    }

    if ($key -eq 'Enter') {
        break
    }
}

switch ($menuOptions[$selectedIndex]) {
    "Homework 1" {
        .\SysSecHomework1.ps1
    }
    "Homework 2" {
        .\SysSecHomework2.ps1
    }
    "Homework 3" {
        .\SysSecHomework3.ps1
    }
    "Quit" {
        Write-Host("Exiting...")
    }
}
