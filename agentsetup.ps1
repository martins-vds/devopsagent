param (
    [string]$URL,
    [string]$PAT,
    [string]$POOL,
    [string]$AGENT,
    [string]$AGENTTYPE
)

function setupazdevops {
    param(
        [string]$URL,
        [string]$PAT,
        [string]$POOL,
        [string]$AGENT
    )
    
        
    Write-Host "About to install components"
    Start-Transcript
    Write-Host "start"

    $ConfirmPreference = 'None'

    $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
    
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    $env:PATH += ";%ALLUSERSPROFILE%\chocolatey\bin" 
    
    choco install oraclejdk -y

    choco install nodejs.install -y

    Write-Host "About to setup Azure DevOps Agent"

    $azagentdir = "c:\agent"
    
    #test if an old installation exists, if so, delete the folder
    if (test-path $azagentdir) {
        
        Write-Host "clean out old directory"
        set-location $azagentdir
        $servicename = (Get-Content .service)
        Stop-Service $servicename -ErrorAction SilentlyContinue
        set-location 'c:\'
        Remove-Item -Path $azagentdir -Force -Confirm:$false -Recurse
    }
    
    Write-Host "create directory"
    #create a new folder
    new-item -ItemType Directory -Force -Path $azagentdir
    set-location $azagentdir
    $global:ProgressPreference = 'SilentlyContinue'
    $env:VSTS_AGENT_HTTPTRACE = $true
    
    #github requires tls 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $ProgressPreference = 'SilentlyContinue'
    #get the latest build agent version
    Write-Host "download agent"
    $wr = Invoke-WebRequest https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest -UseBasicParsing
    $tag = ($wr | ConvertFrom-Json)[0].tag_name
    $tag = $tag.Substring(1)
    
    write-host "$tag is the latest version"
    #build the url
    $download = "https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-win-x64-$tag.zip"
    
    #download the agent
    Invoke-WebRequest $download -Out agent.zip
    
    #expand the zip
    Expand-Archive -Path agent.zip -DestinationPath $PWD
    
    Write-Output "--unattended --url https://dev.azure.com/$URL --auth pat --token "$PAT" --pool $POOL --agent $AGENT --acceptTeeEula --runAsService"
    #run the config script of the build agent
    .\config.cmd --unattended --url https://dev.azure.com/$URL --auth pat --token "$PAT" --pool $POOL --agent $AGENT --acceptTeeEula --runAsService --replace
    
    Write-Host "About to start Azure DevOps Agent"
    set-location $azagentdir
    $servicename = (Get-Content .service)
    Start-Service $servicename -ErrorAction SilentlyContinue

    #exit
    Stop-Transcript
    exit 0
}

function setupghrunner {
    param(

        [string]$URL,
        [string]$PAT,
        [string]$POOL,
        [string]$AGENT
    )
    
    Start-Transcript

    Write-Host "About to setup GitHub Runner"
    $ghrunnerdirectory = "c:\actions-runner"

    #test if an old installation exists, if so, delete the folder
    if (test-path $ghrunnerdirectory) {
        set-location $ghrunnerdirectory
        $servicename = (Get-Content .service)
        Stop-Service $servicename -ErrorAction SilentlyContinue
        set-location 'c:\'
        Remove-Item -Path $ghrunnerdirectory -Force -Confirm:$false -Recurse
    }

    #create a new folder
    new-item -ItemType Directory -Force -Path $ghrunnerdirectory
    set-location $ghrunnerdirectory
    $global:ProgressPreference = 'SilentlyContinue'
    $env:VSTS_AGENT_HTTPTRACE = $true

    #github requires tls 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $ProgressPreference = 'SilentlyContinue'
    #get the latest build agent version
    $wr = Invoke-WebRequest https://api.github.com/repos/actions/runner/releases/latest -UseBasicParsing
    $tag = ($wr | ConvertFrom-Json)[0].tag_name
    $tag = $tag.Substring(1)

    write-host "$tag is the latest version"
    #build the url

    $download = "https://github.com/actions/runner/releases/download/v$tag/actions-runner-win-x64-$tag.zip"

    #download the agent
    Invoke-WebRequest $download -Out ghactionsrunner.zip

    #expand the zip
    Expand-Archive -Path ghactionsrunner.zip -DestinationPath $PWD


    #run the config script of the build agent
    set-location $ghrunnerdirectory
    .\config.cmd --unattended --url https://github.com/$URL  --token "$PAT"  --runnergroup $POOL  --replace --runasservice --replace

    #exit
    Stop-Transcript
    exit 0
}

Write-Output $URL
Write-Output $PAT
Write-Output $POOL
Write-Output $AGENT
Write-Output $AGENTTYPE

$ProgressPreference = 'SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

if ($AGENTTYPE.ToLower() -eq "azuredevops") {
    setupazdevops -URL $URL -PAT $PAT -POOL $POOL -AGENT $AGENT
}
else {
    setupghrunner -URL $URL -PAT $PAT -POOL $POOL -AGENT $AGENT
}
