function InvokeScript { ##This function is designed to test different web protocols. You set the $TargetIP, $SourceDevice, $Port, $Username, and $Passswd. $TargetIP is the IP you're running the test aganist. $SourceDevice is the device that is running the scripts. $Port is the protocol you want to test. $Username and $Passwd are the credentials to the $SourceDevice.
    param(
        $SourceDevice,
        $Script,
        $Username,
        $Passwd
        )
    for ($i = 29; $i -le 29; $i++) { ##This loop is for targeting the correct team numbers in vSphere. You can change the integer to adjust for how many teams.
        if ($i -lt 10) {
            $teamNumber = "0$i" ##This is done for formatting, because the team numbers in vSphere are formatted "Team_01"
        } else {
            $teamNumber = $i
        }
        $result = Get-Folder "SysSec" | Get-Folder "Team_$teamNumber" | Get-VM $SourceDevice | Invoke-VMScript -ScriptText $Script -GuestPassword $Passwd -GuestUser $Username  
    }
    return $result
}

#Test DNS Settings for Win10Client
for ($i = 29; $i -le 29; $i++) {
    $ScriptResult = InvokeScript -SourceDevice "Win10Client" -Script "Get-DnsClientServerAddress" -Username "sysadmin" -Passwd "Change.me!"
    if  ($ScriptResult -match "8.8.8.8, 8.8.4.4"){

        Write-Output "Correct DNS found for Team $i"
    } else {

        Write-Output "Incorrect DNS found for Team $i"

    }
}

#Test IP address for Win10Client
for ($i = 29; $i -le 29; $i++) {
    $ScriptResult = InvokeScript -SourceDevice "Win10Client" -Script "Get-NetIPAddress | Where AddressFamily -eq 'IPv4' | Select-Object -ExpandProperty IPAddress" -Username "sysadmin" -Passwd "Change.me!"
    if  ($ScriptResult -match "10.42.*.12"){

        Write-Output "Correct Win10Client IP found for Team $i"
    } else {

        Write-Output "Incorrect Win10Client IP found for Team $i"

    }
}

#Test ping to Win10Client gateway
for ($i = 29; $i -le 29; $i++) {
    $ScriptResult = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection 10.42.$i.1 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    if  ($ScriptResult -match '0'){

        Write-Output "PING Connection to gateway successful for Team $i"
    } else {

        Write-Output "PING Connection tp gateway unsccessful for Team $i"

    }
}

#Test ping to Win10Client enterprise gateway
for ($i = 29; $i -le 29; $i++) {
    $ScriptResult = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection 192.168.254.254 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    if  ($ScriptResult -match '0'){

        Write-Output "PING Connection to 192.168.254.254 successful for Team $i"
    } else {

        Write-Output "PING Connection to 192.168.254.254 unsuccessful for Team $i"

    }
}

#Test ping dns.google from Win10Client
for ($i = 29; $i -le 29; $i++) {
    $ScriptResult = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection dns.google -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    if  ($ScriptResult -match '0'){

        Write-Output "PING Connection to dns.google successful for Team $i"
    } else {

        Write-Output "PING Connection to dns.google unsuccessful for Team $i"

    }
}

#Test ping 8.8.8.8 from Win10Client
for ($i = 29; $i -le 29; $i++) {
    $ScriptResult = InvokeScript -SourceDevice "Win10Client" -Script "(Test-Connection 8.8.8.8 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!"
    if  ($ScriptResult -match '0'){

        Write-Output "PING Connection to 8.8.8.8 successful for Team $i"
    } else {

        Write-Output "PING Connection to 8.8.8.8 unsuccessful for Team $i"

    }
}

