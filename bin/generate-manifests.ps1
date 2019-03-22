$templateString = @"
{
    "version": "0.0",
    "license": "MIT",
    "homepage": "https://github.com/ryanoasis/nerd-fonts",
    "url": " ",
    "hash": " ",
    "checkver": "github",
    "depends": "sudo",
    "autoupdate": {
        "url": "https://github.com/ryanoasis/nerd-fonts/releases/download/v`$version/%name.zip"
    },
    "installer": {
        "script": [
            "if(!(is_admin)) { error \"Admin rights are required, please run 'sudo scoop install `$app'\"; exit 1 }",
            "Get-ChildItem `$dir -filter '*Windows Compatible.*' | ForEach-Object {",
            "    New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts' -Name `$_.Name.Replace(`$_.Extension, ' (TrueType)') -Value `$_.Name -Force | Out-Null",
            "    Copy-Item \"`$dir\\`$_\" -destination \"`$env:windir\\Fonts\"",
            "}"
        ]
    },
    "uninstaller": {
        "script": [
            "if(!(is_admin)) { error \"Admin rights are required, please run 'sudo scoop uninstall `$app'\"; exit 1 }",
            "Get-ChildItem `$dir -filter '*Windows Compatible.*' | ForEach-Object {",
            "    Remove-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts' -Name `$_.Name.Replace(`$_.Extension, ' (TrueType)') -Force -ErrorAction SilentlyContinue",
            "    Remove-Item \"`$env:windir\\Fonts\\`$(`$_.Name)\" -Force -ErrorAction SilentlyContinue",
            "}",
            "Write-Host \"The '`$(`$app.Replace('-NF', ''))' Font family has been uninstalled and will not be present after restarting your computer.\" -Foreground Magenta"
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

# Generate manifests
$fontNames | ForEach-Object {
    $templateString -replace "%name", $_ | Out-File -FilePath "$PSScriptRoot\..\bucket\$_-NF.json" -Encoding utf8
}

# Use scoop's checkver script to autoupdate the manifests
& $psscriptroot\checkver.ps1 * -u

# Keep frozen files from updating
$frozenFiles = @(
    "CodeNewRoman-NF",
    "Gohu-NF"
)

$frozenFiles | ForEach-Object {
    git checkout "../bucket/$_.json"
}
