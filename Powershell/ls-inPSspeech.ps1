# Angabe des Ordners, dessen Unterordner aufgelistet werden sollen
$folder = "C:

# Erstellen einer neuen CSV-Datei
$subfolders = Get-ChildItem -Directory $folder | Select-Object Name
$subfolders | Export-Csv -NoTypeInformation -Path "sheesh.csv"