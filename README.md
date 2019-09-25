# Scoop bucket for Nerd Fonts

This repo contains manifests for installing Nerd Fonts and various other fonts using the [scoop package manager](https://github.com/lukesampson/scoop) for Windows.

To add this bucket:

```
scoop bucket add nerd-fonts
```

#### Note: Admin rights are required to install these fonts, because their installers modify the registry. Additionally, restarting your computer after uninstalling a font is necessary for the font to be fully removed.

## Generating font manifests

Execute `bin/generate-manifests.ps1` with Powershell 3.0+ to regenerate all of the manifests in this repository from the template (within the same file).
