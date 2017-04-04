# clear screen
Clear-Host

# get the folder path to export de backup files
Write-Host ([String]::Format("Type the UNC path of the backup folder (E.g: \\SERVER\FOLDER): ")) -NoNewline -ForegroundColor Green
$backupFolder = Read-Host

# get the web application name
Write-Host ([String]::Format("Inform the web application name: ")) -NoNewline -ForegroundColor Green
$webAppName = Read-Host

# perform the backup operation
Backup-SPFarm -Directory $backupFolder -BackupMethod Full -Item $webAppName -Verbose