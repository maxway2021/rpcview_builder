# WARNING! 
# This script only works if you launch it from Visual Studio Developer Command Line.

# START_CONFIG
$oldBuild = "6000324D70000"
$loc = ".\RpcCore\RpcCore4_64bits\RpcInternals.h"
$gitURL = "https://github.com/silverf0x/RpcView.git"
# END_CONFIG

# START_CHECK_ARGS
if($args.Length -eq "") {
	echo "Usage: build.ps1 WIN_VERSION"
	echo ""
	echo "Example: build.ps1 10.0.19044.2486"
	exit
}
$v = $args[0].split(".")
# END_CHECK_ARGS

# START_CONVERT_HEX
$patch = ""
Foreach($i in $v) {
	$vHex = [System.Convert]::ToString($i,16)
	if($vHex.Length -ne 4) {
		$vHex = "0" * (4 - $vHex.Length) + $vHex
	}
	$patch += $vHex
}
$patch = $patch.Substring(($patch.Length - 13), 13).toUpper()
# END_CONVERT_HEX

# START_BUILD
echo "Cloning RpcView source code from url: $gitURL"
git clone -q --branch=master $gitURL .\RpcView
echo "[+] Done"
cd .\RpcView
git checkout -qf 68aef3f2d8292ecbf243d9cff4844fe98e59f6f0 # Took from https://ci.appveyor.com/project/silverf0x/rpcview#L5
mkdir .\Build\x64
((Get-Content -path $loc -Raw) -replace $oldBuild,$patch) | Set-Content -Path $loc
echo "[+] New Windows version patch finished. Starting compile process"
cd .\Build\x64
$env:CMAKE_PREFIX_PATH="C:\Qt\5.15.2\msvc2019_64"
cmd /c cmake ..\.. -A x64
cmd /c cmake --build . --config release
# END_BUILD

# FINISH
echo ""
Write-Host "[+] Success, compiled RpcView location: ""$pwd\bin\Release\RpcView.exe"""
echo ""
exit
