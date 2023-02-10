Clear-Host
$vSphereUser = Read-Host "vSphere Username"
$vSpherePass = Read-Host "vSphere Password" -AsSecureString

Connect-VIServer cdr-vcenter.cse.buffalo.edu -User $vSphereUser -Password $vSpherePass
Clear-Host
write-host("Grading Homework 1... This might take a while.")
$startTime = Get-Date
$ProgressPreference = 'SilentlyContinue'
 
function InvokeScript {
    param(
        $SourceDevice,
        $Script,
        $Username,
        $Passwd
        )
    for ($i = 1; $i -le 24; $i++) {
        if ($i -lt 10) {
            $teamNumber = "0$i"
        } else {
            $teamNumber = $i
        }
        $VM = Get-Folder "SysSec" | Get-Folder "Team_$teamNumber" | Get-VM $SourceDevice
        if ($VM.PowerState -eq "PoweredOff") {
            Start-VM -VM $VM
            Write-Host "Powering on Team_$teamNumber $SourceDevice"
        }
        return Invoke-VMScript -ScriptText $Script -GuestPassword $Passwd -GuestUser $Username -VM $VM
        }
    }

function CheckState {
    param(
        $SourceDevice,
        $Script,
        $Username,
        $Passwd,
        $TestName,
        $TestExpectedResult,
        $AdditionalPoints
        )
    $data = @()
    for ($i = 1; $i -le 24; $i++) {
        $ScriptResult = InvokeScript -SourceDevice $SourceDevice -Script $Script -Username $Username -Passwd $Passwd
        $points = 0
        if ($ScriptResult -match $TestExpectedResult) {
            $points += $AdditionalPoints
            Write-Output "$TestName successful for Team $i $SourceDevice"
        } else {
            Write-Output "$TestName unsuccessful for Team $i $SourceDevice"
        }
        $data += [pscustomobject]@{
            Team = $i
            Points = $points
        }
    }
}

CheckState -SourceDevice "Win10Client" -Script "(Test-Connection 8.8.8.8 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging 8.8.8.8" -TestExpectedResult "0" -AdditionalPoints 5

CheckState -SourceDevice "Win10Client" -Script "(Test-Connection dns.google -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging dns.google" -TestExpectedResult "0" -AdditionalPoints 5

#CheckState -SourceDevice "UbuntuClient" -Script "ping -c 1 8.8.8.8 &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging 8.8.8.8" -TestExpectedResult "True" -AdditionalPoints 5
    
#CheckState -SourceDevice "UbuntuClient" -Script "ping -c 1 dns.google &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging dns.google" -TestExpectedResult "True" -AdditionalPoints 5

$data | Export-Csv -Path 'Homework1_Grades.csv' -NoTypeInformation
Write-Host("Grading Homework 1 Complete!")
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "This grading took: $($elapsedTime.TotalSeconds) seconds to run"