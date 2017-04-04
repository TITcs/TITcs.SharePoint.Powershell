# Load SharePoint PowerShell PSSnapIn and the main SharePoint .net library
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

# clear host
Clear-Host

function LogToFile([System.String] $msg){
    Clear-Host
    $filename = "conecte_deploy.log"
    $path = [System.IO.Path]::Combine((Get-Item -Path ".\" -Verbose).FullName, $filename)

    $date = Get-Date -Format "dd/MM/yyyy hh:mm"
    $msg = [System.String]::Format("{0}: {1}", $date, $msg)

    if([System.IO.File]::Exists($path) -eq $false){
        New-Item -Path . -Name $filename -ItemType "file" -Value ([System.String]::Concat($msg, "`r`n")) -Force        
    }else{
        Add-Content -Path $filename -Value ([System.String]::Concat($msg, "`n"))
    }
}

function AddSupportToFormsBasedAuthentication(){

}

#<sectionGroup name="sharePointService">
#   <section name="service" type="TITcs.SharePoint.SSOM.Services.SharePointServiceSection" />
#</sectionGroup>
#<sharePointService>
#   <service assemblyName="PGC.SharePoint.MelhoresPraticas, Version=1.0.0.0, Culture=neutral, PublicKeyToken=9553f3d4b8592cc4" />
#</sharePointService>
#<add name="SharePointHandlerFactory" verb="*" path="*.spss" type="TITcs.SharePoint.SSOM.Services.HandlerFactory" />
#<SafeControl Assembly="PGC.SharePoint.Controls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=67b7b4f910f1bafe" Namespace="ASP" TypeName="*" Safe="True"/>
function AddTITFramework([Microsoft.SharePoint.Administration.SPWebApplication] $wa){
    Try{
        $titFrameworkSection = New-Object "Microsoft.SharePoint.Administration.SPWebConfigModification"
        $titFrameworkSection.Path = "configuration/configSections"
        $titFrameworkSection.Name = "sectionGroup[@name='sharePointService']"
        $titFrameworkSection.Sequence = 0
        $titFrameworkSection.Owner = $owner
        $titFrameworkSection.Type = 0 # EnsureChildNode
        $titFrameworkSection.Value = "<sectionGroup name='sharePointService'><section name='service' type='TITcs.SharePoint.SSOM.Services.SharePointServiceSection' /></sectionGroup>"
        
        #add our web config modification to the stack of mods that are applied
        $wa.WebConfigModifications.Add($titFrameworkSection)
         
        # report progress
        Write-Host -ForegroundColor Yellow "Adicionando configurações do framework"
        LogToFile ([System.String]::Format("Adicionando configSections: `n {0}", $titFrameworkSection.Value))
        
        $titService = New-Object "Microsoft.SharePoint.Administration.SPWebConfigModification"
        $titService.Path = "configuration"
        $titService.Name = "sharePointService"
        $titService.Sequence = 0
        $titService.Owner = $owner
        $titService.Type = 0 # EnsureChildNode
        $titService.Value = "<sharePointService><service assemblyName='PGC.SharePoint.MelhoresPraticas, Version=1.0.0.0, Culture=neutral, PublicKeyToken=9553f3d4b8592cc4'/></sharePointService>"
        
        #add our web config modification to the stack of mods that are applied
        $wa.WebConfigModifications.Add($titService)
        
        # report progress
        LogToFile ([System.String]::Format("Adicionando services sections: `n {0}", $titService.Value))
        
        # add handler
        $titHandler = New-Object "Microsoft.SharePoint.Administration.SPWebConfigModification"
        $titHandler.Path = "configuration/system.webServer/handlers"
        $titHandler.Name = "add[@name='SharePointHandlerFactory']"
        $titHandler.Sequence = 0
        $titHandler.Owner = $owner
        $titHandler.Type = 0 # EnsureChildNode
        $titHandler.Value = "<add name='SharePointHandlerFactory' verb='`*' path='`*.spss' type='TITcs.SharePoint.SSOM.Services.HandlerFactory' />"
        
        #add our web config modification to the stack of mods that are applied
        $wa.WebConfigModifications.Add($titHandler)
        
        # report progress
        LogToFile ([System.String]::Format("Adicionando handler factories: `n {0}", $titHandler.Value))
        
        # add safe control
        $titSafeControl = New-Object "Microsoft.SharePoint.Administration.SPWebConfigModification"
        $titSafeControl.Path = "configuration/SharePoint/SafeControls"
        $titSafeControl.Name = "SafeControl[@Assembly='PGC.SharePoint.Controls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=67b7b4f910f1bafe']"
        $titSafeControl.Sequence = 0
        $titSafeControl.Owner = $owner
        $titSafeControl.Type = 0 # EnsureChildNode
        $titSafeControl.Value = "<SafeControl Assembly='PGC.SharePoint.Controls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=67b7b4f910f1bafe' Namespace='ASP' TypeName='*' Safe='True'/>"
        
        #add our web config modification to the stack of mods that are applied
        $wa.WebConfigModifications.Add($titSafeControl)
        
        # report progress
        LogToFile ([System.String]::Format("Adicionando safe controls: `n {0}", $titSafeControl.Value))
        
        #TODO: ENABLE LDAP AUTH
        #$formsBasedAuth = ""
        #LogToFile ([System.String]::Format("Habilitando autenticação forms: `n {0}", $formsBasedAuth.Value))
        
        Write-Host -ForegroundColor Yellow "Configurações do framework adicionadas"
        
        # update application
        $wa.Update()
    }
    Catch{
        LogToFile ([System.String]::Format("Erro: `n {0}", $_.Exception.Message))
    }
}

#<add assembly="PGC.SharePoint.MelhoresPraticas, Version=1.0.0.0, Culture=neutral, PublicKeyToken=9553f3d4b8592cc4" />
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#   <assemblyIdentity name="Microsoft.AspNet.SignalR.Client" publicKeyToken="31bf3856ad364e35" culture="neutral" />
#   <bindingRedirect oldVersion="0.0.0.0-3.0.0.0" newVersion="2.2.1.0" />
#</dependentAssembly>
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#    <assemblyIdentity name="Microsoft.AspNet.SignalR.Core" publicKeyToken="31bf3856ad364e35" culture="neutral" />
#    <bindingRedirect oldVersion="0.0.0.0-3.0.0.0" newVersion="2.2.1.0" />
#</dependentAssembly>
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#    <assemblyIdentity name="Microsoft.AspNet.SignalR.SystemWeb" publicKeyToken="31bf3856ad364e35" culture="neutral" />
#    <bindingRedirect oldVersion="0.0.0.0-3.0.0.0" newVersion="2.2.1.0" />
#</dependentAssembly>
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#    <assemblyIdentity name="Microsoft.Owin" publicKeyToken="31bf3856ad364e35" culture="neutral" />
#    <bindingRedirect oldVersion="0.0.0.0-4.0.0.0" newVersion="3.0.1.0" />
#</dependentAssembly>
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#    <assemblyIdentity name="Microsoft.Owin.Host.SystemWeb" publicKeyToken="31bf3856ad364e35" culture="neutral" />
#    <bindingRedirect oldVersion="0.0.0.0-4.0.0.0" newVersion="3.0.1.0" />
#</dependentAssembly>
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#   <assemblyIdentity name="Microsoft.Owin.Security" publicKeyToken="31bf3856ad364e35" culture="neutral" />
#   <bindingRedirect oldVersion="0.0.0.0-4.0.0.0" newVersion="3.0.1.0" />
#</dependentAssembly>
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#   <assemblyIdentity name="Newtonsoft.Json" publicKeyToken="30ad4fe6b2a6aeed" culture="neutral" />
#   <bindingRedirect oldVersion="0.0.0.0-10.0.0.0" newVersion="9.0.0.0" />
#</dependentAssembly>
#<dependentAssembly xmlns="urn:schemas-microsoft-com:asm.v1">
#   <assemblyIdentity name="Owin" publicKeyToken="f0ebd12fd5e55cc5" culture="neutral" />
#   <bindingRedirect oldVersion="0.0.0.0-2.0.0.0" newVersion="1.0.0.0" />
#</dependentAssembly>
function AddSignalRSupport([Microsoft.SharePoint.Administration.SPWebApplication] $wa){    
    #create a new web config modification
    $addAssembly = new-object "Microsoft.SharePoint.Administration.SPWebConfigModification"
    $addAssembly.Path = "configuration/system.web/compilation/assemblies"
    $addAssembly.Name = "add[@assembly=`"PGC.SharePoint.MelhoresPraticas, Version=1.0.0.0, Culture=neutral, PublicKeyToken=9553f3d4b8592cc4`"]"
    $addAssembly.Sequence = 0
    $addAssembly.Owner = $owner
    $addAssembly.Type = 0
    $addAssembly.Value = "<add assembly=`"PGC.SharePoint.MelhoresPraticas, Version=1.0.0.0, Culture=neutral, PublicKeyToken=9553f3d4b8592cc4`" />"

    Write-Host -ForegroundColor Yellow "Adicionando configurações do SignalR"
    LogToFile ([System.String]::Format("Adicionando assembly dos hubs: `n {0}", $addAssembly.Value))
    
    #add our web config modification to the stack of mods that are applied
    $wa.WebConfigModifications.Add($addAssembly)
    $wa.Update()

    # dependent assembly section
    $dependentAssemblies = @(
        @{
            name = "Microsoft.AspNet.SignalR.Client";
            publicKeyToken="31bf3856ad364e35";
            oldVersion = "0.0.0.0-3.0.0.0";
            newVersion = "2.2.1.0";
        },
        @{
            name = "Microsoft.AspNet.SignalR.Core";
            publicKeyToken="31bf3856ad364e35";
            oldVersion = "0.0.0.0-3.0.0.0";
            newVersion = "2.2.1.0";
        },
        @{
            name = "Microsoft.AspNet.SignalR.SystemWeb";
            publicKeyToken="31bf3856ad364e35";
            oldVersion = "0.0.0.0-3.0.0.0";
            newVersion = "2.2.1.0";
        },
        @{
            name = "Microsoft.Owin";
            publicKeyToken="31bf3856ad364e35";
            oldVersion = "0.0.0.0-4.0.0.0";
            newVersion = "3.0.1.0";
        },
        @{
            name = "Microsoft.Owin.Host.SystemWeb";
            publicKeyToken="31bf3856ad364e35";
            oldVersion = "0.0.0.0-4.0.0.0";
            newVersion = "3.0.1.0";
        },
        @{
            name = "Microsoft.Owin.Security";
            publicKeyToken="31bf3856ad364e35";
            oldVersion = "0.0.0.0-4.0.0.0";
            newVersion = "3.0.1.0";
        },
        @{
            name = "Newtonsoft.Json";
            publicKeyToken="30ad4fe6b2a6aeed";
            oldVersion = "0.0.0.0-10.0.0.0";
            newVersion = "9.0.0.0";
        },
        @{
            name = "Owin";
            publicKeyToken="f0ebd12fd5e55cc5";
            oldVersion = "0.0.0.0-2.0.0.0";
            newVersion = "1.0.0.0";
        }
    )

    foreach($da in $dependentAssemblies){
        #create a new web config modification
        $dependentAssembly = New-Object "Microsoft.SharePoint.Administration.SPWebConfigModification"
        $dependentAssembly.Path = "configuration/runtime/*[local-name()=`"assemblyBinding`" and namespace-uri()=`"urn:schemas-microsoft-com:asm.v1`"]"
        $dependentAssembly.Name = [String]::Format(“*[local-name()=`"dependentAssembly`"][*/@name=`"{0}`"][*/@publicKeyToken=`"{1}`"][*/@culture=`"neutral`"]”, $da.name, $da.publicKeyToken)
        $dependentAssembly.Sequence = 0
        $dependentAssembly.Owner = $owner
        $dependentAssembly.Type = 0 #EnsureChildNode
        $dependentAssembly.Value = [String]::Format("<dependentAssembly><assemblyIdentity name=`"{0}`" publicKeyToken=`"{1}`" culture=`"neutral`" /><bindingRedirect oldVersion=`"{2}`" newVersion=`"{3}`" /></dependentAssembly>", $da.name, $da.publicKeyToken, $da.oldVersion, $da.newVersion)

        LogToFile ([System.String]::Format("Adicionando dependent assembly: `n {0}", $dependentAssembly.Value))

        #add our web config modification to the stack of mods that are applied
        $wa.WebConfigModifications.Add($dependentAssembly)
        $wa.Update()
    }

    # ensure <trust />
    $trust = New-Object "Microsoft.SharePoint.Administration.SPWebConfigModification"
    $trust.Name = "trust"
    $trust.Path = "configuration/system.web"
    $trust.Sequence = 0
    $trust.Owner = $owner
    $trust.Type = 0 #EnsureChildNode
    $trust.Value = "<trust level=`"Full`" originUrl=`"`" legacyCasModel=`"false`" />"

    #Write-Host -ForegroundColor Yellow ([String]::Format("Adding trust element: {0}", $trust.Value))
    LogToFile ([System.String]::Format("Adicionando trust level: `n {0}", $trust.Value))

    #add our web config modification to the stack of mods that are applied
    $wa.WebConfigModifications.Add($trust)
    $wa.Update()

    Write-Host -ForegroundColor Yellow "Configurações do SignalR adicionadas"
}


#set a few variables for the script
$owner = "PCG.MelhoresPraticas"

# get web app url from user
Write-Host "Por favor, informe a url da aplicação web (Ex. http://srv-01/ ): " -NoNewline -ForegroundColor Green 
$webappurl = Read-Host

#Get the web application we want to work with
$webapp = Get-SPWebApplication $webappurl

#get the Foundation Web Application Service (the one that puts the content web apps on servers)
$farmservices = $webapp.Farm.Services | Where { $_.TypeName -eq "Microsoft SharePoint Foundation Web Application" }

#get the list of existing web config modifications for our web app
$existingModifications = @();
$webapp.WebConfigModifications | Where-Object { $_.Owner -eq $owner } | ForEach-Object { $existingModifications = $existingModifications + $_}
#remove any modofications that match our owner value (i.e. strip out our old mods before we re-add them)
$existingModifications | ForEach-Object{ $webapp.WebConfigModifications.Remove($_) }

# add TIT framework
AddTITFramework $webapp

# add support to SignalR
AddSignalRSupport $webapp

#trigger the process of rebuildig the web config files on content web applications
$farmServices.ApplyWebConfigModifications()