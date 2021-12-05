Function toRadian($Degree){
	return $Degree * ([Math]::Pi / 180);
}

Function Convert-To-Triang(){
	Param
    (   # Parameters needed for the program, rotation is not mandatory
        [Parameter(Mandatory = $true)] [string] $inputFilePath,
        [Parameter(Mandatory = $false)] [double] $rotation,
        [Parameter(Mandatory = $true)] [string] $outputFile
    )
# Variables creation
$Title = 'TITLE  "Rotated by ' + $rotation + ' degree"'
$File = Get-Content $inputFilePath
# Regex patterns to find values that are in table form
$patternCoords = '\d.\d   \d.\d   \d.\d'
$patternNodes = '\d  \d  \d  \d'
$patternMats = '"\w*\d+"'
$MeshpointCoordinates = @()
$NodesQuad1 = @()

# Data extraction and assigning to variables
$File | ForEach-Object{
	If ($_ -match 'TITLE') { $In_Title = ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NMESHPOINTS') { $Nmeshpoints = 'NMESHPOINTS  ' + ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NNODES') { $Nnodes = 'NNODES  ' + ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NELEMENTS_QUAD1') { $Nelements_quad1 = ($_ -split '  ')[1] }
  ElseIf ($_ -match 'NMATERIALS') { $Nmaterials ='NMATERIALS  ' +  ($_ -split '  ')[1] }
  ElseIf ($_ -match $patternCoords) { $MeshpointCoordinates += $_.Substring(6, 15) -split'   '}
  ElseIf ($_ -match $patternNodes) { $NodesQuad1 += $_.Substring(6, 12).Trim() -split'  '}
  ElseIf ($_ -match $patternMats) { $MaterialsQuad1 += $_.Trim() -split'   '}
}
# Calculations by iterating over each element of coordinates array if rotation value exists
if ($rotation -ne $Null -and $rotation -ne ''){
	# Since PowerShell uses the values as radian inside Math functions, i will convert it to Rad
	$i=0
  $rotation = toRadian($rotation)
	while($i -lt $MeshpointCoordinates.Length - 2) { 
		$val_X = $MeshpointCoordinates[$i] -as [int];  
  	$val_Y = $MeshpointCoordinates[$i + 1] -as [int];   
  	# Transform the X value
  	$res_X =  $val_X * [Math]::Cos($rotation) - $val_Y * [Math]::Sin($rotation);
		$MeshpointCoordinates[$i] = [Math]::Round($res_X, 3)
  	# Tranform the Y value 
  	$res_Y =  $val_Y * [Math]::Cos($rotation) + $val_X * [Math]::Sin($rotation);
  	$MeshpointCoordinates[$i + 1] = [Math]::Round($res_Y, 3)
  	$i+= 3;
  	}
 }
 else { $Title = 'TITLE  "conversion without rotation"'}
 # Transform the NODES to TRIANG1
 	$j = 3
  $NODES_TRIANG1 = @()
	while($j -lt $NodesQuad1.Length){
  	$NODES_TRIANG1 += $NodesQuad1[$j]
    $NODES_TRIANG1 += $NodesQuad1[$j - 3]
    $NODES_TRIANG1 += $NodesQuad1[$j - 2]
    $NODES_TRIANG1 += $NodesQuad1[$j]
    $NODES_TRIANG1 += $NodesQuad1[$j - 2]
    $NODES_TRIANG1 += $NodesQuad1[$j - 1]
  	$j += 4
  }
# Add variables to the output file
$NelementsTriang = ($Nelements_quad1 -as [int]) * 2
$NELEMENTS_TRIANG1 = 'NELEMENTS_TRIANG1  ' + $NelementsTriang
# Fix the 0 in Meshpoints to show 0.0 instead
For ($i = 0 ; $i -le $MeshpointCoordinates.Length ; $i++){
	If($MeshpointCoordinates[$i] -eq '0' -or $MeshpointCoordinates[$i] -eq 0){
  	$MeshpointCoordinates[$i] = '0.0'
  }
}
# Print the data
write-host $Title
write-host ''
write-host $Nmeshpoints
write-host $Nnodes
write-host $NELEMENTS_TRIANG1
write-host $Nmaterials
write-host ''
write-host 'MESHPOINT_COORDINATES'
$i = 0
$Line = 1
While($i -lt $MeshpointCoordinates.Length){
	$PrintLine = '  ' + $Line + '   ' + $MeshpointCoordinates[$i] + '   ' + $MeshpointCoordinates[$i + 1] + '   ' + $MeshpointCoordinates[$i + 2]
  Write-Host $PrintLine
  $Line++
  $i+= 3
}
write-host ''
write-host ''
write-host 'NODES_TRIANG1'
$j = 0
$Line = 1
While($j -lt $NODES_TRIANG1.Length){
	$PrintNodes = '  ' + $Line + '     ' + $NODES_TRIANG1[$j] + ' ' + $NODES_TRIANG1[$j +1] + ' ' +$NODES_TRIANG1[$j +2]
  Write-Host $PrintNodes
  $j+= 3
  $Line++
}
write-host ''
write-host ''
write-host 'MATERIALS_TRIANG1'
$k = 1
while($k -le $MaterialsQuad1.Length){
	$mats = '      ' + $k + '   ' + $MaterialsQuad1[1]
  write-host $mats
  $k++
}

# Check if output filename is available
If(Get-Item -Path $outputFile -ErrorAction Ignore){Write-Host $outputFile "file already exists!"}
Else{ # Otherwise proceed with the task 
	#		New-Item -Verbose $outputFile -ItemType File
  #   Write-Host -f Green $outputFile "file created successfully!"
    # }
}

Convert-To-Triang -inputFilePath "input_2.mdf" -outputFile "output_2.mdf" -rotation 45
