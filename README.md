# Scoop bucket for Nerd Fonts

This repo contains manifests for installing Nerd Fonts and various other fonts using the [scoop package manager](https://github.com/lukesampson/scoop) for Windows.

To add this bucket:

```
scoop bucket add nerd-fonts
```

#### Note: Admin rights are required to install these fonts, because their installers modify the registry. Additionally, restarting your computer after uninstalling a font is necessary for the font to be fully removed.

## Generating font manifests

Execute `bin/generate-manifests.ps1` with Powershell 3.0+ to regenerate all of the manifests in this repository from the template (within the same file).

## Notable changes

The regular `CascadiaCode` (not NF) font manifests were [consolidated into a single manifest](https://github.com/matthewjberger/scoop-nerd-fonts/commit/e8c7114a2890a2d7ca035c132f4bb507a191a423). This was done because the [Cascadia Code official releases](https://github.com/microsoft/cascadia-code/releases) prior to `2004.30` had the ttf fonts attached separately, so they had different download urls. From version `2004.30` onward, the fonts are bundled in a zip file.
