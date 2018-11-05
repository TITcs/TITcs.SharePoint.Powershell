# clear console
Clear-Host
    
# load sharepoint module
Add-PSSnapin -Name Microsoft.SharePoint.Powershell -ErrorAction Continue

# This script is intended to be simple
#########=========== NOT SUITABLE FOR PRODUCTION ENVIRONMENTS ===========#########

# variables
$webAppTitle = "WebApp Title"
$webAppHostHeader = "host.header"
$webAppUrl = "https://$webAppHostHeader"
$webAppContentDatabase = "WSS_WebApp_ContentDB"
$webAppPoolAccount = "DOMAIN\user"
$webAppPort = 443
$superUser  = "DOMAIN\superuser"
$superReader = "DOMAIN\superreader"

$webApp = Get-SPWebApplication $webAppUrl -ErrorAction SilentlyContinue

# verify if web app exists
if($webApp -eq $null) {
    Write-Host "Web application does not exist!" -ForegroundColor Green

    Write-Host "Creating the authentication provider"

    $ap = New-SPAuthenticationProvider
    
    Write-Host "Creating web application '$webAppTitle', Url = $webAppUrl" -ForegroundColor Yellow

    # create the web app
    $webApp = New-SPWebApplication -Name $webAppTitle -Url $webAppUrl -ApplicationPool $webAppTitle -ApplicationPoolAccount (Get-SPManagedAccount $webAppPoolAccount) -AuthenticationProvider $ap -SecureSocketsLayer -Port $webAppPort -DatabaseName $webAppContentDatabase -HostHeader $webAppHostHeader

    # cache improvements
    $webApp.Properties["portalsuperuseraccount"] = $superUser
    $webApp.Properties["portalsuperreaderaccount"] = $superReader

    # super user
    $superUserPolicy = $webApp.Policies.Add($superUser, "Portal Super User Account")
    $superUserPolicy.PolicyRoleBindings.Add($webApp.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullControl)) 

    # super reader 
    $superReaderPolicy = $webApp.Policies.Add($superReader, "Portal Super Reader Account") 
    $superReaderPolicy.PolicyRoleBindings.Add($webApp.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullRead))
    
    $webApp.Update()

    Write-Host "Web application $webAppTitle created!" -ForegroundColor Green
}
else {
    Write-Host "Web application already exists! Aborting mission..." -ForegroundColor Red
    Sleep 3
}