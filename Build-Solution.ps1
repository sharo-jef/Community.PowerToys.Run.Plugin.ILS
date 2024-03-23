$ErrorActionPreference = "Stop"

$Version = (Get-Content -Raw -Path "$PSScriptRoot\ILS\plugin.json" | ConvertFrom-Json).Version

if (Test-Path -Path "$PSScriptRoot\ILS\bin") {
  Remove-Item -Path "$PSScriptRoot\ILS\bin\*" -Recurse
}

dotnet build $PSScriptRoot\ILS.sln -c Release /p:Platform="Any CPU"

Remove-Item -Path "$PSScriptRoot\ILS\bin\*" -Recurse -Include *.xml, *.pdb, PowerToys.*, Wox.*
Rename-Item -Path "$PSScriptRoot\ILS\bin\Release" -NewName "ILS"

if (Test-Path -Path $PSScriptRoot\ILS-$Version.zip) {
  Remove-Item -Path $PSScriptRoot\ILS-$Version.zip
}
Compress-Archive -Path "$PSScriptRoot\ILS\bin\ILS\net6.0-windows\*" -DestinationPath "$PSScriptRoot\ILS-$Version.zip"
