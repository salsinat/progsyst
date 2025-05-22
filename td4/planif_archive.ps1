
#le dossier à archiver
$dossier = $args[0]

$logfile = "..\log_archive.txt"
$logfilepath = Join-Path -Path $dossier -ChildPath $logfile

$logcsvfile = "..\log_archive.csv"
$logcsvfilepath = Join-Path -Path $dossier -ChildPath $logcsvfile

if ($null -eq $dossier) {
    Write-Host "Usage: planif_archive.ps1 <dossier>"
    exit 1
}

if (-not (Test-Path $dossier)) {
    Write-Host "Le dossier spécifié n'existe pas."
    exit 1
}

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

    # Vérifier si le fichier CSV existe, sinon le créer
    if (-not (Test-Path $logcsvfile)) {
        #prendre le nom des attributs comme nom de colonnes
        $header = $data | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
        $header = $header | ForEach-Object { $_.ToString() }
        $header | Export-Csv -Path $logcsvfile -NoTypeInformation
    }

    Export-Csv -Path $logcsvfile -InputObject $data -NoTypeInformation -Append
}

#fonction d'archivage
function Archive {
    param (
        [string]$dossier
    )
    
    # Création de l'objet 
    $archive = {
        $date = Get-Date -Format "dd-MM-yyyy",
        $heure = Get-Date -Format "HH-mm-ss",
        $chemin = $dossier,
        $taille = (Get-ChildItem -Path $dossier -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB,
        $nbFichiers = (Get-ChildItem -Path $dossier -Recurse | Measure-Object).Count
    }
    # Création de l'archive
    $archiveName = "..\archive_${dossier}_${$date}_${$heure}_.zip"
    $archivePath = Join-Path -Path $dossier -ChildPath $archiveName
    Compress-Archive -Path $dossier -DestinationPath $archivePath

    # journalisation
    $logMessage = "Archive créée: $archivePath"
    LogToFile -message $logMessage -logfile $logfilepath
    LogToCSV -data $logMessage -logcsvfile $logcsvfilepath

}