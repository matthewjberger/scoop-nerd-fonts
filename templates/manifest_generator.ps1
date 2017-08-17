#TODO: Make file downloads asynchronous
#TODO: Use checkver.ps1 from scoop to get the latest version from github to use in the template


function DownloadFile($url, $targetFile)
{
   $uri = New-Object "System.Uri" "$url"
   $request = [System.Net.HttpWebRequest]::Create($uri)
   $request.set_Timeout(15000) #15 second timeout
   $response = $request.GetResponse()
   $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
   $responseStream = $response.GetResponseStream()
   $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
   $buffer = new-object byte[] 10KB
   $count = $responseStream.Read($buffer,0,$buffer.length)
   $downloadedBytes = $count
   while ($count -gt 0)
   {
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
   }

   Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"
   $targetStream.Flush()
   $targetStream.Close()
   $targetStream.Dispose()
   $responseStream.Dispose()
}

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
    "hash":  "%hash",
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

$rootDir = "$PSScriptRoot\generated_files"
$manifestDir = "$rootDir\manifests"
$filesDir = "$rootDir\files"

New-Item $rootDir -type directory -Force
New-Item $manifestDir -type directory -Force
New-Item $filesDir -type directory -Force

$fontNames | ForEach-Object{
    $font = $_
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/$font.zip"
    $outputFile = "$filesDir\$font.zip"
    DownloadFile $url $outputFile
    $hash = (Get-FileHash $outputFile).Hash.ToLower()
    $namedOutput = $templateString -replace "%name", $font
    $hashedOutput = $namedOutput -replace "%hash", $hash
    $hashedOutput | Out-File -FilePath "$manifestDir\$font.json" -Encoding utf8
}