#Requires -RunAsAdministrator
param([String]$dir)

Get-ChildItem $dir -filter '*Windows Compatible.*' | ForEach-Object {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $_.Name.Replace($_.Extension, ' (TrueType)') -Value $_.Name -Force | Out-Null
    Copy-Item "$dir/$_" -destination "$env:windir\Fonts"
}