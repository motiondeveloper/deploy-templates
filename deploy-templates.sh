#!/bin/bash

### Comand Line Interface for deploying new template files

# Styling Variables

bold=$(tput bold)
normal=$(tput sgr0)

# Helper Functions

emptyLine () {
    echo ""
}

h1 () {
    input="${1}"
    echo "${bold}==> ${input}${normal}"
}

h2 () {
    input="${1}"
    echo "${bold}${input}${normal}"
}

continuePrompt () {
    input="${1}"
    read -p "Press [return] to ${input}, or [cntrl+c] to abort"
}

# Installation Functions

syncFoldersWithPrompts () {

    # Inputs
    fromPath="${1}"
    intoPath="${2}"

    # Tell user what's going to happen
    emptyLine
    h1 "Syncing from:"
    echo "${fromPath}"
    h1 "Into:"
    echo "${intoPath}"

    # Wait for confirmation
    emptyLine
    emptyLine
    h2 "A dry run will be performed to ensure no files are synced incorrectly."
    continuePrompt "sync"

    # Sync dry run
    emptyLine
    rsync -ahv --progress --delete --dry-run --exclude=".*" --delete-excluded "${fromPath}" "${intoPath}"

    # Ask for confirmation of dry run before syncing
    emptyLine
    emptyLine
    h1 "Please review the dry run output and check for errors!"
    continuePrompt "sync"

    # Sync folders
    emptyLine
    h2 "Syncing..."
    rsync -ah --progress --delete --exclude=".*" --delete-excluded "${fromPath}" "${intoPath}"

    # Give confirmation
    emptyLine
    emptyLine
    h1 "Synced Folders!"
    emptyLine
}

createInstaller () {

    # Script Inputs
    installerPrefix="$1"
    versionNumber="$2"
    copyToMac="$3"
    templateName="$(tr '[:lower:]' '[:upper:]' <<< ${installerPrefix:0:1})${installerPrefix:1}"

    # Installer Files
    baseScript="./src/install-mogrt.bash"
    folderName="SBS ${installerPrefix}"
    changelog="./src/${installerPrefix}/changelog"
    templates="./src/${installerPrefix}/templates"
    configFile="./src/${installerPrefix}/installer.config"
    iconFile="./src/${installerPrefix}/icon.icns"

    # Platypus Settings
    appName="${templateName} Templates Installer"
    appType="Progress Bar"
    icon="${iconFile}"
    verion="${versionNumber}"
    author="SBS Creatove"
    bundledFiles="${changelog}|${templates}|${configFile}"
    indentifier="au.com.sbs"
    script="${baseScript}"
    outputFile="SBS ${templateName} Templates Installer v${versionNumber}.app"

    # Tell user what's about to happen
    emptyLine
    h1 "Creating ${templateName} Installer:"
    echo "${outputFile}"
    h2 "Templates:"
    echo "${templates}"
    h2 "Changelog"
    echo "${changelog}"
    emptyLine
    emptyLine
    continuePrompt "create installer"

    # Create Installer
    emptyLine
    h1 "Creating installer..."
    platypus -a "${appName}" -o "${appType}" -i "${icon}" -V "${version}" -u "${author}" -f "${bundledFiles}" -I "${indentifier}" -R "${script}" "./dist/${outputFile}"
    emptyLine
    
    if [[ ${copyToMac} == "y" ]]; then
        macInstallerFolder="/Volumes/01_SBS_2019/03_TEMPLATES/MOTION/Social_Video_Premiere_Template/Mac/"
        syncFoldersWithPrompts "./dist/${outputFile}" "${macInstallerFolder}"
    fi

    # Complete confirmation
    emptyLine
    emptyLine
    h1 "Created ${templateName} Installer!"
    emptyLine
}

# Main Input Prompts

h1 "SBS Templates Deployment"
echo "This script will guide you through the deployment of"
echo "new template files based on your answers to a few prompts"
emptyLine
continuePrompt "start"
clear

# Social Template Inputs
read -p "${bold}Deploy social templates?${normal} [y/n]: " deploySocial

    # Input Social Options
    if [[ "${deploySocial}" == "y" ]]; then
        read -p "   Export new installer app? [y/n]: " createSocialInstaller

        if [[ "${createSocialInstaller}" == "y" ]]; then
            read -p "   Social installer version number [x.x.x]: " socialVersion
            read -p "   Copy Installer to Mac delivery folder? [y/n]: " socialMacSync
        fi

        read -p "   Sync social templates into broadcast? [y/n]: " socialBroadcastSync
        read -p "   Sync social templates with Windows folder? [y/n]: " socialWindowsSync
    fi

# News Template Inputs
read -p "${bold}Deploy news templates?${normal} [y/n]: " deployNews

    # Input news Options
    if [[ "${deployNews}" == "y" ]]; then
        read -p "   Export news installer app? [y/n]: " createNewsInstaller
        
        if [[ "${createNewsInstaller}" == "y" ]]; then
            read -p "   News installer version number [x.x.x]: " newsVersion
            read -p "   Copy Installer to Mac delivery folder? [y/n]: " newsMacSync
        fi

        read -p "   Sync news templates with Windows folder? [y/n]: " newsWindowsSync
    fi

# Deploy Social

if [[ ${deploySocial} == "y" ]]; then

    # Feedback
    clear
    h1 "Deploying Social..."
    continuePrompt "continue"
    emptyLine

    socialTemplatesPath="./src/social/templates/"

    if [[ ${createSocialInstaller} == "y" ]]; then
        createInstaller "social" "${socialVersion}" "${socialMacSync}"
    fi

    if [[ ${socialBroadcastSync} == "y" ]]; then

        h2 "Deploying to broadcast folder"
        broadcastTemplatePath="/Volumes/01_SBS_2019/03_TEMPLATES/MOTION/_MOGRT Releases/Social/"
        syncFoldersWithPrompts "${socialTemplatesPath}" "${broadcastTemplatePath}"
    fi

    if [[ ${socialWindowsSync} == "y" ]]; then

        h2 "Deploying to Windows folder"
        windowsSocialTemplatesPath="/Volumes/01_SBS_2019/03_TEMPLATES/MOTION/Social_Video_Premiere_Template/Windows/SBS Social/"
        syncFoldersWithPrompts "${socialTemplatesPath}" "${windowsSocialTemplatesPath}"
    fi

fi

# Deploy News

if [[ ${deployNews} == "y" ]]; then

    # Feedback
    clear
    h1 "Deploying News..."
    continuePrompt "continue"
    emptyLine

    newsTemplatesPath="./src/news/templates/"

    if [[ ${createNewsInstaller} == "y" ]]; then
        createInstaller "news" "${newsVersion}" "${newsMacSync}"
    fi

    if [[ ${newsWindowsSync} == "y" ]]; then

        h2 "Deploying to Windows folder"
        windowsNewsTemplatesPath="/Volumes/01_SBS_2019/03_TEMPLATES/MOTION/Social_Video_Premiere_Template/Windows/SBS News/"
        syncFoldersWithPrompts "${newsTemplatesPath}" "${windowsNewsTemplatesPath}"
    fi
fi

emptyLine
h1 "Finished deploying templates!"