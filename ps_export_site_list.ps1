# Limpar dados da tela
Clear-Host

# Carregar modulo powershell
if((Get-PSSnapin -Name Microsoft.SharePoint.Powershell) -eq $null){
    Add-PSSnapin -Name Microsoft.SharePoint.Powershell -ErrorAction Continue
}

# Perguntar endereço do site
Write-Host "Digite o endereço do site (Ex. https://hml.wks-01): " -ForegroundColor Yellow -NoNewline
$siteUrl = Read-Host

# Perguntar endereço da lista
Write-Host "Digite o caminho relativo da lista (Ex. ""/Lists/Contatos"" ): " -ForegroundColor Yellow -NoNewline
$listUrl = Read-Host

# Perguntar onde salvar a lista
Write-Host "Digite o caminho local para o arquivo de backup (Ex. ""C:\lista.cmp""): " -ForegroundColor Yellow -NoNewline
$localPath = Read-Host

# Exportar site/lista
Export-SPWeb -Identity $siteUrl -ItemUrl $listUrl -Path $localPath