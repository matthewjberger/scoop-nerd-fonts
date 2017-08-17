param([String]$dir)

$Shell = New-Object -ComObject Shell.Application
$SystemFontsFolder = $Shell.Namespace(0x14)
$SystemFontsPath = $Shell.Namespace(0x14)
$Fonts = Get-ChildItem $dir -Filter "*Windows Compatible*"

foreach($Font in $Fonts)
{
    $targetPath = Join-Path $SystemFontsPath $Font.Name
    if(Test-Path $targetPath)
    {
        Remove-Item $targetPath -force
        Copy-Item $Font.FullName $targetPath -Force
    }
    else
    {
        $SystemFontsFolder.CopyHere($Font.FullName)
    }
}
