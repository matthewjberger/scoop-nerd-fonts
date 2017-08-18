param([String]$dir)

$Shell = New-Object -ComObject Shell.Application
$SystemFontsFolder = $Shell.Namespace(0x14)
$Fonts = $Shell.Namespace($dir).Items()
$Fonts.Filter(64, '*Windows Compatible.*')
$SystemFontsFolder.CopyHere($Fonts)