
#le dossier à archiver
$dossier = $args[0]
$nomDossier = Split-Path -Path $dossier -Leaf

$dateFin = (Get-Date).AddMinutes(5)
$archiveFolderPath = "$dossier\..\archives_$nomDossier"

if ($null -eq $dossier) {
    Write-Host "Usage: planif_archive.ps1 <dossier>"
    exit 1
}

if (-not (Test-Path $dossier)) {
    Write-Host "Le dossier spécifié n'existe pas."
    exit 1
}

# Création du dossier d'archives s'il n'existe pas
if (-not (Test-Path -Path $archiveFolderPath)) {
    New-Item -Path $archiveFolderPath -ItemType Directory
}

$logfile = "log_archive.txt"
$logfilepath = Join-Path -Path $archiveFolderPath -ChildPath $logfile

$logcsvfile = "log_archive.csv"
$logcsvfilepath = Join-Path -Path $archiveFolderPath -ChildPath $logcsvfile



# fonction de journalisation dans un fichier texte
function LogToFile {
    param (
        [string]$message,
        [string]$logfile
    )

    # Vérifier si le fichier de log existe, sinon le créer
    if (-not (Test-Path $logfile)) {
        New-Item -Path $logfile -ItemType File
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logfile -Value $logMessage
}

# fonction de journalisation dans un fichier CSV
function LogToCSV {
    param (
        [object]$data,
        [string]$logcsvfile
    )

    $data | Export-Csv -Path $logcsvfile -NoTypeInformation -Append
}

#fonction d'archivage
function Archive {
    param (
        [string]$dossier
    )
    
    # Création de l'objet 
    $archive = [PSCustomObject]@{
        Nom = $nomDossier
        Date = Get-Date -Format "dd-MM-yyyy"
        Heure = Get-Date -Format "HH-mm-ss"
        Chemin = $dossier
        Taille = (Get-ChildItem -Path $dossier -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        NbFichiers = (Get-ChildItem -Path $dossier -Recurse | Measure-Object).Count
    }
    # Création de l'archive
    $archiveName = "$($nomDossier)_$($archive.Date)_$($archive.Heure)_.zip"
    $archivePath = Join-Path -Path $archiveFolderPath -ChildPath $archiveName
    Compress-Archive -Path $dossier -DestinationPath $archivePath -Force

    # journalisation
    $logMessage = "Archive créée: $archivePath"
    LogToFile -message $logMessage -logfile $logfilepath
    LogToCSV -data $archive -logcsvfile $logcsvfilepath
}

while ((Get-Date) -lt $dateFin) {
    # pause de 5 secondes
    Start-Sleep -Seconds 5
    # appel de la fonction d'archivage
    Archive -dossier $dossier
    # suppression des plus anciennes archives si plus de 5 archives
    $archivesExistantes = Get-ChildItem -Path $archiveFolderPath | Sort-Object LastWriteTime -Descending | Where-Object { $_.Extension -eq '.zip' }
    if ($archivesExistantes.Count -gt 5) {
        $archivesExistantes | Select-Object -Skip 5 | ForEach-Object {
            Remove-Item -Path $_.FullName -Force
            LogToFile -message "Archive supprimée: $($_.FullName)" -logfile $logfilepath
        }
    }
}