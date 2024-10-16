$csvPath = "\\UNC\PATH\to\FILE.csv"

$results = @()

$currentDate = Get-Date -Format "yyyy-MM-dd"

$currentTime = Get-Date -Format "HH:mm"

try {

    $onboardingState = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -Name "OnboardingState" |
                       Select-Object -ExpandProperty OnboardingState

    $mpStatus = Get-MpComputerStatus

    $result = [pscustomobject]@{
        Date                    = $currentDate              
	Time                    = $currentTime        
	ComputerName            = $env:COMPUTERNAME         
        OnboardingState         = $onboardingState
        AMEngineVersion         = $mpStatus.AMEngineVersion
        AMRunningMode           = $mpStatus.AMRunningMode
        AMServiceRunningMode    = $mpStatus.AMServiceRunningMode
        AMServiceVersion        = $mpStatus.AMServiceVersion
        ComputerID              = $mpStatus.ComputerID
        OnAccessProtectionEnabled = $mpStatus.OnAccessProtectionEnabled
	IsTamperProtected       = $mpStatus.IsTamperProtected
        RealTimeProtectionEnabled = $mpstatus.RealTimeProtectionEnabled
    }
}
catch {
  
    $result = [pscustomobject]@{
        Date                    = $currentDate
	Time                    = $currentTime        
ComputerName            = $env:COMPUTERNAME
        OnboardingState         = "Error"
        AMEngineVersion         = "Error"
        AMRunningMode           = "Error"
        AMServiceRunningMode    = "Error"
        AMServiceVersion        = "Error"
        ComputerID              = "Error"
        OnAccessProtectionEnabled = "Error"
	IsTamperProtected       = "Error"
        RealTimeProtectionEnabled = "Error"
    }
}


$results += $result

$results | Export-Csv -Path $csvPath -NoTypeInformation -Append
