$templateString = @"
{
    "version":  "",
    "license":  "MIT",
    "homepage":  "https://github.com/ryanoasis/nerd-fonts",
    "url": "%url",
    "hash":  "",
    "checkver": "github",
    "autoupdate": {
        "url": "https://github.com/ryanoasis/nerd-fonts/releases/download/v`$version/%name.zip"
    },
    "installer": {
        "script": "
            Get-ChildItem `$dir -filter '*Windows Compatible.*' | ForEach-Object {
                New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts' -Name `$_.Name.Replace(`$_.Extension, ' (TrueType)') -Value `$_.Name -Force | Out-Null
                Copy-Item \"`$dir\\`$_\" -destination \"`$env:windir\\Fonts\"
            }
        "
    },
    "uninstaller": {
        "script": "
            Get-ChildItem `$dir -filter '*Windows Compatible.*' | ForEach-Object {
                Remove-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts' -Name `$_.Name.Replace(`$_.Extension, ' (TrueType)') -Force -ErrorAction SilentlyContinue
                Remove-Item \"`$env:windir\\Fonts\\`$(`$_.Name)\" -Force -ErrorAction SilentlyContinue
            }
        "
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
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/$_.zip"
    $output = $templateString -replace "%name", $_
    $output = $output -replace "%url", $url
    $output | Out-File -FilePath "$PSScriptRoot\..\$_-NF.json" -Encoding utf8
}

# Use scoop's checkver script to autoupdate the manifests
& ./checkver.ps1 * -u
