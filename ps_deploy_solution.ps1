# clear console
Clear-Host
    
# carrega modulo powershell
if((Get-PSSnapin -Name Microsoft.SharePoint.Powershell) -eq $null){
    Add-PSSnapin -Name Microsoft.SharePoint.Powershell -ErrorAction Continue
}

$packageName = "Solution.wsp"
$siteUrl = "https://siteurl"
$fullPackageName = ([System.IO.Path]::Combine($(Get-Location), $packageName))

# uninstall package in case it exists
$solution = Get-SPSolution $packageName -ErrorAction SilentlyContinue
if($solution -ne $null) {
    Write-Host "Uninstalling package $packageName from $siteUrl" -ForegroundColor Yellow
    $solution | Uninstall-SPSolution -WebApplication $siteUrl -Confirm:$false

    while($solution.JobExists) {
        Sleep 3
        Write-Host "." -NoNewline
    }

    Write-Host "Package uninstalled!" -ForegroundColor Green

    # remove from CA
    Write-Host "Removing package $packageName from CA" -ForegroundColor Yellow
    $solution | Remove-SPSolution -Confirm:$false

    Write-Host "Package removed!" -ForegroundColor Green
}

# add package to CA
Write-Host "Adding package $packageName to CA" -ForegroundColor Green
Add-SPSolution -LiteralPath $fullPackageName -Confirm:$false

# installing package into destination site
Write-Host "Installing package $packageName at $siteUrl" -ForegroundColor Green
Install-SPSolution $packageName -WebApplication $siteUrl -GACDeployment -FullTrustBinDeployment -Confirm:$false

while($solution.JobExists) {
    Sleep 3
    Write-Host "." -NoNewline
}

Write-Host

Write-Host "Package installed!" -ForegroundColor Green

Remove-PSSnapin Microsoft.SharePoint.PowerShell