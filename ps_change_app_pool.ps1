# Limpar dados da tela
Clear-Host
    
# Carregar modulo powershell
Add-PSSnapin -Name Microsoft.SharePoint.Powershell -ErrorAction Continue

# URL da web application da qual quero copiar o Application Pool
$baseWebAppUrl = "http://origem.com" # MUDAR
$baseWebAppPool = (Get-SPWebApplication $baseWebAppUrl).ApplicationPool

# URL da web application que quero mudar o Application Pool
$webAppUrl = "http://destino.com" # MUDAR
$webApp = Get-SPWebApplication $webAppUrl
$webApp.ApplicationPool = $baseWebAppPool
$webApp.ProvisionGlobally()
$webApp.Update();

# Reiniciar o IIS
iisreset