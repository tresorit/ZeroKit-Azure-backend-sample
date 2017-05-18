Write-Host "*** Building ZeroKit-Azure-backend-sample ***"

# Check MSbuild availabality
# valid versions are [14.0, 15.0] tested for 14.0
$toolVersion = "14.0"
$regKey = "HKLM:\software\Microsoft\MSBuild\ToolsVersions\$toolVersion"
$regProperty = "MSBuildToolsPath"
$keyItem = Get-ItemProperty $regKey -ErrorAction SilentlyContinue

if ($keyItem -eq $null) 
{ 
    Write-Error "Unable to find MSBUILD on your machine"
	exit -1
}

$msbuildExe = join-path -path $keyItem.$regProperty -childpath "msbuild.exe"
Write-Host -ForegroundColor Green "> MSBuild tooles found"

# Delete possibole old build outputs
if (Test-Path "$PSScriptRoot\ZeroKitNodejsSample\obj\Release\"){
	Remove-Item -Force -Recurse "$PSScriptRoot\ZeroKitNodejsSample\obj\Release\"
	Write-Host -ForegroundColor Green "> Old build output has been removed"
}

# Check submodule by checking existance of main js sript
if (-Not (Test-Path "$PSScriptRoot\ZeroKitNodejsSample\app\bin\www"))
{
	Write-Error "Please check out and update submodules before build!"
	exit -1
}
Write-Host -ForegroundColor Green "> GIT submodule found"

# Re-generate project file
.\ZeroKitNodejsSample\.build\generate-project.ps1

if (-Not $?)
{
	cd $oldPath
	Write-Error "Failed to generate project file, aborting!!"
	exit -1
}

# Building project
Write-Host -ForegroundColor Green "> Building project..."
$slnPath = Resolve-Path "$PSScriptRoot\ZeroKit-Azure-backend-sample.sln"
&$msbuildExe /p:Configuration=Release /p:DeployOnBuild=true "$slnPath"

if (-Not $?)
{
	cd $oldPath
	Write-Error "Build failed, aborting!!"
	exit -1
}

cp "$PSScriptRoot\ZeroKitNodejsSample\obj\Release\Package\ZeroKitNodejsSample.zip" "$PSScriptRoot\.package\"
Write-Host -ForegroundColor Green "> Package generation OK, output copied to /.package folder"