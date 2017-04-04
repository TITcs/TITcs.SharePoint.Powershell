# Limpar dados da tela
Clear-Host
    
# Carregar modulo powershell
if((Get-PSSnapin -Name Microsoft.SharePoint.Powershell) -eq $null){
    Add-PSSnapin -Name Microsoft.SharePoint.Powershell -ErrorAction Continue
}

function NewLista([System.String]$id, [System.String]$title, [System.String]$serverRelativeUrl, [System.String]$baseType){
    # Criando o objeto de retorno
    $resultObj = New-Object -TypeName Object

    # Adicionar propriedades ao objeto
    Add-Member -InputObject $resultObj -MemberType NoteProperty -Name Id -Value $id
    Add-Member -InputObject $resultObj -MemberType NoteProperty -Name Title -Value $title
    Add-Member -InputObject $resultObj -MemberType NoteProperty -Name ServerRelativeUrl -Value $serverRelativeUrl
    Add-Member -InputObject $resultObj -MemberType NoteProperty -Name BaseType -Value $baseType

    return $resultObj
}

function ExportLists(){
}

function FixLookupColumn([Microsoft.SharePoint.SPList] $destList, [System.String] $columnName, [System.String] $newLookupListId, [System.String] $sourceWebId){
    # Mostrar mensagem de status de atualizacao
    Write-Host ([System.String]::Format("Atualizando coluna de lookup {0} para a lista {1}", $columnName, $newLookupListId)) -ForegroundColor Yellow
    
    $listAttrRegexStr = "List=`"({)?([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})(})?`""
    $sourceAttrRegexStr = "SourceID=`"({)?([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})(})?`""
    $webAttrRegexStr = "WebId=`"({)?([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})(})?`""

    # Forçar permissão para atualizar campos via powershell
    #$destList.ParentWeb.AllowUnsafeUpdates = $true
    #$destList.Update()

    # Buscar coluna a ser atualizada
    $field = $destList.Fields.GetField($columnName)

    # Checar se a coluna não é nula
    if($field -ne $null){
        $listAttrRegex = [System.Text.RegularExpressions.Regex]($listAttrRegexStr)
        $sourceAttrRegex = [System.Text.RegularExpressions.Regex]($sourceAttrRegexStr)
        $webAttrRegex = [System.Text.RegularExpressions.Regex]($webAttrRegexStr)

        if(($listAttrRegex.Match($field.SchemaXml)).Success){
            # Fazer cast de tipo da coluna
            [Microsoft.SharePoint.SPFieldLookup] $lookupField = $field

            # Armazenar SchemaXml da coluna
            $oldSchema = $lookupField.SchemaXml

            $lookupField.LookupWebId

            Write-Host ([System.String]::Format("{0} (SourceID: {1})", $oldSchema, $sourceWebId)) -ForegroundColor White
            Write-Host ([System.String]::Format("-------------------------------")) -ForegroundColor Yellow

            $newSchema = $oldSchema.Replace($lookupField.LookupWebId.ToString(), $destList.ParentWeb.ID.ToString())
            $newSchema = $newSchema.Replace($lookupField.LookupList.ToString(), $newLookupListId)

            #$newSchema = ([System.Text.RegularExpressions.Regex]($listAttrRegexStr)).Replace($oldSchema, [System.String]::Concat("List=`"", $newListName, "`""))
            #$newSchema = ([System.Text.RegularExpressions.Regex]($sourceAttrRegex)).Replace($newSchema, [System.String]::Concat("SourceID=`"{", $destList.ID, "}`""))
            #$newSchema = ([System.Text.RegularExpressions.Regex]($webAttrRegex)).Replace($newSchema, [System.String]::Concat("WebID=`"{", $destList.ParentWeb.ID, "}`""))

            #$lookupField.LookupList = $destList.ID
            #$lookupField.LookupWebId = [Guid]($destList.ParentWeb.ID)
            #$newSchema = $lookupField.SchemaXml
            #$lookupField.Update($true)

            Write-Host ([System.String]::Format("{0}", $newSchema)) -ForegroundColor Magenta

            $lookupField.SchemaXml = $newSchema
            #$lookupField.PushChangesToLists = $true
            $lookupField.Update()

            # Excluir coluna antiga
            #$destList.Fields.GetField($columnName).Delete()
            #$destList.Update()

            # Adicionar coluna nova
            #$destList.Fields.AddFieldAsXml($newSchema)
            #$destList.Update()
        }
    }

    # Proibir permissão para atualizar campos via powershell
    #$destList.ParentWeb.AllowUnsafeUpdates = $false
    #$destList.Update()
}

