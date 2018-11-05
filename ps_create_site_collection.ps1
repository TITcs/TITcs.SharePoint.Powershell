# clear console
Clear-Host
    
# load sharepoint module
Add-PSSnapin -Name Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue

# This script is intended to be simple
#########=========== NOT SUITABLE FOR PRODUCTION ENVIRONMENTS ===========#########

# variables
$siteCollectionUrl = "https://siteurl"
$siteOwnerAlias = "DOMAIN\user"
$webTemplateName = "BLANKINTERNETCONTAINER#0"
$webTemplate = Get-SPWebTemplate $webTemplateName -ErrorAction SilentlyContinue

if($webTemplate -ne $null) {    
    Write-Host "Creating site collection at $siteCollectionUrl with template $webTemplateName" -ForegroundColor Yellow

    # create site collection
    New-SPSite -Url $siteCollectionUrl -OwnerAlias $siteOwnerAlias -Template $webTemplate

    Write-Host "Site collection created!" -ForegroundColor Green
}
else {
    Write-Host "Sharepoint does not support the web template!" -ForegroundColor Red
}