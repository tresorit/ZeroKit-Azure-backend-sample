## Re-generate project file after npm build
# Check npm
if ((Get-Command "npm" -ErrorAction SilentlyContinue) -eq $null) 
{ 
    Write-Error "Unable to find npm in your PATH"
	exit -1
}
Write-Host -ForegroundColor Green "> NPM found"

# Check submodule by checking existance of main js sript
if ( -Not (Test-Path "$PSScriptRoot\..\app\bin\www"))
{
	Write-Error "Please check out and update submodules before build!"
	exit -1
}

# Install npm modules
Write-Host -ForegroundColor Green "> Installing NPM modules for GIT submodule"
$oldPath = (Get-Location).Path
$appPath = Resolve-Path "$PSScriptRoot\..\app"
cd $appPath
npm install --silent --prefix $appPath

if (-Not $?)
{
	cd $oldPath
	Write-Error "NPM package install failed, aborting!!"
	exit -1
}
Write-Host -ForegroundColor Green "> NPM packages are up-to-date"
cd $oldPath

# Read template project file
Write-Host -ForegroundColor Green "> Updating project file with submodule / NPM changes"
[Xml]$xml = Get-Content -Path "$PSScriptRoot\ZeroKitNodejsSample.njsproj.template"

$after = $xml.Project.ChildNodes | ?{$_.Name -match "^ItemGroup$" } | Select-Object -Last 1

# Preapre file replacement prefix
$prefix = Resolve-Path "$PSScriptRoot\..\"

# Get app folders to add
$folders = $xml.CreateElement("ItemGroup", $xml.Project.NamespaceURI)

Get-ChildItem "$PSScriptRoot\..\app\" -Recurse | ?{ $_.PSIsContainer} | ?{ $_.FullName -notmatch ".*\\(test|node_modules)(\\.*)?" }  | ForEach-Object {
	 $name = $_.FullName.Replace($prefix,"").TrimStart('\');
	 $folder = $xml.CreateElement("Folder", $xml.Project.NamespaceURI);
	 $attr = $xml.CreateAttribute("Include");
	 $dump = $folder.Attributes.Append($attr);
	 $dump = $folder.SetAttribute("Include", $name);
	 $dump = $folder.RemoveAttribute("xmlns")
	 $dump = $folders.AppendChild($folder);
}

$dump = $folders.RemoveAttribute("xmlns")
$dump = $xml.Project.InsertAfter($folders, $after)
$after = $folders

# Get npm folders to add
$folders = $xml.CreateElement("ItemGroup", $xml.Project.NamespaceURI)

Get-ChildItem "$PSScriptRoot\..\app\" -Recurse | ?{ $_.PSIsContainer} | ?{ $_.FullName -match ".*\\(node_modules)(\\.*)?" }  | ForEach-Object {
	 $name = $_.FullName.Replace($prefix,"").TrimStart('\');
	 $folder = $xml.CreateElement("Folder", $xml.Project.NamespaceURI);
	 $attr = $xml.CreateAttribute("Include");
	 $dump = $folder.Attributes.Append($attr);
	 $dump = $folder.SetAttribute("Include", $name);
	 $dump = $folder.RemoveAttribute("xmlns")
	 $dump = $folders.AppendChild($folder);
}

$dump = $folders.RemoveAttribute("xmlns")
$dump = $xml.Project.InsertAfter($folders, $after)
$after = $folders

# Get npm files to add
$files = $xml.CreateElement("ItemGroup", $xml.Project.NamespaceURI)

Get-ChildItem "$PSScriptRoot\..\app\" -Recurse | ?{ -not $_.PSIsContainer} | ?{ $_.FullName -match ".*\\(node_modules)\\.*" } | ForEach-Object {
	 $name = $_.FullName.Replace($prefix,"").TrimStart('\')
	 $file = $xml.CreateElement("Content", $xml.Project.NamespaceURI)
	 $attr = $xml.CreateAttribute("Include")
	 $dump = $file.Attributes.Append($attr)
	 $dump = $file.SetAttribute("Include", $name)
	 $dump = $file.RemoveAttribute("xmlns")
	 $dump = $files.AppendChild($file)
} 

$dump = $files.RemoveAttribute("xmlns")
$dump = $xml.Project.InsertAfter($files, $after)
$after = $files

# Get js files to add
$files = $xml.CreateElement("ItemGroup", $xml.Project.NamespaceURI)

Get-ChildItem "$PSScriptRoot\..\app\" -Recurse | ?{ $_.FullName -Match ".*\.js$" } | ?{ $_.FullName -notmatch ".*\\(test|node_modules)\\.*" } | ForEach-Object {
	 $name = $_.FullName.Replace($prefix,"").TrimStart('\')
	 $file = $xml.CreateElement("Compile", $xml.Project.NamespaceURI)
	 $attr = $xml.CreateAttribute("Include")
	 $dump = $file.Attributes.Append($attr)
	 $dump = $file.SetAttribute("Include", $name)
	 $dump = $file.RemoveAttribute("xmlns")
	 $dump = $files.AppendChild($file)
} 

$dump = $files.RemoveAttribute("xmlns")
$dump = $xml.Project.InsertAfter($files, $after)
$after = $files

# Get typescript files
$files = $xml.CreateElement("ItemGroup", $xml.Project.NamespaceURI)

Get-ChildItem "$PSScriptRoot\..\app\" -Recurse | ?{ $_.FullName -Match ".*\.ts$" } | ?{ $_.FullName -notmatch ".*\\(test|node_modules)\\.*" } | ForEach-Object {
	 $name = $_.FullName.Replace($prefix,"").TrimStart('\')
	 $file = $xml.CreateElement("TypeScriptCompile", $xml.Project.NamespaceURI)
	 $attr = $xml.CreateAttribute("Include")
	 $dump = $file.Attributes.Append($attr)
	 $dump = $file.SetAttribute("Include", $name)
	 $dump = $file.RemoveAttribute("xmlns")
	 $dump = $files.AppendChild($file)
} 

$dump = $files.RemoveAttribute("xmlns")
$dump = $xml.Project.InsertAfter($files, $after)

# Get json files
$files = $xml.CreateElement("ItemGroup", $xml.Project.NamespaceURI)

Get-ChildItem "$PSScriptRoot\..\app\" -Recurse | ?{ $_.FullName -Match ".*\.json$" } | ?{ $_.FullName -notmatch ".*\\(test|node_modules)\\.*" } | ForEach-Object {
	 $name = $_.FullName.Replace($prefix,"").TrimStart('\')
	 $file = $xml.CreateElement("Content", $xml.Project.NamespaceURI)
	 $attr = $xml.CreateAttribute("Include")
	 $dump = $file.Attributes.Append($attr)
	 $dump = $file.SetAttribute("Include", $name)
	 $dump = $file.RemoveAttribute("xmlns")
	 $dump = $files.AppendChild($file)
} 

# Add engine
$file = $xml.CreateElement("Content", $xml.Project.NamespaceURI)
$attr = $xml.CreateAttribute("Include")
$dump = $file.Attributes.Append($attr)
$dump = $file.SetAttribute("Include", "app/bin/www")
$dump = $file.RemoveAttribute("xmlns")
$dump = $files.AppendChild($file)

$dump = $files.RemoveAttribute("xmlns")
$dump = $xml.Project.InsertAfter($files, $after)

# Re-generate project file
$xml.Save("$PSScriptRoot\..\ZeroKitNodejsSample.njsproj")
Write-Host -ForegroundColor Green "> Generating project file done."
