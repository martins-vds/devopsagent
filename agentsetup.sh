#!/bin/bash

# Parameters
URL=$1
PAT=$2
POOL=$3
AGENT=$4
AGENTTYPE=$5

setup_az_devops() {
    URL=$1
    PAT=$2
    POOL=$3
    AGENT=$4

    echo "About to install components"

    # Install Azure CLI
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    # Install JDK and Node.js
    sudo apt-get update

    # installing other dependencies
    sudo apt-get install -y openjdk-17-jdk

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

    apt-cache policy docker-ce -y

    sudo apt install docker-ce -y

    sudo apt-get install -y build-essential python3

    sudo usermod -aG docker LabUser

    sudo apt install nodejs -y

    sudo apt install npm -y

    sudo apt  install jq -y

    newgrp docker

    sudo apt install apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   
    download="https://raw.githubusercontent.com/microsoft/GHAzDO-Resources/main/src/agent-setup/codeql-install-ubuntu.sh"
    curl -L $download -o codeql-install-ubuntu.sh

    sudo +x codeql-install-ubuntu.sh

    ./codeql-install-ubuntu.sh
    
    echo "About to setup Azure DevOps Agent"

    echo "Creating directory"
    sudo mkdir -p "/agent"
    sudo mkdir -p "/agent1"
    sudo mkdir -p "/agent2"
    sudo mkdir -p "/agent3"
    sudo mkdir -p "/agent4"                
    cd "/agent"

    # Get the latest build agent version
    echo "Downloading agent"
    tag=$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep tag_name | head -1 | sed -E 's/.*"v([^"]+)".*/\1/')
    echo "$tag is the latest version"
    download="https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-linux-x64-$tag.tar.gz"
    curl -L $download -o agent.tar.gz

    # Expand the tarball
    tar -zxvf agent.tar.gz

    # Run the config script of the build agent
    echo "Configuring the Azure DevOps Agent"

    sudo -u LabUser ./config.sh --unattended --url "https://dev.azure.com/$URL" --auth pat --token "$PAT" --pool "$POOL" --agent "$AGENT" --acceptTeeEula --runAsService --replace

    echo "About to start Azure DevOps Agent"

    sudo ./svc.sh install
    sudo ./svc.sh start

    cd /agent1

    # Get the latest build agent version
    echo "Downloading agent"
    tag=$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep tag_name | head -1 | sed -E 's/.*"v([^"]+)".*/\1/')
    echo "$tag is the latest version"
    download="https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-linux-x64-$tag.tar.gz"
    curl -L $download -o agent.tar.gz

    # Expand the tarball
    tar -zxvf agent.tar.gz

    echo "Configuring the Azure DevOps Agent 1"

    sudo -u LabUser ./config.sh --unattended --url "https://dev.azure.com/$URL" --auth pat --token "$PAT" --pool "$POOL" --agent "${AGENT}1" --acceptTeeEula --runAsService --replace

    echo "About to start Azure DevOps Agent 1"

    sudo ./svc.sh install
    sudo ./svc.sh start

    cd /agent2

    # Get the latest build agent version
    echo "Downloading agent"
    tag=$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep tag_name | head -1 | sed -E 's/.*"v([^"]+)".*/\1/')
    echo "$tag is the latest version"
    download="https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-linux-x64-$tag.tar.gz"
    curl -L $download -o agent.tar.gz

    # Expand the tarball
    tar -zxvf agent.tar.gz

    echo "Configuring the Azure DevOps Agent 2"

    sudo -u LabUser ./config.sh --unattended --url "https://dev.azure.com/$URL" --auth pat --token "$PAT" --pool "$POOL" --agent "${AGENT}2" --acceptTeeEula --runAsService --replace

    echo "About to start Azure DevOps Agent 2"

    sudo ./svc.sh install
    sudo ./svc.sh start

    cd /agent3

    # Get the latest build agent version
    echo "Downloading agent"
    tag=$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep tag_name | head -1 | sed -E 's/.*"v([^"]+)".*/\1/')
    echo "$tag is the latest version"
    download="https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-linux-x64-$tag.tar.gz"
    curl -L $download -o agent.tar.gz

    # Expand the tarball
    tar -zxvf agent.tar.gz

    echo "Configuring the Azure DevOps Agent 3"

    sudo -u LabUser ./config.sh --unattended --url "https://dev.azure.com/$URL" --auth pat --token "$PAT" --pool "$POOL" --agent "${AGENT}3" --acceptTeeEula --runAsService --replace

    echo "About to start Azure DevOps Agent 3"

    sudo ./svc.sh install
    sudo ./svc.sh start

    cd /agent4

    # Get the latest build agent version
    echo "Downloading agent"
    tag=$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep tag_name | head -1 | sed -E 's/.*"v([^"]+)".*/\1/')
    echo "$tag is the latest version"
    download="https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-linux-x64-$tag.tar.gz"
    curl -L $download -o agent.tar.gz

    # Expand the tarball
    tar -zxvf agent.tar.gz

    echo "Configuring the Azure DevOps Agent 4"

    sudo -u LabUser ./config.sh --unattended --url "https://dev.azure.com/$URL" --auth pat --token "$PAT" --pool "$POOL" --agent "${AGENT}4" --acceptTeeEula --runAsService --replace

    echo "About to start Azure DevOps Agent 4"

    sudo ./svc.sh install
    sudo ./svc.sh start

    sudo chown -R LabUser /agent/
    sudo chown -R LabUser /agent1/
    sudo chown -R LabUser /agent2/
    sudo chown -R LabUser /agent3/
    sudo chown -R LabUser /agent4/
}

echo "Parameters: URL=$URL, PAT=$PAT, POOL=$POOL, AGENT=$AGENT, AGENTTYPE=$AGENTTYPE"

setup_az_devops $URL $PAT $POOL $AGENT
