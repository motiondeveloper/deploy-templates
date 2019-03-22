<!-- Links -->
[Platypus]: https://sveinbjorn.org/platypus
[Platypus Docs]: https://sveinbjorn.org/files/manpages/PlatypusDocumentation.html
[Back To Top ↑]: #overview

<div align="center">

![Installer Icon](docs/static/installer-icon.png)

# Deploy Templates CLI

Command line tool to deploy the SBS Motion Graphics Templates

**[Overview](#overview) | [Updating the Files](#updating-the-files) | [Using the CLI](#using-the-cli) | [How It Works](#how-it-works)**

</div>

## Overview

The deploy templates CLI automates the process of deploying any changes made to the SBS templates, across the various files and installers used across the business.

This consists of:

1. Creating new installer apps with the new bundled templates and changelogs
2. Copying the installers into the appropriate directories on the server
3. Syncing the template files with the neccesary server locations

These steps are done based on the files in the folder structure, as well as user input to the command line prompts.

[Back To Top ↑]

## Dependancies

To create the installers, the [Platypus] command line interface must be installed. For more info on installing [Platypus] and it's CLI, see the [How it works](#how-it-works) section.

[Back To Top ↑]

## Updating the files

<details><summary>Project File Structure</summary>
<p>

The CLI works on assumptions about the file structure of project, and so any changes made to the files must be done within this specific structure.

```files
base-folder
├── deploy-templates.sh
├── dist
│   └── installerName.app
├── LICENSE
├── README.md
├── src
│   ├── template-package-name
│   │   ├── changelog
|   |   |   ├── index.html
|   |   |   └── main.css
│   │   ├── icon.icns
│   │   ├── installer.config
│   │   ├── templates
│   │   |   └── mogrt-files
```

The files that are distrubuted are located in the `src/` folder, with a sub folder for each package, e.g. `src/news` and `src/social`. All the templates and installer properties are contained within each of these package folders.

</p>
</details>

<details><summary>Versioning System</summary>
<p>

The installers, changelog and templates are versioned according to the [Semantic Versioning System](https://semver.org/).

</p>
</details>

<details><summary>Creating New Packages</summary>
<p>

### Creating new packages

The CLI is currently configured to deploy two template packages, **SBS News** and **SBS Social**. A new package may be added by duplicating an existing package, renaming it, and modifying the following files:

- `package-name/changelog/index.html`

    The changelog should be changed to reflect the version history of the new package.

- `package-name/icon.icns`

    The icon file for the installer.

- `package-name/installer.config`

    This contains the package specific configuration for it's installer, and the `folderName` variable in this file should be updated to reflect the folder name of the installed templates, e.g. `SBS Radio`.

- `package-name/templates/`

    The template files for the new package should be placed into this folder.

</p>
</details>

### Updating the templates

The templates files for each package are located in `src/package-name/templates/`, with the directory strucure in this folder being copied over into the `Essential Graphics` folder of the end user.

- To add a new template to the package, it just needs to be added to this folder
- To update an existing template, the old one can be replaced with the updated `.mogrt` with an incremented version number.

During the installation to the end users `Essential Graphics` folder, old versions of the templates are deleted to match the source directory structure.

There is currently a sub folder for each aspect ratio provided, e.g. `src/social/templates/1x1/1x1_Bug_1.0.1.mogrt`.

### Updating the changelogs

The changelog site is bundled with each installer, and is located in the `src/package-name/changelog/` directory.

Any updates made to the template files should be documented in the `index.html` file for the respective package changelog.

> The changelogs may soon be updated to source from a Markdown file hosted in this projects Github repository, rather than bundled with the installer. This file will be updated to reflect those changes if this is the case.

[Back To Top ↑]

## Using the CLI

> The following instructions are commands to be run in a mac terminal emulator, such as the macOS `Terminal.app`.

![CLI Screencast](docs/static/deploy-templates-cli.gif)

1. Change to the deploy templates folder, e.g. `'/Users/username/Desktop/mogrt-installer'`

    ```shell
    cd path/to/folder
    ```

2. Run the deploy templates script

    ```shell
    bash ./deploy-templates.sh
    ```

3. Follow the prompts to deploy the templates