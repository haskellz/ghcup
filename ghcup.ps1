# Copyright (c) 2019, Woodson Delhia <woodsondelhia88@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the <ORGANIZATION> nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)

# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.




# @VARIABLE: VERSION
# @DESCRIPTION:
# Version of this script.
$VERSION = "0.0.1"

# @VARIABLE: VERBOSE
# @DESCRIPTION:
# Whether to print verbose messages in this script.
$VERBOSE = $false 

# @VARIABLE: FORCE
# @DESCRIPTION:
# Whether to force installation and overwrite files.
$FORCE = $false

# @VARIABLE: GHCUP_INSTALL_BASE_PREFIX
# @DESCRIPTION:
# The main install directory prefix, under which .ghcup
# directory will be created. This directory is user
# configurable via the environment variable of the
# same name. It must be non-empty and the path
# it points to must exist.
$GHCUP_INSTALL_BASE_PREFIX = $HOME

# @VARIABLE: INSTALL_BASE
# @DESCRIPTION:
# The main install directory where all ghcup stuff happens.
$INSTALL_BASE = "$GHCUP_INSTALL_BASE_PREFIX\.ghcup"

# @VARIABLE: GHC_LOCATION
# @DESCRIPTION:
# The location where ghcup will install different ghc versions.
# This is expected to be a subdirectory of INSTALL_BASE.
$GHC_LOCATION = "$INSTALL_BASE\ghc"

# @VARIABLE: BIN_LOCATION
# @DESCRIPTION:
# The location where ghcup will create symlinks for GHC binaries.
# This is expected to be a subdirectory of INSTALL_BASE.
$BIN_LOCATION = "$INSTALL_BASE\bin"

# @VARIABLE: CACHE_LOCATION
# @DESCRIPTION:
# The location where ghcup will put tarballs for caching.
# This is expected to be a subdirectory of INSTALL_BASE.
$CACHE_LOCATION = "$INSTALL_BASE\cache"

# @VARIABLE: DOWNLOADER
# @DESCRIPTION:
# What program to use for downloading files.
$DOWNLOADER = "Invoke-WebRequest -URI"

# @VARIABLE: DOWNLOADER_OPTS
# @DESCRIPTION:
# Options passed to the download program.
$DOWNLOADER_OPTS = "-OutFile"

# @VARIABLE: GHC_DOWNLOAD_BASEURL
# @DESCRIPTION:
# Base URL for all GHC tarballs.
$GHC_DOWNLOAD_BASEURL = "https://downloads.haskell.org/~ghc"

# @VARIABLE: SOURCE
# @DESCRIPTION:
# the script name.
$SOURCE = $MyInvocation.ScriptName

# @VARIABLE: BASE_DOWNLOAD_URL
# DESCRIPTION:
# The base url for downloading stuff like meta files, requirements files etc.
$BASE_DOWNLOAD_URL = "https://github.com/haskellz/ghcup/raw/master/"

# @VARIABLE: SCRIPT_UPDATE_URL
# @DESCRIPTION:
# Location to update this script from.
$SCRIPT_UPDATE_URL = "${BASE_DOWNLOAD_URL}/ghcup"

# @VARIABLE: GHCUP_META_DOWNLOAD_URL & META_DOWNLOAD_URL 
# DESCRIPTION:
# The url of the meta file for getting
# download information for ghc/cabal-install etc.
$META_DOWNLOAD_URL ="${BASE_DOWNLOAD_URL}/.download-urls"

# @VARIABLE: META_DOWNLOAD_FORMAT
# DESCRIPTION:
# The version of the meta file format.
# This determines whether this script can read the
# file from "${META_DOWNLOAD_URL}".
$META_DOWNLOAD_FORMAT = "1"

# @VARIABLE: META_VERSION_URL
# DESCRIPTION:
# The url of the meta file for getting
# available versions for ghc/cabal-install etc.
$META_VERSION_URL = "${BASE_DOWNLOAD_URL}/.available-versions"

# @VARIABLE: META_VERSION_FORMAT
# DESCRIPTION:
# The version of the meta file format.
# This determines whether this script can read the
# file from "${META_VERSION_URL}".
$META_VERSION_FORMAT = "1"

