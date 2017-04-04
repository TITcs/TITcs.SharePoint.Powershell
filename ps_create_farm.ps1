# =============== ETAPA 1 =============== #
# instala as roles Application Server e Web Server
#   1. montar o disco de instalação do Windows Server
#   2. abrir o Windows PowerShell com provilégios de administrador
#   3. executar Import-Module ServerManager
#   4. Add-WindowsFeature Net-Framework-Features,Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,
#      Web-Http-Errors,Web-App.Dev,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,
#      Web-Http-Tracing,Web-Security,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Digest-Auth,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,
#      Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Application-Server,AS-Web-Support,AS-TCP-Port-Sharing,AS-WAS-Support,AS-HTTP-Activation,
#      AS-TCP-Activation,AS-Named-Pipes,AS-Net-Framework,WAS,WAS-Process-Model,WAS-NET-Environment,WAS-Config-APIs,Web-Lgcy-Scripting,Windows-Identity-Foundation,
#      Server-Media-Foundation,Xps-Viewer -Source MOUNTPOINTDAMEDIADOWINDOWS
#   5. shutdown /r

# =============== ETAPA 2 =============== #
# instala os prerequisitos do SharePoint
#   1. d:\Prerequisiteinstaller.exe /PowerShell:"\\ws2012dc\prereq\WINDOWS6.1-KB2506143-x64.msu" /NETFX:"\\ws2012dc\prereq\dotNetFx45_Full_x86_x64.exe" /IDFX:"\\ws2012dc\prereq\Windows6.1-KB974405-x64.msu" 
#      /sqlncli:"\\ws2012dc\prereq\sqlncli.msi" /Sync:"\\ws2012dc\prereq\Synchronization.msi" /AppFabric:"\\ws2012dc\prereq\WindowsServerAppFabricSetup_x64.exe" /IDFX11:"\\ws2012dc\prereq\MicrosoftIdentityExtensions-64.msi" /MSIPCClient:"\\ws2012dc\prereq\setup_msipc_x64.msi" 
#      /WCFDataServices:"\\ws2012dc\prereq\WcfDataServices.exe" /KB2671763:"\\ws2012dc\prereq\AppFabric1.1-RTM-KB2671763-x64-ENU.exe"


# =============== ETAPA 3 =============== #

# Antes de rodar esse script, é necessário desabilitar execução paralela de instruções no SQL Server (Valor 1).

# Para executar esse script é necessário que o usuário logado:
#   1. Possua conta com permissão de usuário de domnínio
#   2. Seja membro do grupo "Local Administrators" em cada servidor na camada Web e de Aplicação
#   3. Seja membro do grupo "securityadmin" e "dbcreator" no SQL Server

# adiciona o módulo de powershell do SharePoint
Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue

# solicita a conta do farm
$farmCredential = Get-Credential -credential DOMINIO\CONTA

# solicita a senha
$passPhrase = Read-Host -AsSecureString "SENHA"

# configura variáveis
$dbName = "SharePoint_Config"
$dbServer = "SERVIDOR"
$adminContentDb = "SharePoint2016_Admin_Content"
$centralAdminPort = "5000"

# =============== ESSE COMANDO PODE DEMORAR PARA FINALIZAR ===============

# cria o banco de configuração
New-SPConfigurationDatabase -DatabaseName $dbName -DatabaseServer $dbServer -AdministrationContentDatabaseName $adminContentDb -FarmCredentials $farmCredential -PassPhrase $passPhrase

# =============== ESSE COMANDO PODE DEMORAR PARA FINALIZAR ===============


# =============== ETAPA 4 =============== #


# instala arquivos site collection de suporte
Install-SPHelpCollection -All

# reforça segurança de recursos no servidor local
Initialize-SPResourceSecurity

# instala e provisiona serviços na farm
Install-SPService

# instala recursos do arquivo Feature.xml
Install-SPFeature -AllExistingFeatures

# =============== ETAPA 5 =============== #
# cria a central de administração
New-SPCentralAdministration -Port $centralAdminPort -WindowsAuthProvider "NTLM"

# copiar dados compartilhados para pastas da aplicação
Install-SPApplicationContent

# =============== ETAPA 6 =============== #

# instalar o pacote de linguagens em CADA SERVIDOR


# =============== ETAPA 7 =============== #
# registrar os service connection points no AD
Get-SPFarmConfig -ServiceConnectionPoint
Set-SPFarmConfig -ServiceConnectionPointBindingInformation http://URLDOFARMTOPOLOGYSERVICE # (Get-SPTopologyServiceApplication | select URI )

# Para remover o service connection point da SharePoint Farm do AD
# Set-SPFarmConfig -ServiceConnectionDelete

# =============== ETAPA 8 =============== #
# configura emails de entrada e saída
#   1. instalar o recurso de SMTP server no servidor
#   2. habilitar emails de entrada na Central de Administração > Configurações de Sistema > Configurações Automáticas

