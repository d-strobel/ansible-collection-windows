# Define the path to your module folder
$ModuleFolder = "$PSScriptRoot\..\plugins\modules"

# Create the Markdown table header
$MarkdownTable = @"
| Category | Module | Description |
|----------|--------|-------------|

"@

# Get files in the folder
$Files = Get-ChildItem -Path $ModuleFolder -File -Filter "*.py"

# Loop through each file
foreach ($File in $Files) {
    # Extract the category and module name from the file name
    $FileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
    $Parts = $FileNameWithoutExtension -split "_"
    $Category = $Parts[0]
    $Module = $FileNameWithoutExtension

    # Read the contents of the .py file
    $PyFilePath = Join-Path -Path $ModuleFolder -ChildPath "$FileNameWithoutExtension.py"
    $PyFileContent = Get-Content -Path $PyFilePath

    # Extract the short_description from the Python file
    $ShortDescription = $PyFileContent | Select-String -Pattern "short_description: (.*)" | ForEach-Object { $_.Matches.Groups[1].Value }

    # Add the information to the Markdown table
    $MarkdownTable += "| $Category | $Module | $ShortDescription |`n"
}

# Output the Markdown table
$MarkdownTable