# @VARIABLE: BUG_URL
# DESCRIPTION:
# The url to report bugs to.
$BUG_URL = "https://gitlab.haskell.org/haskell/ghcup/issues"

# @VARIABLE: CACHING
# @DESCRIPTION:
# Whether to cache tarballs in $CACHE_LOCATION.
$CACHING = $false


# @FUNCTION: usage
# @DESCRIPTION:
# Print the help message for 'ghcup' to STDERR
# and exit the script with status code 1.
Function Write-Usage 
{
    $compile = if ($VERBOSE) { "`n    compile            Compile and install GHC from source (UNSTABLE!!!)" } else { "" }
    Write-Host @"
ghcup $VERSION
GHC up toolchain installer

USAGE:
    ${SCRIPT} [FLAGS] <SUBCOMMAND>

FLAGS:
    -v, --verbose    Enable verbose output
    -h, --help       Prints help information
    -V, --version    Prints version information
    -w, --wget       Use wget instead of curl
    -c, --cache      Use \"${CACHE_LOCATION}\" for caching tarballs
                        (these will not be removed by ghcup)

SUBCOMMANDS:
    install            Install GHC $compile
    set                Set currently active GHC version
    list               Show available GHCs and other tools
    upgrade            Upgrade this script in-place
    rm                 Remove an already installed GHC
    install-cabal      Install cabal-install
    debug-info         Print debug info (e.g. detected system/distro)
    changelog          Show the changelog of a GHC release (online)
    print-system-reqs  Print an approximation of system requirements

DISCUSSION:
    ghcup installs the Glasgow Haskell Compiler from the official
    release channels, enabling you to easily switch between different
    versions.
"@
    Exit 1
}

if ($args.Length -eq 0)
{
    Write-Usage
    Exit 1
}

Function Write-List-Commands
{
    Write-Host @"
changelog
compile
debug-info
install
install-cabal
list
print-system-reqs
rm
set
upgrade
"@
    Exit 0
}

# @FUNCTION: list_usage
# @DESCRIPTION:
# Print the help message for 'ghcup list' to STDERR
# and exit the script with status code 1.
Function Write-List-Usage
{
    Write-Host @"
ghcup-list
Show available GHCs and other tools

USAGE:
    ${SCRIPT} list

FLAGS:
    -h, --help                             Prints help information
    -t, --tool <all|ghc|cabal-install>     Tool to list versions for. Default is ghc only.
    -c, --show-criteria <installed|set>    Show only installed or set tool versions
    -r, --raw-format                       Raw format, for machine parsing

DISCUSSION:
    Prints tools (e.g. GHC and cabal-install) and their
    available/installed/set versions.
"@
    Exit 1
}

# @FUNCTION: download_silent
# @USAGE: <url>
# @DESCRIPTION:
# Downloads the given url as a file into the current directory, silent, unless
# verbosity is on.
$download_silent = {
    param ($url, $opts)
    echo "hello: $url $opts"
    if (!$url)
    {
        Kill-Process "Internal error: no argument given to download"
    }

    if ($VERBOSE)
    {
        Try-Command "$DOWNLOADER $url $DOWNLOADER_OPTS $opts"
    }
    else
    {
        echo "in"
        $progressPreference = 'silentlyContinue'
        Try-Command "$DOWNLOADER $url $DOWNLOADER_OPTS $opts"
        $progressPreference = 'Continue'
    }
    echo "done download!"
}

# @FUNCTION: Get-Meta-File-Version
# @USAGE: <file> <metaver>
# @DESCRIPTION:
# Check that the given meta file has the same format version
# as specified, otherwise die.
Function Get-Meta-File-Version($filepath, $format) {
    echo "filepathsadasd: $filepath"
    if (-not ($filepath -and $format)) { Kill-Process "Internal error: not enough arguments given to check_meta_file_version" }

    $fileformat = Get-Content $filepath -TotalCount 1 | ForEach-Object { $_.Split("=")[1]}

    if ($fileformat -ne $format) { Kill-Process "Unsupported meta file format, run: ${SCRIPT} upgrade" }
}

