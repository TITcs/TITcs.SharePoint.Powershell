# clear screen
Clear-Host

# 1) source site
$sUrl = "http://SITE_URL"
$sAdmin = "USER"
$sPwd = "PASS"
$xmlFileSiteColumnsPath = "C:\spOnline\script-sitecolumns.xml"
$xmlFileContentTypesPath = "C:\spOnline\script-contenttypes.xml"

# 3) What Site Column Group do you want to synchronize?
$sGroupName1 = "GROUP 1"
$sGroupName2 = "GROUP 2"

$sSecurePwd = ConvertTo-SecureString $sPwd -AsPlainText -Force

# these aren't required for the script to run, but help to develop
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"

# connect/authenticate to SharePoint Online and get ClientContext object.. 
$sCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sUrl)
$sCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sAdmin, $sSecurePwd)
$sCtx.Credentials = $sCredentials

if (!$sCtx.ServerObjectIsNull.Value) 
{
    # show progress status
    Write-Host [System.String]::Format("connected to the SOURCE at the sharePoint online site: ", $sCtx.Url) -ForegroundColor Green

    # get context objects
    $sSite = $sCtx.Web
    $sCols = $sSite.AvailableFields
    $sCTypes = $sSite.AvailableContentTypes

    # load data
    $sCtx.Load($sCols)
    $sCtx.Load($sCTypes)

    # execute query
    $sCtx.ExecuteQuery()

    # show results
    Write-Host [System.String]::Format("Found {0} site columns", $sCols.Count) -ForegroundColor Cyan

    # create export files
    New-Item $xmlFileSiteColumnsPath -type file -force
    New-Item $xmlFileContentTypesPath -type file -force

    Add-Content $xmlFileSiteColumnsPath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
    Add-Content $xmlFileContentTypesPath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
    Add-Content $xmlFileSiteColumnsPath "`n<Fields>"
    Add-Content $xmlFileContentTypesPath "`n<ContenTypes>"

    foreach($sCol in $sCols)
    {
        if(($sCol.Group -eq $sGroupName1) -or ($sCol.Group -eq $sGroupName1))
        {
            # print static name
            Write-Host $sCol.StaticName -ForegroundColor Cyan

            # concat file
            Add-Content $xmlFileSiteColumnsPath $sCol.SchemaXml
        }
    }

    foreach($sCT in $sCTypes){
        if(($sCT.Group -eq $sGroupName1) -or ($sCT.Group -eq $sGroupName3))
        {
            # print static name
            Write-Host "CType: " $sCT.StaticName -ForegroundColor Blue

            # concat file
            Add-Content $xmlFileContentTypesPath $sCT.SchemaXml
        }
    }

    # add end to the file
    Add-Content $xmlFileSiteColumnsPath "</Fields>"
    Add-Content $xmlFileContentTypesPath "</ContenTypes>"
}

$sCtx.Dispose()