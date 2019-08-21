New-Variable -Force -Name GHCUP_INSTALL_BASE_PREFIX -Value "$HOME"

Function Kill-Process($message) {
    Write-Host "$message failed!" -ForegroundColor Red 
    Exit 2
}

Function Try-Command($command){
    $exit_code = Invoke-Command -ScriptBlock { 
        Invoke-Expression -command $command
        $LASTEXITCODE
    }

    if ($exit_code -gt 0) {
        Kill-Process $command
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

$ghcup? = Get-Command -CommandType Application ghci -ErrorAction SilentlyContinue

if ($ghcup?) {
    Try-Command "ghcup upgrade"
}else {
    echo "false"
}