# @FUNCTION: get_meta_version_file
# @DESCRIPTION:
# Downloads the META_VERSION_URL
# in case it hasn't been downloaded
# during the execution of this script yet
# and checks the format version matches
# the expected one.
# @STDOUT: file location
Function Get-Meta-Version-File
{
    $meta_filename = [System.IO.Path]::GetFileName($META_VERSION_URL)
    $meta_filepath = "$CACHE_LOCATION\$meta_filename"

    if (-not (Test-Path -Path $meta_filepath))
    {
        $current_pwd = pwd 
        try 
        {
            Set-Location -Path $CACHE_LOCATION
            & $download_silent $META_VERSION_URL $meta_filename $> $null
        } catch
        {
            echo "error!"
            Kill-Process $PSItem.Exception.InnerExceptionMessage
        } finally
        {
            Set-Location $current_pwd
            echo "done set loc"
        }
    }

    Get-Meta-File-Version $meta_filepath $META_VERSION_FORMAT

    echo "done!!!"
    return $meta_filepath
}

Function Get-List($tool, $raw_format, $criteria)
{
    $metafile = Get-Meta-Version-File
    
    if (!$metafile) { Kill-Process "failed to get meta file" }

    if (-not ($raw_format)) { Write-Host -ForegroundColor Green "Available versions:" }
}

Function Shift-Args-Left 
{
    $head,$rest = $script:args 
    $script:args = $rest 
}

Function Kill-Process($message) 
{
    Write-Host $message -ForegroundColor Red 
    Exit 2
}

$try_command = Function Try-Command($command)
{
    $cmd = Invoke-Expression -Command "$command -ErrorAction SilentlyContinue"
    if (!$?) 
    {
        Kill-Process $command
    }
}

while ($args.Length -gt 0)
{
    switch ($args.get(0))
    {
        { $_ -cin @("-h", "--help")    } { Write-Usage }
        { $_ -cin @("-V", "--version") } { Write-Host "$VERSION"; Exit 0 }
        { $_ -ceq "--list-commands"    } { Write-List-Commands }
        { $_ -cin @("-v", "--verbose") } 
        { 
            $VERBOSE = $true; 
            Shift-Args-Left
            if ($args.Length -lt 1) { Write-Usage } 
        }
        { $_ -cin @("-c", "--cache") } 
        { 
            $CACHING = $true; 
            Shift-Args-Left
            if ($args.Length -lt 1) { Write-Usage } 
        }
        default ## startup tasks ##
        {
            New-Item -Path $INSTALL_BASE -ItemType Directory -Force *> $null
            New-Item -Path $BIN_LOCATION -ItemType Directory -Force  *> $null
            New-Item -Path $CACHE_LOCATION -ItemType Directory -Force *> $null

            # clean up old meta files
            $meta_filename = [System.IO.Path]::GetFileName($META_VERSION_URL)
            if (Test-Path -Path "$CACHE_LOCATION/$meta_filename")
            {
                Try-Command "Remove-Item $CACHE_LOCATION/$meta_filename *> $null" 
            }

            $meta_downloadurl = [System.IO.Path]::GetFileName($META_DOWNLOAD_URL)
            if (Test-Path -Path "$CACHE_LOCATION/$meta_filename")
            {
                Try-Command "Remove-Item $CACHE_LOCATION/$meta_downloadurl *> $null"
            }
            
            switch ($args.get(0))
            {
                { $_ -ceq "list" } 
                { 
                    $raw_format = $false
                    $tool = "ghc"
                    $show_criteria
                    Shift-Args-Left

                    while ($args.Length -gt 0 )
                    {
                        switch ($args.get(0))
                        {
                            { $_ -cin @("-h", "--help")          } { Write-List-Usage }
                            { $_ -cin @("-t", "--tool")          } { $tool = $args.get(1); Shift-Args-Left; Shift-Args-Left }
                            { $_ -cin @("-c", "--show-criteria") } { $show_criteria = $args.get(1); Shift-Args-Left; Shift-Args-Left }
                            { $_ -cin @("-r", "--raw-format")    } { $raw_format = $true; Shift-Args-Left }
                            default { Write-List-Usage }
                        }

                    }
                   Get-List $tool $raw_format $show_criteria
                   break;
                }
            }
        }
    }
}


# Things to not forget to remove/review: 
# need to remove "-Force" for the function right after the startup tasks
# New-Item -Path $INSTALL_BASE -ItemType Directory -Force