function MainFunction(){
    # Perguntar o endereco do site para listagem
    Write-Host "Digite o endereço do site (Ex. http://wfe-01): " -ForegroundColor Green -NoNewline
    $siteUrl = Read-Host
    
    # Retirar barra do final
    $siteUrl = $siteUrl.TrimEnd("/")
    
    # Listas a serem exportadas
    $lists = @()

    # Carregar informacoes sobre o site
    $spWeb = Get-SPWeb -Identity $siteUrl
    if($spWeb -ne $null){
        Write-Host ">> Site: " $spWeb.Url -ForegroundColor Cyan
        foreach($l in $spWeb.Lists){
            # Imprimir nome da lista
            if([System.String]::Compare("DocumentLibrary", $l.BaseType, $true) -ne 0){

                # Mostrar listas do tipo DocumentLibrary do site
                Write-Host ([System.String]::Format("    >> Lista: {0} ", $l.Title)) -ForegroundColor Yellow -NoNewline
                Write-Host ([System.String]::Format("{0} - {1}", $l.Id, $l.RootFolder.ServerRelativeUrl)) -ForegroundColor Magenta
    
                # Adicionar lista na fila
                $lists += (NewLista $l.Id $l.Title $l.RootFolder.ServerRelativeUrl $l.BaseType)
            }
        }
    
        # Perguntar quais listas deseja exportar
        Write-Host `n
    
        Write-Host ([System.String]::Format("Quais listas deseja exportar? (Ex. Digite os IDs do comando anterior separados por expaço em branco) ")) -ForegroundColor Green -NoNewline
        $listasExportar = Read-Host
    
        # Processar entrada de dados
        $listas = $listasExportar.TrimStart().TrimEnd().Split(",")
    
        # Exportar para qual diretorio?
        Write-Host ([System.String]::Format("Para qual diretório deseja exportar as listas? (Ex. C:\tmp ) ")) -ForegroundColor Yellow -NoNewline
        $dir = Read-Host
    
        if([System.IO.Directory]::Exists($dir)){
            Write-Host ([System.String]::Format("Exportar listas para {0}", $dir)) -ForegroundColor Magenta
    
            foreach($lista in $listas){
                # Inicializar contador
                $tmp = $null
                $count = 0

                # Verificar se a lista realmente existe
                $tmp = $lists | Where-Object { $_.ServerRelativeUrl -eq $lista }
                $tmp | ForEach-Object {
                    $count = $count + 1
                }

                if($count -gt 0){
                    if(($tmp -is [System.Array])){
                        $tmp = $tmp[0]
                    }

                    $filename = [System.IO.Path]::Combine($dir, [System.String]::Format("{0}.cmp", $lista.Replace(" ", "_").Replace("/", "_").TrimStart("_").TrimEnd("_")))
    
                    #Export-SPWeb -Identity $siteUrl -ItemUrl $tmp.ServerRelativeUrl -Path $filename -IncludeVersions All -Verbose
                    Write-Host ([System.String]::Format("Exportando lista {0} para o arquivo {1}", $tmp.ServerRelativeUrl, $filename)) -ForegroundColor Cyan
                }
                # Mostrar mensagem de lista inexistente
            }
    
        }else{
            # Mostrar mensagem de erro de diretÃ³rio invÃ¡lido!
            Write-Host ([System.String]::Format("Erro! Diretório inválido!")) -ForegroundColor Red
        }
    
        # Perguntar o site para o qual deseja importar as listas
        Write-Host
        Write-Host "Digite o endereço do site para o qual deseja importar as listas (Ex. http://wfe-01): " -ForegroundColor Green -NoNewline
        $destUrl = Read-Host
    
        # Buscar todos os arquivos .cmp da pasta de output de importação
        $exports = [System.IO.Directory]::GetFiles($dir, "*.cmp")
    
        foreach($exp in $exports){
            # Logar mensagem de importação
            Write-Host ([System.String]::Format("Importando lista a partir do arquivo {0}", $exp)) -ForegroundColor Cyan
    
            # Importar lista
            #Import-SPWeb -Identity $destUrl -Path $exp -Force
        }
    
        # Obter contexto da web de destino
        $destWeb = Get-SPWeb -Identity $destUrl
    
        if($destWeb -ne $null){
            # Mostrar informação do site de destino
            Write-Host ">> Site: " $destWeb.Url -ForegroundColor Cyan
            foreach($l in $destWeb.Lists){

                # Imprimir nome das listas do site de destino
                if([System.String]::Compare("DocumentLibrary", $l.BaseType, $true) -ne 0){
                    # Mostrar listas do tipo DocumentLibrary
                    Write-Host ([System.String]::Format("    >> Lista: {0} {1} {2} ", $l.Title, $l.Id, $l.RootFolder.ServerRelativeUrl)) -ForegroundColor Yellow
                }
            }

            foreach($l in $listas){                
                # Inicializar contador
                $tmp = $null
                $count = 0

                # Verificar se a lista realmente existe
                $tmp = $lists | Where-Object { $_.ServerRelativeUrl -eq $l }
                $tmp | ForEach-Object {
                    $count = $count + 1
                }

                if($count -gt 0){
                    if(($tmp -is [System.Array])){
                        $tmp = $tmp[0]
                    }

                    # Buscar lista após importação
                    $listObj = $destWeb.Lists[$tmp.Title]

                    if($listObj -ne $null){
                        Write-Host ([System.String]::Format("Atualizando colunas de lookup da lista {0} {1}", $listObj.Title, $listObj.Id)) -ForegroundColor Cyan

                        # Mostrar informações sobre as colunas da lista
                        foreach($z in $listObj.Fields | Where-Object { $_.Type -eq "Lookup"}){
                            Write-Host ([System.String]::Format("    Coluna: {0} ", $z.InternalName)) -ForegroundColor White
                        }

                        Write-Host `n

                        Write-Host ([System.String]::Format("Informe as colunas para atualizar. (Ex: Title,StartDate )")) -ForegroundColor Cyan
                        $fields = Read-Host

                        if([System.String]::IsNullOrEmpty($fields) -ne $true){
                            # Transformar entrada em array                            
                            $fields = $fields.TrimStart().TrimEnd().Split(",")

                            foreach($f in  $fields){
                                # Buscar dados da coluna no site
                                $tmpF = $listObj.Fields.GetField($f)

                                # Só realiza atualização nas colunas de lookup
                                if(($tmpF).Type -eq "Lookup"){
                                    # Perguntar o id da nova lista 'target' do lookup
                                    Write-Host ([System.String]::Format("Informe o Id da lista que a coluna deve obter os dados. (Ex: 01f66f53-bd92-468f-a1d2-0fee138dd173 )")) -ForegroundColor Cyan                                
                                    $newLookupId = Read-Host

                                    #Write-Host ([System.String]::Format("    Atualizando coluna {0})", $f)) -ForegroundColor Cyan

                                    FixLookupColumn  -destList $listObj -columnName $f -newLookupListId $newLookupId -sourceWebId $spWeb.ID

                                    #$schemaXml = $tmpF.SchemaXml
                                    #$newSchemaXml = [System.Text.RegularExpressions.Regex]::Replace($schemaXml, $regex, [System.String]::Concat("List=`"{", $newLookupId, "}`""), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

                                    #Write-Host ([System.String]::Format("{0} --> `n {1}", $schemaXml, $newSchemaXml)) -ForegroundColor Cyan
                                    #Write-Host ([System.String]::Format("    Coluna {0} atualizada!)", $f)) -ForegroundColor Cyan
                                }
                            }
                        }
                    }
                }
            }
        }
        
        # Liberar memoria
        $spWeb.Dispose()
    }
}

MainFunction