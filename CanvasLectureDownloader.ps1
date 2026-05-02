$CanvasURL = "https://canvas.ualberta.ca" # I go to the University of Alberta, so this is the URL for my canvas instance, change it to your own if you want to use this script for your own courses
$Token = Read-Host "Enter your Canvas API Token"
$Dest = Read-Host "Enter the destination folder PATH for the downloaded files"


$Headers = @{
	Authorization = "Bearer $Token"
}

#Canvas page that shows all our courses
$Courses = Invoke-RestMethod -Uri "$CanvasURL/api/v1/courses?enrollment_state=active&per_page=100" -Headers $Headers

for($i = 0; $i -lt $Courses.Count; $i++){
    Write-Host "$i -> $($Courses[$i].name)"    
}

$CourseIndex = Read-Host "Enter the index of the course you want to download from"
$CourseID = $Courses[$CourseIndex].id

# Show all the modules in the course
$Modules = Invoke-RestMethod -Uri "$CanvasURL/api/v1/courses/$CourseID/modules?per_page=100" -Headers $Headers

for ($i = 0; $i -lt $Modules.Count; $i++) {
    Write-Host "$i -> $($Modules[$i].name)"
}

$ModuleIndex = Read-Host "Enter the index of the module you want to download from"
$ModuleID = $Modules[$ModuleIndex].id

# Depending on how the course is structured, there may be multiple ways to access the files.
# The most common way is that a single module contains all the lectures, where each lecture is stored as a item in the module.
$ModuleItems = Invoke-RestMethod -Uri "$CanvasURL/api/v1/courses/$CourseID/modules/$ModuleID/items?per_page=100" -Headers $Headers
foreach ($item in $ModuleItems) {
    if ($item.type -eq "File") {
        $fileDetails = irm -Uri $item.url -Headers $Headers
        
        # Download the actual PDF
        Write-Host "Downloading: $($fileDetails.display_name)"
        iwr -Uri $fileDetails.url -OutFile "$Dest\$($fileDetails.display_name)"
    }
}

# I was gonna make a dynamic downloading system, where the script checks how the files are stored on canvas, however during the making of this
# I found out my professor locked all the files, so I'm not gonna be able to use this script, gl to anyone that tries this, see you next semester maybe lol
