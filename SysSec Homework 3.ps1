

function TestPing { ## This function is designed to ping the $TargetIP from the $TargetVM using the local credentials.
    param(
        $TargetIP,
        $SourceDevice,
        $Username,
        $Passwd
        )
    for ($i = 30; $i -le 30; $i++) {
        if ($i -lt 10) {
            $teamNumber = "0$i"
        } else {
            $teamNumber = $i
        }
        $result = Get-Folder "SysSec" | Get-Folder "Team_$teamNumber" | Get-VM $SourceDevice | Invoke-VMScript -ScriptText "(Test-Connection $TargetIP -Count 1).StatusCode" -GuestPassword $Passwd -GuestUser $Username ##Add looping through the SysSec folder later
    }
    return $result
}
function TestWebProtocol { ##This function is designed to test different web protocols. You set the $TargetIP, $SourceDevice, $Port, $Username, and $Passswd. $TargetIP is the IP you're running the test aganist. $SourceDevice is the device that is running the scripts. $Port is the protocol you want to test. $Username and $Passwd are the credentials to the $SourceDevice.
    param(
        $TargetIP,
        $SourceDevice,
        $Port,
        $Username,
        $Passwd
        )
    for ($i = 29; $i -le 29; $i++) { ##This loop is for targeting the correct team numbers in vSphere. You can change the integer to adjust for how many teams.
        if ($i -lt 10) {
            $teamNumber = "0$i" ##This is done for formatting, because the team numbers in vSphere are formatted "Team_01"
        } else {
            $teamNumber = $i
        }
        $result = Get-Folder "SysSec" | Get-Folder "Team_$teamNumber" | Get-VM $SourceDevice | Invoke-VMScript -ScriptText "(Test-NetConnection $TargetIP -Port $Port).TcpTestSucceeded" -GuestPassword $Passwd -GuestUser $Username ## This script portion of this command is what is executed on the $SourceDevice. It sends traffic to the $TargetIP on $Port, and reports if connection was successful. 
    }
    return $result
}

#Test ping from Win10Client to 8.8.8.8
for ($i = 29; $i -le 29; $i++) {
    $pingResult = TestPing -TargetIP "8.8.8.8" -SourceDevice "Win10Client" -Username "sysadmin" -Passwd "Change.me!"
    if ($pingResult -match '0'){
        Write-Output "PING Connection Successful for Team $i"
    }
    else{
        Write-Output "PING Connection Unsuccessful for Team $i"
    }
}

#Test ping from OutsideDevice to UbuntuClient
for ($i = 29; $i -le 29; $i++) {
    $pingResult = TestPing -TargetIP "10.43.$i.12" -SourceDevice "OutsideDevice" -Username "sysadmin" -Passwd "Change.me!"
    if ($pingResult -match '0'){
        Write-Output "PING Connection Successful for Team $i"
    }
    else{
        Write-Output "PING Connection Unsuccessful for Team $i"
    }
}
#Test HTTP for Win10Client
for ($i = 29; $i -le 29; $i++) {
   $httpResult = TestWebProtocol -TargetIP "www.go.com" -SourceDevice "Win10Client" -Port "80" -Username "sysadmin" -Passwd "Change.me!"
   if ($httpResult -match 'True'){
       Write-Output "HTTP Connection Successful for Team $i"
   }
   else{
       Write-Output "HTTP Connection Unsuccessful for Team $i"
   }
}

#Test HTTPS for Win10Client
for ($i = 29; $i -le 29; $i++) {
    $httpsResult = TestWebProtocol -TargetIP "www.ftx.com" -SourceDevice "Win10Client" -Port "443" -Username "sysadmin" -Passwd "Change.me!"
    Write-Host($httpsResult)
    if ($httpsResult -match 'True'){
        Write-Output "HTTPS Connection Successful for Team $i"
    }
    else{
        Write-Output "HTTPS Connection Unsuccessful for Team $i"
    }
}


#Test FTP for Win10Client
for ($i = 29; $i -le 29; $i++) {
    $ftpResult = TestWebProtocol -TargetIP "bks4-speedtest-1.tele2.net" -SourceDevice "Win10Client" -Port "21" -Username "sysadmin" -Passwd "Change.me!"
    if ($ftpResult -match 'True'){
        Write-Output "FTP Connection Successful for Team $i"
    }
    else{
        Write-Output "FTP Connection Unsuccessful for Team $i"
    }
}

#Test RDP into Win10Client from OutsideDevice
for ($i = 29; $i -le 29; $i++) {
    $rdpResult = TestWebProtocol -TargetIP "10.42.$i.12" -SourceDevice "OutsideDevice" -Port "3389" -Username "sysadmin" -Passwd "Change.me!"
    if ($rdpResult -match 'True'){
        Write-Output "RDP Connection Successful for Team $i"
    }
    else{
        Write-Output "RDP Connection Unsuccessful for Team $i"
    }
}

#Test SSH into UbuntuClient from OutsideDevice
for ($i = 29; $i -le 29; $i++) {
    $sshResult = TestWebProtocol -TargetIP "10.43.$i.7" -SourceDevice "OutsideDevice" -Port "22" -Username "sysadmin" -Passwd "Change.me!"
    if ($sshResult -match 'True'){
        Write-Output "SSH Connection Successful for Team $i"
    }
    else{
        Write-Output "SSH Connection Unsuccessful for Team $i"
    }
}

#Test WinRM into Win10Client from OutsideDevice
for ($i = 29; $i -le 29; $i++) {
    $winrmResult = TestWebProtocol -TargetIP "10.42.$i.12" -SourceDevice "OutsideDevice" -Port "5985" -Username "sysadmin" -Passwd "Change.me!"
    if ($winrmResult -match 'True'){
        Write-Output "WinRM Connection Successful for Team $i"
    }
    else{
        Write-Output "WinRM Connection Unsuccessful for Team $i"
    }
}

