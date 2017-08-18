param([String]$dir)

$Shell = New-Object -ComObject Shell.Application
$SystemFontsFolder = $Shell.Namespace(0x14)
$SystemFontsPath = $SystemFontsFolder.Self.Path
$Fonts = Get-ChildItem $dir -Filter "*Windows Compatible*"

foreach($Font in $Fonts)
{
    $targetPath = Join-Path $SystemFontsPath $Font.Name
    if(Test-Path $targetPath)
    {
        Write-Host -fore blue "Uninstalling $Font.Name"
        Remove-Item $targetPath -Force
    }
}