#TODO: Make file downloads asynchronous
#TODO: Use checkver.ps1 from scoop to get the latest version from github to use in the template

$templateString = @"
{
    "version":  "v1.1.0",
    "license":  "MIT",
    "homepage":  "https://github.com/ryanoasis/nerd-fonts",
    "url":  [
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/%name.zip",
        "https://raw.githubusercontent.com/matthewjberger/scoop-nerd-fonts/master/scripts/install-nerd-fonts.ps1",
        "https://raw.githubusercontent.com/matthewjberger/scoop-nerd-fonts/master/scripts/uninstall-nerd-fonts.ps1"
    ],
    "hash":  [
        "%hash",
        "%installScriptHash",
        "%uninstallScriptHash"
    ],
    "checkver": "github",
    "autoupdate": "https://github.com/ryanoasis/nerd-fonts/releases/download/`$version/%name.zip",
    "installer": {
        "_comment": "install-nerd-fonts.ps1 installs all windows compatible nerd fonts in a given directory",
        "file": "install-nerd-fonts.ps1",
        "args": [
            "`$dir"
        ]
    },
    "uninstaller": {
        "_comment": "uninstall-nerd-fonts.ps1 uninstalls all windows compatible nerd fonts in a given directory",
        "file": "uninstall-nerd-fonts.ps1",
        "args": [
            "`$dir"
        ]
    }
}
"@

$fontNames = @(
    "3270",
    "AnonymousPro",
    "AurulentSansMono",
    "BitstreamVeraSansMono",
    "CodeNewRoman",
    "DejaVuSansMono",
    "DroidSansMono",
    "FantasqueSansMono",
    "FiraCode",
    "FiraMono",
    "Gohu",
    "Hack",
    "Hasklig",
    "HeavyData",
    "Hermit",
    "Inconsolata",
    "InconsolataGo",
    "Iosevka",
    "Lekton",
    "LiberationMono",
    "Meslo",
    "Monofur",
    "Monoid",
    "Mononoki",
    "MPlus",
    "ProFont",
    "ProggyClean",
    "RobotoMono",
    "ShareTechMono",
    "SourceCodePro",
    "SpaceMono",
    "Terminus",
    "Ubuntu",
    "UbuntuMono"
)

$scriptsDir = "$PSScriptRoot"
$manifestDir = "$scriptsDir\.."
$filesDir = "$scriptsDir\font_data"

New-Item $filesDir -type directory -Force | Out-Null

$client = New-Object System.Net.WebClient

$fontNames | ForEach-Object {
    $font = $_
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/$font.zip"

    $outputFilePath = "$filesDir\$font.zip"
    $installScriptFilePath = "$scriptsDir\install-nerd-fonts.ps1"
    $uninstallScriptFilePath = "$scriptsDir\uninstall-nerd-fonts.ps1"

    Write-Host "Downloading $url to `n$outputFilePath" -ForegroundColor Blue
    $client.DownloadFile($url, $outputFilePath)

    $fontZipFileHash = (Get-FileHash $outputFilePath).Hash.ToLower()
    $installScriptHash = (Get-FileHash $installScriptFilePath).Hash.ToLower()
    $uninstallScriptHash = (Get-FileHash $uninstallScriptFilePath).Hash.ToLower()

    $namedOutput = $templateString -replace "%name", $font
    $hashedOutput = $namedOutput -replace "%hash", $fontZipFileHash
    $hashedOutput = $hashedOutput -replace "%installScriptHash", $installScriptHash
    $hashedOutput = $hashedOutput -replace "%uninstallScriptHash", $uninstallScriptHash
    $hashedOutput | Out-File -FilePath "$manifestDir\$font.json" -Encoding utf8

    Remove-Item $outputFilePath

    Write-Host "Generated manifest for font: $font.ttf" -ForegroundColor Green
}

Remove-Item $filesDir -Force