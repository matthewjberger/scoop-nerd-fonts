#Requires -RunAsAdministrator
param([String]$dir)

Get-ChildItem $dir -filter '*Windows Compatible.*' | ForEach-Object {
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $_.Name.Replace($_.Extension, ' (TrueType)') -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:windir\Fonts\$($_.Name)" -Force -ErrorAction SilentlyContinue
}