#!/bin/bash

### Comand Line Interface for deploying new template files

# Exit if any errors thrown
set -e

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
    continuePrompt "continue"

    # Sync dry run
    clear
    rsync -ahv --progress --delete --dry-run --exclude=".*" --delete-excluded "${fromPath}" "${intoPath}"

    # Ask for confirmation of dry run before syncing
    emptyLine
    emptyLine
    h1 "Please review the dry run output and check for errors!"
    continuePrompt "sync"

    # Sync folders
    clear
    h2 "Syncing..."
    rsync -ahq --progress --delete --exclude=".*" --delete-excluded "${fromPath}" "${intoPath}"

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
    author="SBS Creative"
    bundledFiles="${changelog}|${templates}|${configFile}"
    indentifier="au.com.sbs"
    script="${baseScript}"
    outputFile="SBS ${templateName} Templates Installer v${versionNumber}.app"

    # Tell user what's about to happen
    h1 "Creating ${templateName} Installer:"
    echo "${outputFile}"
    emptyLine
    h2 "Templates:"
    echo "${templates}"
    h2 "Changelog"
    echo "${changelog}"
    emptyLine
    emptyLine
    continuePrompt "create installer"

    # Create Installer
    clear
    h1 "Creating installer..."
    platypus -a "${appName}" -o "${appType}" -i "${icon}" -V "${version}" -u "${author}" -f "${bundledFiles}" -I "${indentifier}" -R "${script}" "./dist/${outputFile}"
    emptyLine
    h1 "Finished creating installer!"
    continuePrompt "continue"
    
    if [[ ${copyToMac} == "y" ]]; then
        clear
        h1 "Copying into Mac installers folder..."
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

# Loop through directories (template packages) in src

for directory in src/*/ ; do

  packageName="$(basename ${directory})"

  # Ask for template properties

  read -p "${bold}Deploy ${packageName} templates?${normal} [y/n]: " deployPackage

    # Input Social Options
    if [[ "${deployPackage}" == "y" ]]; then
        read -p "   Export new installer app? [y/n]: " createInstaller

        if [[ "${createInstaller}" == "y" ]]; then
            read -p "   Installer version number [x.x.x]: " versionNumber
            read -p "   Copy Installer to Mac delivery folder? [y/n]: " macSync
        fi

        read -p "   Sync templates into broadcast? [y/n]: " broadcastSync
        read -p "   Sync templates with Windows folder? [y/n]: " windowsSync
    fi

  # Create installer and copy to delivery locations

  if [[ ${deployPackage} == "y" ]]; then

    # Feedback
    clear
    h1 "Deploying ${packageName}..."
    continuePrompt "continue"
    clear

    templatesPath="./src/${packageName}/templates/"

    if [[ ${createInstaller} == "y" ]]; then
        createInstaller "${packageName}" "${versionNumber}" "${macSync}"
    fi

    if [[ ${broadcastSync} == "y" ]]; then

        h2 "Deploying to broadcast folder"
        broadcastTemplatePath="/Volumes/01_SBS_2019/03_TEMPLATES/MOTION/_MOGRT Releases/${packageName}/"
        syncFoldersWithPrompts "${templatesPath}" "${broadcastTemplatePath}"
    fi

    if [[ ${windowsSync} == "y" ]]; then

        h2 "Deploying to Windows folder"
        windowsTemplatesPath="/Volumes/01_SBS_2019/03_TEMPLATES/MOTION/Social_Video_Premiere_Template/Windows/SBS ${packageName}/"
        syncFoldersWithPrompts "${templatesPath}" "${windowsTemplatesPath}"
    fi

  fi

  clear

done

clear
emptyLine
h1 "Finished deploying templates!"
exit
