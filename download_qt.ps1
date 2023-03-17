# Shout out to @itm4n for making this script! Thanks!
$DestinationFolder = "C:\Qt"
$QtVersion = "qt5_5152"
$Target = "msvc2019"
$BaseUrl = "https://download.qt.io/online/qtsdkrepository/windows_x86/desktop"
$7zipPath = "C:\Program Files\7-Zip\7z.exe"

# Store all the 7z archives in a Temp folder.
$TempFolder = Join-Path -Path $DestinationFolder -ChildPath "Temp"
$null = [System.IO.Directory]::CreateDirectory($TempFolder)

# Build the URLs for all the required components.
$AllUrls = @("$($BaseUrl)/tools_qtcreator", "$($BaseUrl)/$($QtVersion)_src_doc_examples", "$($BaseUrl)/$($QtVersion)")

# For each URL, retrieve and parse the "Updates.xml" file. This file contains all the information
# we need to dowload all the required files.
foreach ($Url in $AllUrls) {
    $UpdateXmlUrl = "$($Url)/Updates.xml"
    $UpdateXml = [xml](New-Object Net.WebClient).DownloadString($UpdateXmlUrl)
    foreach ($PackageUpdate in $UpdateXml.GetElementsByTagName("PackageUpdate")) {
        $DownloadableArchives = @()
        if ($PackageUpdate.Name -like "*$($Target)*") {
            $DownloadableArchives += $PackageUpdate.DownloadableArchives.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrEmpty($_) }
        }
        $DownloadableArchives | Sort-Object -Unique | ForEach-Object {
            $Filename = "$($PackageUpdate.Version)$($_)"
            $TempFile = Join-Path -Path $TempFolder -ChildPath $Filename
            $DownloadUrl = "$($Url)/$($PackageUpdate.Name)/$($Filename)"
            if (Test-Path -Path $TempFile) {
                Write-Host "File $($Filename) found in Temp folder!"
            }
            else {
                Write-Host "Downloading $($Filename) ..."
                (New-Object Net.WebClient).DownloadFile($DownloadUrl, $TempFile)
            }
            Write-Host "Extracting file $($Filename) ..."
            &"$($7zipPath)" x -o"$($DestinationFolder)" $TempFile | Out-Null
        }
    }
}
