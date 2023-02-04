#$vSphereUser = Read-Host "vSphere Username"
#$vSpherePass = Read-Host "vSphere Password" -AsSecureString
Connect-VIServer cdr-vcenter.cse.buffalo.edu -User $vSphereUser -Password $vSpherePass
write-host("Running Homework 1 Script")
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
            Write-Host "Powered on Team $i $SourceDevice"
            while ($VM.PowerState -ne "PoweredOn") {
                Start-Sleep -Seconds 5
            }
        }
        $result = Invoke-VMScript -ScriptText $Script -GuestPassword $Passwd -GuestUser $Username -VM $VM
    }
    return $result
}


#Test ping to 8.8.8.8  on Win10Client
for ($i = 1; $i -le 24; $i++) {
    Team$iPoints = 0
    Write-host("Testing Ping to 8.8.8.8 on Team $i Win10Client")
    $Win10_Ping8 = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection 8.8.8.8 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    if  ($Win10_Ping8 -match '0'){
        Team($i)Points += 10
    }
    #Test ping to dns.google on Win10Client 
    Write-host("Testing Ping to dns.google on Team $i Win10Client")
    $Win10_PingGoogle = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection dns.google -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    if  ($Win10_PingGoogle -match '0'){
        Team($i)Points += 10
    }
    #Test ping tot 8.8.8.8 on UbuntuClient
    Write-host("Testing Ping to 8.8.8.8 on Team $i UbuntuClient")
    $Nix_Ping8 = InvokeScript -SourceDevice "UbuntuClient" -Script "$(ping -c 1 8.8.8.8)?" -Username "sysadmin" -Passwd "Change.me!"
    if  ($Nix_Ping8 -match '0'){
        Team($i)Points += 10
    }
    #Test ping to dns.google on UbuntuClient
    Write-host("Testing Ping to dns.google on Team $i UbuntuClient")
    $Nix_PingGoogle = InvokeScript -SourceDevice "UbuntuClient" -Script "$(ping -c 1 dns.google)?" -Username "sysadmin" -Passwd "Change.me!"
    if  ($Nix_PingGoogle -match '0'){
        Team($i)Points += 10
    }
    Write-Host(Team($i)Points)
}





