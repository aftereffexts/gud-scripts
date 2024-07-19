$paths = New-Object System.Collections.Generic.List[string]

$paths.Add("W:")
$paths.Add("V:")

$date = Get-Date -Format "yyyy-MM-dd"

$csvfile = "C:\Users\TestPC\Documents\$date-logs.csv"

$results = @()

#New-Item -Path $csvfile -ItemType File

foreach($path in $paths) {

    if(Test-Path -Path $path) {

        $items = dir $path -Directory | ?{$_.CreationTime -lt (Get-Date).AddMonths(-3)}

        $items | del -recurse -Force

        $results += $items

    }

}

$results | Export-Csv -Path $csvfile -append -delimiter ";" -encoding utf8 -NoTypeInformation -Force

