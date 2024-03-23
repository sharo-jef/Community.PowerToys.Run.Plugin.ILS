Param(
  [parameter(Mandatory = $true)][string]$ActionKeyword,
  [parameter(Mandatory = $true)][string]$Author,
  [parameter(Mandatory = $true)][string]$ProjectName,
  [string]$DotnetVersion = "net6.0-windows"
)

$ErrorActionPreference = "Stop"

if (Test-Path "$ProjectName.sln") {
  Write-Error "Solution already exists"
  exit 1
}

$Guid1 = [guid]::NewGuid().ToString().ToUpper()
$Guid2 = 'EA8F0A99-3F15-4C5E-9A98-0F308C467CD2'
$PluginId = [guid]::NewGuid().ToString().ToUpper() -replace '-', ''

# Generate .sln
Write-Output "Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.2.32519.379
MinimumVisualStudioVersion = 10.0.40219.1
Project(`"{$Guid1}`") = `"$ProjectName`", `"$ProjectName\$ProjectName.csproj`", `" {$Guid2}`"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{$Guid2}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{$Guid2}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{$Guid2}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{$Guid2}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
		SolutionGuid = {$Guid2}
	EndGlobalSection
EndGlobal
" | Tee-Object -FilePath "$ProjectName.sln"

# Generate project
New-Item -ItemType Directory -Path "$PSScriptRoot\$ProjectName"
dotnet new classlib -n $ProjectName -o "$PSScriptRoot\$ProjectName"
Remove-Item -Path "$PSScriptRoot\$ProjectName\*.cs"

# Generate .csproj
Write-Output "<Project Sdk=`"Microsoft.NET.Sdk`">

<PropertyGroup>
  <TargetFramework>$DotnetVersion</TargetFramework>
  <useWPF>true</useWPF>
  <ImplicitUsings>enable</ImplicitUsings>
  <Nullable>enable</Nullable>
  <EnableWindowsTargeting>true</EnableWindowsTargeting>
</PropertyGroup>

<ItemGroup>
  <Reference Include=`"PowerToys.Common.UI`">
    <HintPath>..\libs\PowerToys.Common.UI.dll</HintPath>
  </Reference>
  <Reference Include=`"PowerToys.ManagedCommon`">
    <HintPath>..\libs\PowerToys.ManagedCommon.dll</HintPath>
  </Reference>
  <Reference Include=`"Wox.Infrastructure`">
    <HintPath>..\libs\Wox.Infrastructure.dll</HintPath>
  </Reference>
  <Reference Include=`"Wox.Plugin`">
    <HintPath>..\libs\Wox.Plugin.dll</HintPath>
  </Reference>
</ItemGroup>

<ItemGroup>
  <!-- <None Update=`"images\icon.png`">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
  </None> -->
  <None Update=`"plugin.json`">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
  </None>
</ItemGroup>
</Project>" | Tee-Object -FilePath "$PSScriptRoot\$ProjectName\$ProjectName.csproj"

# Generate Main.cs
Write-Output "using System.Windows;
using Wox.Plugin;

namespace PowerToysRunPluginSample
{
    public class Main : IPlugin
    {
        private PluginInitContext? context { get; set; }

        public string Name => `"$ProjectName`";

        public string Description => `"`";

        public static string PluginID => `"$PluginId`";

        public List<Result> Query(Query query)
        {
            return new List<Result>
            {
                new Result
                {
                    Title = `"Item1`",
                    SubTitle = `"Item1 Subtitle`",
                    Action = e =>
                    {
                        Clipboard.SetText(`"Item1`");
                        return true;
                    },
                },
            };
        }

        public void Init(PluginInitContext context)
        {
            this.context = context;
        }
    }
}" | Tee-Object -FilePath "$PSScriptRoot\$ProjectName\Main.cs"

# Generate plugin.json
Write-Output "{
  `"ID`": `"$PluginId`",
  `"Disabled`": false,
  `"ActionKeyword`": `"$ActionKeyword`",
  `"Name`": `"$ProjectName`",
  `"Author`": `"$Author`",
  `"Version`": `"0.0.1`",
  `"Language`": `"csharp`",
  `"Website`": `"WEB_SITE_URL`",
  `"ExecuteFileName`": `"$ProjectName.dll`",
  `"IsGlobal`": false
}" | Tee-Object -FilePath "$PSScriptRoot\$ProjectName\plugin.json"

# Generate build script
Write-Output "`$ErrorActionPreference = `"Stop`"

`$Version = `"0.0.1`"

if (Test-Path -Path `"`$PSScriptRoot\$ProjectName\bin`") {
  Remove-Item -Path `"`$PSScriptRoot\$ProjectName\bin\*`" -Recurse
}

dotnet build `$PSScriptRoot\$ProjectName.sln -c Release /p:Platform=`"Any CPU`"

Remove-Item -Path `"`$PSScriptRoot\$ProjectName\bin\*`" -Recurse -Include *.xml, *.pdb, PowerToys.*, Wox.*
Rename-Item -Path `"`$PSScriptRoot\$ProjectName\bin\Release`" -NewName `"$ProjectName`"

if (Test-Path -Path `$PSScriptRoot\$ProjectName-`$Version.zip) {
  Remove-Item -Path `$PSScriptRoot\$ProjectName-`$Version.zip
}
Compress-Archive -Path `"`$PSScriptRoot\$ProjectName\bin\$ProjectName\$DotnetVersion`" -DestinationPath `"`$PSScriptRoot\$ProjectName-`$Version.zip`"
" | Tee-Object -FilePath "$PSScriptRoot\Build-Solution.ps1"
