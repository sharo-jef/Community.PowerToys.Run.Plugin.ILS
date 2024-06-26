Param(
  [switch]$Docker = $False
)

$ErrorActionPreference = "Stop"

$Version = (Get-Content -Raw -Path "$PSScriptRoot\ILS\plugin.json" | ConvertFrom-Json).Version

if (Test-Path -Path "$PSScriptRoot\ILS\bin") {
  Remove-Item -Path "$PSScriptRoot\ILS\bin\*" -Recurse
}

if ($Docker) {
  docker run -v "${PSScriptRoot}:/app" -w /app mcr.microsoft.com/dotnet/sdk:8.0 dotnet build ILS.sln -c Release /p:Platform="Any CPU"
}
else {
  dotnet build $PSScriptRoot\ILS.sln -c Release /p:Platform="Any CPU"
}

Remove-Item -Path "$PSScriptRoot\ILS\bin\*" -Recurse -Include *.xml, *.pdb, PowerToys.*, Wox.* -ErrorAction SilentlyContinue
Rename-Item -Path "$PSScriptRoot\ILS\bin\Release" -NewName "ILS"

if (Test-Path -Path "$PSScriptRoot\ILS-$Version.zip") {
  Remove-Item -Path "$PSScriptRoot\ILS-$Version.zip"
}
Compress-Archive -Path "$PSScriptRoot\ILS\bin\ILS\net6.0-windows\*" -DestinationPath "$PSScriptRoot\ILS-$Version.zip"
