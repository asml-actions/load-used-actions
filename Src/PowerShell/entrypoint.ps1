param (
    [string] $organization,
    [string] $PAT
)

function main {

    if ($null -eq $organization -or "" -eq $organization) {
        Write-Host "Using default for organization: [$($env:GITHUB_REPOSITORY_OWNER)]"
        $organization = $($env:GITHUB_REPOSITORY_OWNER)
    }

    if ($null -eq $PAT -or "" -eq $PAT) {
        Write-Host "Using default for PAT: [GITHUB_TOKEN]"
        $PAT = $($env:GITHUB_TOKEN)
    }

    $actions = (.\load-used-actions.ps1 -orgName $organization -PAT $PAT)

    # wite the file outside of the container so we can pick it up
    Write-Host "Found [$($actions.Count)] actions "
    #Write-Verbose $actions | ConvertTo-Json -Depth 10
    $jsonObject = ($actions | ConvertTo-Json -Depth 10)
    $fileName = "summarized-actions.json"
    New-Item -Path $fileName -Value $jsonObject -Force | Out-Null
    $content = Get-Content $fileName
    Write-Host "Written [$($content.Length)] characters to the output file [$fileName]"
}

try {
    # call main script:
    main
    # return the container with the last exit code:
    Write-Host "Returning with last exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}
catch {
    # return the container with the last exit code: 
    Write-Error "Error loading actions: $($_)"	
    Write-Host "Returning with last exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}