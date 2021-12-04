
Function Convert-To-Triang(){
	Param
    (   #parameters needed for the program, rotation is not mandatory
        [Parameter(Mandatory = $true)] [string] $inputFilePath,
        [Parameter(Mandatory = $false)] [double] $rotation,
        [Parameter(Mandatory = $true)] [string] $outputFile
    )
# Variables creation
$File = Get-Content $inputFilePath
#Regex patterns to find values that are in table form
$patternCoords = '\d.\d   \d.\d   \d.\d'
$patternNodes = '\d  \d  \d  \d'
$patternMats = '"\w*\d+"'
$MeshpointCoordinates = @()
$NodesQuad1 = @()

# Data extraction and assigning to variables
$File | ForEach-Object{
	If ($_ -match 'TITLE') { $Title = ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NMESHPOINTS') { $Nmeshpoints = ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NNODES') { $Nnodes = ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NELEMENTS_QUAD1') { $Nelements_quad1 = ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NMATERIALS') { $Nmaterials = ($_ -split '  ')[1] }
  ElseIf ($_ -match $patternCoords) { $MeshpointCoordinates += $_.Substring(6, 15) -split'   '}
  ElseIf ($_ -match $patternNodes) { $NodesQuad1 += $_.Substring(6, 12).Trim() -split'  '}
  ElseIf ($_ -match $patternMats) { $MaterialsQuad1 += $_.Trim() -split'   '}
}
#write-host 'coords length should be 18 and is : ' $MeshpointCoordinates.Length
write-host 'MESHPOINT_COORDINATES old' $MeshpointCoordinates
# Calculations by iterating over each element of coordinates array if rotation value exists
if ($rotation -ne $Null -and $rotation -ne ''){
	$i=0
	while($i -lt $MeshpointCoordinates.Length - 2) { 
		$val_X = $MeshpointCoordinates[$i] -as [double];
  	$val_Y = $MeshpointCoordinates[$i + 1] -as [double];
  	# Transform the X value
  	$res_X = ( $val_X * [Math]::Cos($rotation) ) - ( $val_Y * [Math]::Sin($rotation) );
		$MeshpointCoordinates[$i] = [math]::Round($res_X,2).toString()
  	# Tranform the Y value
  	$res_Y = ( $val_Y * [Math]::Cos($rotation) ) + ( $val_X * [Math]::Sin($rotation) );
  	$MeshpointCoordinates[$i + 1] = [math]::Round($res_Y,2).toString()
  	$i+= 3;
  	}
 }

write-host 'Title '$Title
write-host 'NMESHPOINTS '$Nmeshpoints
write-host 'NNODES '$Nnodes
write-host 'NELEMENTS_QUAD1 '$Nelements_quad1
write-host 'NMATERIALS '$Nmaterials
write-host 'MESHPOINT_COORDINATES new' $MeshpointCoordinates
write-host 'NODES_QUAD1' $NodesQuad1
write-host 'MATS ' $MaterialsQuad1 #this array will contain index and MAT type after each other

 #check if output filename is not available
# if(Get-Item -Path $outputFile -ErrorAction Ignore){Write-Host $outputFile "file already exists!"}
# else{ #proceed with the task 
	#		New-Item -Verbose $outputFile -ItemType File
  #   Write-Host -f Green $outputFile "file created successfully!"
    # }
}

Convert-To-Triang -inputFilePath "inputPS.txt" -outputFile "outputPS.mdf" -rotation 90

