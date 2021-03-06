
function Resolve-ModuleMetadataFile
{
    [cmdletbinding(DefaultParameterSetName='ByDirectoryInfo')]
    param (
        [parameter(
            ParameterSetName = 'ByPath',
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string]
        $Path,
        [parameter(
            ParameterSetName = 'ByDirectoryInfo',
            Mandatory,
            ValueFromPipeline
        )]
        [System.IO.DirectoryInfo]
        $InputObject

    )

    process
    {
        $MetadataFileFound = $true
        $MetadataFilePath = ''
        Write-Verbose "Using Parameter set - $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName)
        {
            'ByPath'             {
                                    Write-Verbose "Testing Path - $path"
                                    if (Test-Path $Path)
                                    {
                                        Write-Verbose "`tFound $path."
                                        $item = (Get-Item $Path)
                                        if ($item.psiscontainer)
                                        {
                                            Write-Verbose "`t`tIt is a folder."
                                            $ModuleName = Split-Path $Path -Leaf
                                            $MetadataFilePath = Join-Path $Path "$ModuleName.psd1"
                                            $MetadataFileFound = Test-Path $MetadataFilePath
                                        }
                                        else
                                        {
                                            if ($item.Extension -like '.psd1')
                                            {
                                                Write-Verbose "`t`tIt is a module metadata file."
                                                $MetadataFilePath = $item.FullName
                                                $MetadataFileFound = $true
                                            }
                                            else
                                            {
                                                $ModulePath = Split-Path $Path
                                                Write-Verbose "`t`tSearching for module metadata folder in $ModulePath"
                                                $ModuleName = Split-Path $ModulePath -Leaf
                                                Write-Verbose "`t`tModule name is $ModuleName."
                                                $MetadataFilePath = Join-Path $ModulePath "$ModuleName.psd1"
                                                Write-Verbose "`t`tChecking for $MetadataFilePath."
                                                $MetadataFileFound = Test-Path $MetadataFilePath
                                            }
                                        }
                                    }
                                    else
                                    {
                                        $MetadataFileFound = $false
                                    }
                                }
            'ByDirectoryInfo'   {
                                    $ModuleName = $InputObject.Name
                                    $MetadataFilePath = Join-Path $InputObject.FullName "$ModuleName.psd1"
                                    $MetadataFileFound = Test-Path $MetadataFilePath
                                }

        }

        if ($MetadataFileFound -and (-not [string]::IsNullOrEmpty($MetadataFilePath)))
        {
            Write-Verbose "Found a module metadata file at $MetadataFilePath."
            Convert-path $MetadataFilePath
        }
        else
        {
            Write-Error "Failed to find a module metadata file at $MetadataFilePath."
        }
    }
}