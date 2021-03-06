<#
SPLEETER POWERSHELL SCRIPT


#>



# throw error if too many arguments
if ($args.Length -gt 3) {
	throw @"
------------------------------------------------
Too many parameters....
Type .\spleeter.ps1 -h to see possible arguments
------------------------------------------------
"@
}

$SpleeterPath = 'C:\Users\Foderking\Downloads\spleeter'  # Path where spleeter is executed
$output = "C:\Foderking\Production\spleeter\" 	# Output path
$model_path = "C:\Users\Foderking\Downloads\spleeter\pretrained_models\"
$name = $args[0]     # Path to file to be spleet
$stems = $args[1] 		
$cutoff_freq = $args[2]

if (($name -eq "-h") -or ($args.Length -eq 0)){
	Write-Output @"
COMMANDS:
==================================================================================================
.\spleeter.ps1 <path_to_file.mp3> 
				--  Splits file into 2 stems using default parameters

.\spleeter.ps1 <path_to_file.mp3> <no_of_stems>  
				-- Splits file into specified no of stemms (Range: 2 - 5)

.\spleeter.ps1 <path_to_file.mp3> <no_of_stems> <frequency> 
				-- Splits file into specified no of stems and a specific frequency cuttof (Range: 11 - 16)
==================================================================================================
"@
	return
}
# Check if paths are valid
if ( (!(Test-Path $output) -or !(Test-Path $name)) ) {
	throw "Invalid Paths given"
	return
}
# Checks if all parameters are valid
elseif ( !($name -match '.(mp3|wav)$') -or (!($stems -match '^(2|3|4|5)?$') -or !($cutoff_freq -match '^(16)?$')) ) {
	throw "Invalid Parameters given"
	return
}
# Error if pretrained data is missing
elseif (!(Test-Path "$($model_path)$($stems)stems\model.data-00000-of-00001") -and $stems ) {
	$no_model = Read-Host "Error: Pretrained data not found. `nDelete $($model_path)$($stems)stems (Y/N) ?"

	if ($no_model.ToLower() -eq "y" ) {
		Remove-Item -Recurse -Path "$($model_path)$($stems)stems" 
		Write-Output "Successfully deleted"
	}
	else {
		Write-Output "Exiting..."
	}
	return	
}
# Error if the file contains spaces
if ($name -match ' +') {
	$resp = Read-Host "File contains spaces. `nDo you wish to rename it? (Y/N)"

	if ($resp.ToLower() -eq "y") {
		$new_path = $name -replace ' +', '-'
		Write-Output "renamed to $new_path"

		Rename-Item -Path $name -NewName $new_path
		$name = $new_path
	}
}



switch ($args.Length) {
	3 { 
		$parameters = "-p spleeter:$($stems)stems-$($cutoff_freq)kHz"; 
		break 
	}
	2 { 
		$parameters = "-p spleeter:$($stems)stems-16kHz"; 
		break 
	}
	Default { $parameters = "" }
}

# echo "-o $output -p $parameters $name"
conda activate spleeter
Set-Location $SpleeterPath
Invoke-Expression "spleeter separate -o $output $parameters $name"