## Script to backup and replace the Mi8 auto start script and replace with current repo

Function Get-Folder()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

# Check that we know where the ED install location is:
$installPath = $env:DCS_INSTALL_PATH
if(!$installPath)
{
  Read-Host ""
}