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

function TestConnection {
    param(
        $SourceDevice,
        $Script,
        $Username,
        $Passwd,
        $TestName,
        $TestExpectedResult,
        $additionalPoints
        )
    $data = @()
    for ($i = 1; $i -le 24; $i++) {
        $ScriptResult = InvokeScript -SourceDevice $SourceDevice -Script $Script -Username $Username -Passwd $Passwd
        points = 0
        if ($ScriptResult -match $TestExpectedResult) {
            points += $additionalPoints
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
    #Test DNS Settings for Win10Client
TestConnection -SourceDevice "Win10Client" -Script "Get-DnsClientServerAddress" -Username "sysadmin" -Passwd "Change.me!" -TestName "Correct DNS found" -TestExpectedResult "8.8.8.8, 8.8.4.4"

TestConnection -SourceDevice "Win10Client" -Script "Get-NetIPAddress | Where AddressFamily -eq 'IPv4' | Select-Object -ExpandProperty IPAddress" -Username "sysadmin" -Passwd "Change.me!" -TestName "Correct IP address found" -TestExpectedResult "10.42.*.12"
    
TestConnection -SourceDevice "Win10Client" -Script "(Test-Connection 10.42.$i.1 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!" -TestName "PING connection to gateway" -TestExpectedResult "0"
    
TestConnection -SourceDevice "Win10Client" -Script "(Test-Connection 192.168.254.254 -Count 1).StatusCode" -Us


Write-Host("Grading Homework 1 Complete!")
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "This grading took: $($elapsedTime.TotalSeconds) seconds to run"
$data | Export-Csv -Path 'Homework1_Grades.csv' -NoTypeInformation