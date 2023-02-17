Clear-Host
$vSphereUser = Read-Host "vSphere Username"
$vSpherePass = Read-Host "vSphere Password" -AsSecureString

Connect-VIServer cdr-vcenter.cse.buffalo.edu -User $vSphereUser -Password $vSpherePass
Clear-Host
write-host("Grading Homework 2... This might take a while.")
$startTime = Get-Date
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

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

        $ScriptResult = Invoke-VMScript -ScriptText $Script -GuestPassword $Passwd -GuestUser $Username -VM $VM -ToolsWaitSecs 120 ## will return output from script that is run.
        $ExpectedResult = $TestExpectedResult -f $number
        if ($ScriptResult -match $ExpectedResult) {
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


##Checking that pfSense if fully configured
#Cannot run script on pfsense, because it uses 'sh' has scripting language, which Invoke-VMScript does not have acccess to
#$checkOPT = CheckState -SourceDevice "pfSenseRouter" -Script "ifconfig em2 | grep inet" -ScriptType "" -Username "admin" -Passwd "pfsense" -TestName "OPT Interface" -TestExpectedResult "10.43.$teamNumber.1" -AdditionalPoints 4
#$checkLAN = CheckState -SourceDevice "pfSenseRouter" -Script "ifconfig em0 | grep inet" -Username "admin" -Passwd "pfsense" -TestName "LAN Interface" -TestExpectedResult "10.42.$teamNumber.1" -AdditionalPoints 4
#$checkWAN = CheckState -SourceDevice "pfSenseRouter" -Script "ifconfig em1 | grep inet" -Username "admin" -Passwd "pfsense" -TestName "WAN Interface" -TestExpectedResult "192.168.254.100 + $teamNumber" -AdditionalPoints 4

##Checking Win10 connection  and configuration
$checkWinGateway = CheckState -SourceDevice "Win10Client" -Script "Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4DefaultGateway | Select-object NextHop" -Username "sysadmin" -Passwd "Change.me!" -TestName "Gateway" -TestExpectedResult "10.42.{$number}.1" -AdditionalPoints 2.5  
$checkWinIP = CheckState -SourceDevice "Win10Client" -Script "Get-NetIPAddress | Where AddressFamily -eq 'IPv4' | Select-Object -ExpandProperty IPAddress" -Username "sysadmin" -Passwd "Change.me!" -TestName "IP address" -TestExpectedResult "10.42.{$number}.12" -AdditionalPoints 2.5
$checkWinPing = CheckState -SourceDevice "Win10Client" -Script "(Test-Connection 8.8.8.8 -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging 8.8.8.8" -TestExpectedResult "0" -AdditionalPoints 2.5
$checkWinDNSPing =CheckState -SourceDevice "Win10Client" -Script "(Test-Connection dns.google -Count 1).StatusCode" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging dns.google" -TestExpectedResult "0" -AdditionalPoints 2.5
##Checking Ubuntu connection and configuration
$checkNixIP = CheckState -SourceDevice "UbuntuClient" -Script "ip addr | grep 'inet 10'" -Username "sysadmin" -Passwd "Change.me!" -TestName "IP" -TestExpectedResult "10.42.{$number}.7" -AdditionalPoints 2.5
$checkNixDNSPing = CheckState -SourceDevice "UbuntuClient" -Script "ping -c 1 dns.google &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging dns.google" -TestExpectedResult "True" -AdditionalPoints 2.5
$checkNixPing = CheckState -SourceDevice "UbuntuClient" -Script "ping -c 1 8.8.8.8 &> /dev/null; echo $?" -Username "sysadmin" -Passwd "Change.me!" -TestName "Pinging 8.8.8.8" -TestExpectedResult "True" -AdditionalPoints 2.5
$checkNixGateway = CheckState -SourceDevice "UbuntuClient" -Script "ip route | grep 'default via'" -Username "sysadmin" -Passwd "Change.me!" -TestName "Gateway" -TestExpectedResult "10.43.{$number}.1" -AdditionalPoints 2.5

$results = $checkWinGateway + $checkWinIP + $checkWinPing + $checkWinDNSPing + $checkNixIP + $checkNixDNSPing + $checkNixPing + $checkNixGateway | Group-Object -Property Team | Select-Object -Property Name, @{n = 'Points'; e = { ($_.Group | Measure-Object -Property Points -Sum).Sum } }
$results | Export-Csv -Path "Homework2_Grades.csv" -NoTypeInformation

Write-Host("Grading Homework 2 Complete!")
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "This grading took: $($elapsedTime.TotalSeconds) seconds to run"

