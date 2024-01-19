pnputil /add-driver "\gdi\brium15a.inf"
pnputil /add-driver "\gdi\BROHL15A.INF"
pnputil /add-driver "\hp\hpbuio200l.inf"

#Adding with pnputil some drivers

#Generating a List with your Inf Files Path

$path = New-Object System.Collections.Generic.List[string]

$path.Add("C:\Windows\System32\DriverStore\FileRepository\brium15a.inf*")
$path.Add("C:\Windows\System32\DriverStore\FileRepository\BROHL15A.INF*")


$onecounter= 0

foreach($p in $path) {

    if(Test-Path -Path $p) {

    }

    else {
        $onecounter++
    }

    
}

if ($onecounter -eq 0)
    {exit 0 }
else {"exit"}