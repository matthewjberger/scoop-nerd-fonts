# scoop-nerd-fonts bucket

#### Note: This does not completely work as is. Installing fonts manually on Windows has issues that will need to be addressed in the installation and uninstallation scripts.

This repo is an attempt at creating an installer/uninstaller for nerd-fonts in the form of a [scoop package manager](https://github.com/lukesampson/scoop) bucket.

[This is discussed on the issue tracker for the scoop package manager](https://github.com/lukesampson/scoop-extras/pull/500).

The installation and uninstallation scripts need to be tweaked to properly install and uninstall fonts, but the manifests can be generated for each of the nerd-fonts programmatically using the [generate-manifests.ps1](https://github.com/matthewjberger/scoop-nerd-fonts/blob/master/bin/generate-manifests.ps1) script in this repository.
