# Limpar dados da tela
Clear-Host

# Perguntar onde deseja importar os dados
Write-Host "Digite a url do site para importação (Ex. http://wfe-01): " -ForegroundColor Cyan -NoNewline
$siteUrl = Read-Host

# Perguntar o caminho do arquivo para importação
Write-Host "Digite o caminho do arquivo de importação (Ex. C:\backup.cmp): " -ForegroundColor Cyan -NoNewline
$path = Read-Host

if($path.EndsWith(".cmp") -eq $true){
    # Importar dados
    Import-SPWeb -Identity $siteUrl -Path $path -Force
}else{
    # Logar mensagem de argumento invalido
    Write-Host "Extensão de arquivo inválido." -ForegroundColor Red
}