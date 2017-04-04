# Limpar dados da tela
Clear-Host

# Carregar modulo powershell
if((Get-PSSnapin -Name Microsoft.SharePoint.Powershell) -eq $null){
    Add-PSSnapin -Name Microsoft.SharePoint.Powershell -ErrorAction Continue
}

# Perguntar o endereco do site para listagem
Write-Host "Digite o endereço do site (Ex. http://wfe-01): " -ForegroundColor Cyan -NoNewline
$siteUrl = Read-Host

# Carregar informações sobre o site
$spWeb = Get-SPWeb -Identity $siteUrl
if($spWeb -ne $null){
    Write-Host "Site: " $spWeb.Url -ForegroundColor Green
    foreach($l in $spWeb.Lists){
        # Imprimir nome da lista
        Write-Host "    >> Lista: " $l.Title "(" $l.ID ")(" $l.DefaultDisplayFormUrl ")" -ForegroundColor Yellow
    }

    # Liberar memoria
    $spWeb.Dispose()
}