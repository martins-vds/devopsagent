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

    sudo apt install apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "About to setup Azure DevOps Agent"
    azagentdir="/agent"

    # Test if an old installation exists, if so, delete the folder
    if [ -d "$azagentdir" ]; then
        echo "Cleaning out old directory"
        cd $azagentdir
        servicename=$(cat .service)
        sudo systemctl stop $servicename
        cd /
        sudo rm -rf $azagentdir
    fi

    echo "Creating directory"
    sudo mkdir -p $azagentdir
    cd $azagentdir

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

    # installing other dependencies
    sudo apt-get install -y openjdk-11-jdk

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

    apt-cache policy docker-ce -y

    sudo apt install docker-ce -y

    sudo -u LabUser curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    export NVM_DIR="LabUser/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    nvm install v20.11.0

    npm install -g npm@6.14.4

    sudo usermod -aG docker LabUser

    newgrp docker

}

echo "Parameters: URL=$URL, PAT=$PAT, POOL=$POOL, AGENT=$AGENT, AGENTTYPE=$AGENTTYPE"

setup_az_devops $URL $PAT $POOL $AGENT
