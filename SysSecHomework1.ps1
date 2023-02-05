Clear-Host
$vSphereUser = Read-Host "vSphere Username"
$vSpherePass = Read-Host "vSphere Password" -AsSecureString
Connect-VIServer cdr-vcenter.cse.buffalo.edu -User $vSphereUser -Password $vSpherePass
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

    $data = @()
#Test ping to 8.8.8.8  on Win10Client
for ($i = 1; $i -le 24; $i++) {
    $points = 0
    $Win10_Ping8 = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection 8.8.8.8 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    Write-host("Testing Ping to 8.8.8.8 on Team_$i Win10Client")
    if  ($Win10_Ping8 -match '0'){
        Write-host("Team_$i Win10Client ping to 8.8.8.8 successful")
        $points += 10
    }else{
        Write-host("Team_$i Win10Client ping to 8.8.8.8 unsucessful")
    }
    #Test ping to dns.google on Win10Client 
    
    $Win10_PingGoogle = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection dns.google -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    Write-host("Testing Ping to dns.google on Team_$i Win10Client")
    if  ($Win10_PingGoogle -match '0'){
        Write-host("Team $i Win10Client ping to dns.google successful")
        $points += 10
    }else{
        Write-host("Team $i Win10Client ping to dns.google unsuccessful")
    }
    #Test ping tot 8.8.8.8 on UbuntuClient
    $Nix_Ping8 = InvokeScript -SourceDevice "UbuntuClient" -Script "ping -c 1 8.8.8.8 &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!"
    Write-host("Testing Ping to 8.8.8.8 on Team_$i UbuntuClient")
    if  ($Nix_Ping8 -match 'True'){
        Write-host("Team $i UbuntuClient ping to 8.8.8.8 successful")
        $points += 10
    }else{
        Write-host("Team $i UbuntuClient ping to 8.8.8.8 unsuccessful")
    }
    #Test ping to dns.google on UbuntuClient
    $Nix_PingGoogle = InvokeScript -SourceDevice "UbuntuClient" -Script "ping -c 1 dns.google &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!"
    Write-host("Testing Ping to dns.google on Team_$i UbuntuClient")
    if  ($Nix_PingGoogle -match 'True'){
        $points += 10
        Write-host("Team $i UbuntuClient ping to dns.google successful")
    }else{
        Write-host("Team $i UbuntuClient ping to dns.google unsuccessful")
    }
    ##Should there be a check for installing updates on UbuntuClient?
    $data += [pscustomobject]@{
        Team = $i
        Points = $points
    }
}
    Write-Host("Grading Homework 1 Complete!")
    $endTime = Get-Date
    $elapsedTime = $endTime - $startTime
    Write-Host "This grading took: $($elapsedTime.TotalSeconds) seconds to run"
    $data | Export-Csv -Path 'Homework1_Grades.csv' -NoTypeInformation




