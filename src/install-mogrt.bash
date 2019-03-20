#!/bin/bash

# ------------ README ---------------------------------------
#
#   Mogrt Installer for the social graphics used across SBS
#
#   All templates are located within the installer and 
#   copied out during the installation. New versions of
#   the installer must be delivered with each update
#   of the templates, with only the changed files
#   being copied over.
#
#   The installer is a simple app built using Platypus
#   than runs this script when opened, with a simple
#   interface. Any command outputs are shown in this
#   interface.
#
# -----------------------------------------------------------

#   COMANDS USED
#   ------------
#
#   osascript -> Run Applescript, used to display alerts and notifications
#   rm -> Deletes files and folders
#   rsync -> Syncs files between two locations
# 
#   More info on each of these comands can be read by typing in 'man command' into terminal
#   For resources on writing bash scripts, check out: Bash Syntax Cheetsheet - https://devhints.io/bash

# Function to append a string to a file for writing logs
function writeLineToFile () {
  echo "$1" >> "$2"
}

# Path to the app resources
appContentFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Installer config file
configFile="${appContentFolder}/installer.config"

# Set source ton config file to inherit variables
. "${configFile}"

# Template Variables
# List of folders to install templates in for CC verions
declare -a templateFolderNames=("Essential Graphics" "Motion Graphics Templates")
# Where to copy the templates out of
templatesSourceFolder="${appContentFolder}/templates/"
# Path to the changelog site
changelogSite="${appContentFolder}/changelog/index.html"
# Name of folder to install templates into, sourced from config file
installFolder="${folderName}"
 
# Enables extended glob syntax (*)
shopt -s extglob

# Ask the user if they've closed Premiere
osascript -e 'tell app "System Events" to display dialog "Have you closed Premiere?" buttons {"Yes", "No"} default button "Yes" cancel button "No"'

if [[ $? -ne 0 ]]; then
  # If they responeded no, show alert
  osascript -e 'tell app "System Events" to display dialog "Please close Premiere before running the installer!"'
else
  # They responded yes, so we install the templates
  echo "Finding existing templates..."

  # Error variables
  error=false
  foundSomeFolders=false
  # Log file
  errorLog="${appContentFolder}/log.txt"

  # Create error log header for this install
  writeLineToFile "-----" "${errorLog}"
  writeLineToFile "Social Template Installer Log" "${errorLog}"
  writeLineToFile "$(date)" "${errorLog}"
  writeLineToFile "-----" "${errorLog}"
  writeLineToFile "" "${errorLog}"

  # Loops through folder list and installs templates in each folder
  for folderName in "${templateFolderNames[@]}"
  do
    currentTemplateFolder="Library/Application Support/Adobe/Common/${folderName}"
    # Checks to see if folder exists, if it does install templates into it
    if [[ -d  ~/"${currentTemplateFolder}" ]]; then

      foundSomeFolders=true

      # Navigate into folder
      cd ~/"${currentTemplateFolder}"

      # Deletes files
      rmOut="$( rm -rf !(*.txt|SBS*) 2>&1 )"
      if [[ $? -ne 0 ]]; then
        writeLineToFile "Error: Failed to delete default templates in ${folderName}" "${errorLog}"
        writeLineToFile "" "${errorLog}"
        writeLineToFile "rm Output:" "${errorLog}"
        writeLineToFile "${rmOut}" "${errorLog}"
        error=true
      else
        writeLineToFile "Success: Deleted default templates in ${folderName}" "${errorLog}"
      fi

      echo "Installing SBS templates in ${folderName}..."

      # Syncs files
      rsyncOut="$( rsync -avhq --delete "${templatesSourceFolder}" "${installFolder}/" 2>&1 )"
      if [[ $? -ne 0 ]]; then
        writeLineToFile "Error: Failed to copy template files into ${folderName}" "${errorLog}"
        writeLineToFile "" "${errorLog}"
        writeLineToFile "rsync Output:" "${errorLog}"
        writeLineToFile "${rsyncOut}" "${errorLog}"
        error=true
      else
        writeLineToFile "Success: Synced Templates in ${folderName}" "${errorLog}"
      fi

    fi

    # Didn't find any folders in the list to install into
    if [ "${foundsomeFolders}" = false ]; then
      error=true
      writeLineToFile "Error: No template folders found. Maybe Premiere is not installed?" "${errorLog}"
    fi

    # Add empty line to log
    writeLineToFile "" "${errorLog}"

  done

  if [ "${error}" = false ]; then
    # If some templates were installed, Display OS Notification
    osascript -e 'display notification "Finished updating SBS Motion Graphics Templates" with title "Installation Complete"'
    echo 'Finished installing templates!'

    # Show the view changes dialog
    osascript -e 'tell app "System Events" to display dialog "Finished installing templates!" buttons {"View Changes", "Quit"} default button "View Changes" cancel button "Quit"'
    if [[ $? -ne 1 ]]; then
      # If they pressed yes, open the changelog site
      open "${changelogSite}"
    fi

  else
    # There was an error during the install
    echo 'Oops! There were some errors'
    # Display error dialog
    osascript -e 'tell app "System Events" to display dialog "There were some errors during the installation, please contact the creative team with a copy of the log." with title "Error installing templates" with icon 2 buttons {"View Log"} default button "View Log"'
    # Open the error log file with the default editor
    open -t "${errorLog}"
  fi
fi