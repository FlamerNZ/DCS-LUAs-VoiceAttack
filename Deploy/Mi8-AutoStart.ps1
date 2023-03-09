## Script to backup the current Mi8 auto start script and replace with our custom one from the current repo
$ErrorActionPreference = "Stop"
$macroSequenciesRelPath = "Mods\aircraft\Mi-8MTV2\Cockpit\Scripts\Macro_sequencies.lua"

Write-Host "`n** Shifty's Mi8 Auto Start Script deployment script script :P **`n"

function Get-Folder()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "DCS Install Location (not Saved Games folder)"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

function Get-DCSInstallPath {
  # Check that we know where the ED install location is:
  $installPath = $env:DCS_INSTALL_PATH
  if(!$installPath)
  {
    Write-Host "Where is your DCS install path?"
    $env:DCS_INSTALL_PATH = Get-Folder
  }
  return $installPath
}

function Get-BackupPath ($path, $i = 0) {
  if(Test-Path $path)
  {
    #increment by 1
    $path = $path + "_" + $i
    if(Test-Path $path)
    {
      $path = Get-BackupPath $path $i++
    }
  }
  return $path
}

$installPath = Get-DCSInstallPath
Write-Host "Current DCS install path: " $installPath

$macroSequenciesPath = $installPath + "\" + $macroSequenciesRelPath
Write-Host "Checking that I can find your autostart file..."
if(Test-Path $macroSequenciesPath)
{
  Write-Error -Message "File doesn't seem to be at this path: $macroSequenciesPath"
  $response = Read-Host -Prompt "Would you like to reset your DCS install path? (Y/N)"
  if($response -eq "Y")
  {
    $installPath = Get-DCSInstallPath
  } else {
    exit 1
  }
}
Write-Host "Taking a backup of your current auto start..."
$backupPath = $macroSequenciesPath + "." + (get-date -Format "yy-MM-dd") + ".bak"
$backupPath = Get-BackupPath $backupPath
Rename-Item $macroSequenciesPath -NewName $backupPath

Write-Host "Deploying new auto start..."
Copy-Item "Startup\Mi-8\Macro_sequencies.lua" -Destination $macroSequenciesPath

Write-Host "Auto Start Script updated from current branch.  Enjoy!"