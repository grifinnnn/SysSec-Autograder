    function RunInvokeScript {
        param(
            $SourceDevice,
            $Script,
            $Username,
            $Passwd
            )
        for ($i = 30; $i -le 30; $i++) {
            if ($i -lt 10) {
                $teamNumber = "0$i"
            } else {
                $teamNumber = $i
            }
            $result = Get-Folder "SysSec" | Get-Folder "Team_$teamNumber" | Get-VM $SourceDevice | Invoke-VMScript -ScriptText $Script -GuestPassword $Passwd -GuestUser $Username 
        }
        return $result
    }

    for ($i = 1; $i -le 30; $i++) {
        Team($i)Points = 0
        ##Check IP for ADServer
        $AD_IPAddress = RunInvokeScript -SourceDevice "ADServer" -Script "Get-NetIPAddress | Where AddressFamily -eq 'IPv4' | Select-Object -ExpandProperty IPAddress" -Username "sysadmin" -Passwd "Change.me!"
        if ($AD_IPAddress -match '10.42.$i.98'){
            Team($i)Points += 2.5
        }
        ##Check DNS for ADServer
        $AD_DNS = RunInvokeScript -SourceDevice "ADServer" -Script "Get-DnsClientServerAddress" -Username "sysadmin" -Passwd "Change.me!"
        if ($AD_DNS -match '127.0.0.1'){
            Team($i)Points += 2.5
        }
        ##Check DNS for Win10Client
        $Win10_DNS = RunInvokeScript -SourceDevice "Win10Client" -Script "Get-DnsClientServerAddress" -Username "sysadmin" -Passwd "Change.me!"
        if ($Win10_DNS -match '10.42.$i.98'){
            Team($i)Points += 2.5
        }
        ##Check IP for ServerIIS
        $IIS_IP = RunInvokeScript -SourceDevice "ServerIIS" -Script "Get-NetIPAddress | Where AddressFamily -eq 'IPv4' | Select-Object -ExpandProperty IPAddress" -Username "sysadmin" -Passwd "Change.me!"
        if ($IIS_IP -match '10.42.$i.90'){
            Team($i)Points += 2.5
        }
        ##Check domain for Win10Client
        $Win10_Domain = RunInvokeScript -SourceDevice "ServerIIS" -Script "(Get-WmiObject -Class Win32_ComputerSystem).Domain" -Username "sysadmin" -Passwd "Change.me!"
        if ($Win10_Domain -match 'team$i.local'){
            Team($i)Points += 2.5
        }
        ##Check Powershell logging
        $PS_Logging = RunInvokeScript -SourceDevice "ServerAD" -Script "(Get-ExecutionPolicy) -eq 'Transcription'" -Username "sysadmin" -Passwd "Change.me!"
        if ($PS_Logging -match 'Enabled'){
            Team($i)Points += 2.5
        }
        ##Check DNS status is alive and automatic
        $DNS_Status = RunInvokeScript -SourceDevice "ServerAD" -Script "(Get-Service -Name 'DNS').Status -eq 'Started' -and (Get-Service -Name 'DNS').StartType -eq 'Automatic'" -Username "sysadmin" -Passwd "Change.me!"
        if ($DNS_Status -eq 'True'){
            Team($i)Points += 2.5
        }
        ##Check if IIS status is alive and automatic
        $IIS_Status = RunInvokeScript -SourceDevice "ServerIIS" -Script "(Get-Service -Name 'W3SVC').Status -eq 'Started' -and (Get-Service -Name 'W3SVC').StartType -eq 'Automatic'" -Username "sysadmin" -Passwd "Change.me!"
        if ($IIS_Status -eq 'True'){
            Team($i)Points += 2.5
        }
    }