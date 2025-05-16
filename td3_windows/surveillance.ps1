$processName = "notepad"
$dateDebut = Get-Date

#création d'un fhchier de log s'il n'existe pas
$logFile = "$pwd\log_windows.txt"
if (-not (Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File
}

#fonction de log 
function LogMessage {
    param (
        [string]$message,
        [bool]$color = $false
    )
    if ($color) {
        Write-Host $message -ForegroundColor Green
    } else {
        Write-Host $message 
    }
    Add-Content -Path $logFile -Value $message
}

$i = 5
while ($i -gt 0) {
    $logHeure = "Il est $((Get-Date).ToString('HH:mm:ss')), écoute du processus $processName..."
    LogMessage $logHeure

    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        $logMsg = "Le processus $processName est en cours d'exécution."
        LogMessage $logMsg
    } else {
        $logMsg = "Le processus $processName n'est pas en cours d'exécution."
        LogMessage $logMsg
        Start-Process $processName
        $logMsg = "Le processus $processName a été relancé."
        LogMessage $logMsg
    }
    Start-Sleep -Seconds 5
    $i--
}

#fichier csv
$csvFile = "$pwd\resume_surveillance.csv"
if (-not (Test-Path $csvFile)) {
    New-Item -Path $csvFile -ItemType File
    $csvContent = "Nom du script;Processus Surveillé;Nombre total de relance;Date de début;Date de fin;Durée totale"
    Add-Content -Path $csvFile -Value $csvContent
}

#message coloré
$logFin = "Fin de la surveilllance`n"
LogMessage $logFin $true

#écriture dans le fichier csv
$scriptName = "surveillance.ps1"
$dateFin = Get-Date
$duree = $dateFin - $dateDebut
$csvContent = "$scriptName;$processName;$(5-$i);$dateDebut;$dateFin;$duree"
Add-Content -Path $csvFile -Value $csvContent

