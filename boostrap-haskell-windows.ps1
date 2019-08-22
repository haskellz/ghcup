New-Variable -Force -Name GHCUP_INSTALL_BASE_PREFIX -Value "$HOME"

Function Kill-Process($message) 
{
    Write-Host "$message failed!" -ForegroundColor Red 
    Exit 2
}

Function Try-Command($command)
{
    $cmd = Invoke-Expression -Command "$command -ErrorAction SilentlyContinue"

    if (-not $cmd) 
    {
        Kill-Process $command
    }
}

Function Wait-User-Response ($message)
{
    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

Function Check-Ghcup-Exist
{
    $expr = "Get-Command -CommandType Application ghci2" 
    $cmd = Invoke-Expression -Command "$expr -ErrorAction SilentlyContinue"

    if ($cmd) 
    {
        Try-Command "ghcup upgrade"
    }
    else 
    {
        echo "false"
    }
}

Write-Host @"


Welcome to Haskell!

This will download and install the Glasgow Haskell Compiler (GHC) for 
the Haskell programming language, and the Cabal build tool.

It will add the 'cabal', 'ghc', and 'ghcup' executables to bin directory 
located at: 

  $GHCUP_INSTALL_BASE_PREFIX\.ghcup\bin

and create the environment file $GHCUP_INSTALL_BASE_PREFIX\.ghcup\env
which you should source in your ~\.bashrc or similar to get the required
PATH components.

"@

Write-Host "To proceed with the ghcup installation press enter, to cancel press ctrl-c."
Write-Host "Note that this script can be re-run at any given time."
# Wait for user input to continue.
# shellcheck disable=SC2034
read-host “Press ENTER to continue...”


if (Get-Command -CommandType Application ghcup -ErrorAction SilentlyContinue) 
{
    echo "exist"
}
else 
{
    try 
    {
        Invoke-WebRequest -Uri 'https://github.com/haskellz/ghcup/raw/windows-support/ghcup.ps1' -OutFile $GHCUP_INSTALL_BASE_PREFIX\.ghcup\bin\ghcup.ps1
        Write-Host -ForegroundColor Yellow "Adding $HOME\.cabal\bin and $GHCUP_INSTALL_BASE_PREFIX\.ghcup\bin to PATH environment variable..."
        Add-Content -Path $Profile.CurrentUserAllHosts -Value '$Env:Path += ";$HOME\.cabal\bin;$GHCUP_INSTALL_BASE_PREFIX\.ghcup\bin"'
        refreshenv
    }
    catch
    {
        Kill-Process "Invoke-WebRequest"
    }
    
}

# Try-Command "ghcup --cache install"
# Try-Command "ghcup set"
# Try-Command "ghcup --cache install-cabal"
# Try-Command "cabal new-update"

Write-Host -ForegroundColor Green @"

Installation done!

"@ 



