Clear-Host
$vSphereUser = Read-Host "vSphere Username"
$vSpherePass = Read-Host "vSphere Password" -AsSecureString

Connect-VIServer cdr-vcenter.cse.buffalo.edu -User $vSphereUser -Password $vSpherePass
Clear-Host
write-host("Grading Homework 1... This might take a while.")
$startTime = Get-Date
$ProgressPreference = 'SilentlyContinue'
 
function CheckState {
    param(
        $SourceDevice, ## device you are logging into
        $Script, ## script you want to run
        $Username, ## username for an account on $SourceDevice
        $Passwd, ## password for an account on $SourceDevice
        $TestName, ## name of what is being tested, for instance "Pinging 8.8.8.8 from Win10Client"
        $TestExpectedResult, ## the expected result of the script to determine successful system state
        $AdditionalPoints ## number of points you want test to be worth
    )

    $TeamPoints = @()
    for ($number = 1; $number -le 24; $number++) { ## change the upper bound number based on how many teams are being graded. 
        if ($number -lt 10) { ## done because format for numbers <10 are 01, 02, etc.
            $teamNumber = "0$number"
        }
        else {
            $teamNumber = $number
        }
        $VM = Get-Folder "SysSec" | Get-Folder "Team_$teamNumber" | Get-VM $SourceDevice
        if ($VM.PowerState -eq "PoweredOff") {## makes sure VMs are powered on before running scripts. NOTE: there is a bug where VMware tools will stop running if VM's go into hibernation. Fix in windwows power settings.
            Start-VM -VM $VM 
            Write-Host "Powering on Team_$teamNumber $SourceDevice"
            Wait-Tools -VM $VM
        }
        $points = 0

        $ScriptResult = Invoke-VMScript -ScriptText $Script -GuestPassword $Passwd -GuestUser $Username -VM $VM ## will return output from script that is run.
        if ($ScriptResult -match $TestExpectedResult) {
            Write-Host("$TestName successful for Team $number $SourceDevice")
            $points += $AdditionalPoints
        }
        else {
            Write-Host("$TestName unsuccessful for Team $number $SourceDevice")
        }
        $TeamPoints += [PSCustomObject]@{
            Team   = "Team $number"
            Points = $points
        }
    }
    return $TeamPoints
}



$WinPingDNS = CheckState -SourceDevice "Win10Client" -Script "(Test-Connection dns.google -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!" -TestName "Ping to dns.google" -TestExpectedResult "0" -AdditionalPoints 8
$WinPing8 = CheckState -SourceDevice "Win10Client" -Script "(Test-Connection 8.8.8.8 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!" -TestName "Ping to 8.8.8.8" -TestExpectedResult "0" -AdditionalPoints 8
$NixPing8 = CheckState -SourceDevice "UbuntuClient" -Script "ping -c 1 8.8.8.8 &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging 8.8.8.8" -TestExpectedResult "True" -AdditionalPoints 8
$NixPingDNS = CheckState -SourceDevice "UbuntuClient" -Script "ping -c 1 dns.google &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging dns.google" -TestExpectedResult "True" -AdditionalPoints 8
$NixUpdated = CheckState -SourceDevice "UbuntuClient" -Script "apt-get -s upgrade | grep -c '^Inst'" -Username "sysadmin" -Passwd "Change.me!" -TestName "Checking if system is upgraded" -TestExpectedResult "0" -AdditionalPoints  8
$results = $WinPingDNS + $WinPing8 + $NixPing8 + $NixPingDNS + $NixUpdated | Group-Object -Property Team | Select-Object -Property Name, @{n = 'Points'; e = { ($_.Group | Measure-Object -Property Points -Sum).Sum } }
$results | Export-Csv -Path "Results.csv" -NoTypeInformation
Write-Host("Grading Homework 1 Complete!")
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "This grading took: $($elapsedTime.TotalSeconds) seconds to run"