$csvPath = "\\UNC\PATH\to\FILE.csv"

$results = @()

$currentDate = Get-Date -Format "yyyy-MM-dd"

try {

    $onboardingState = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -Name "OnboardingState" |
                       Select-Object -ExpandProperty OnboardingState

    $mpStatus = Get-MpComputerStatus

    $result = [pscustomobject]@{
        Date                    = $currentDate              
        ComputerName            = $env:COMPUTERNAME         
        OnboardingState         = $onboardingState
        AMEngineVersion         = $mpStatus.AMEngineVersion
        AMRunningMode           = $mpStatus.AMRunningMode
        AMServiceRunningMode    = $mpStatus.AMServiceRunningMode
        AMServiceVersion        = $mpStatus.AMServiceVersion
        ComputerID              = $mpStatus.ComputerID
        OnAccessProtectionEnabled = $mpStatus.OnAccessProtectionEnabled
    }
}
catch {
  
    $result = [pscustomobject]@{
        Date                    = $currentDate
        ComputerName            = $env:COMPUTERNAME
        OnboardingState         = "Error"
        AMEngineVersion         = "Error"
        AMRunningMode           = "Error"
        AMServiceRunningMode    = "Error"
        AMServiceVersion        = "Error"
        ComputerID              = "Error"
        OnAccessProtectionEnabled = "Error"
    }
}


$results += $result

$results | Export-Csv -Path $csvPath -NoTypeInformation -Append
