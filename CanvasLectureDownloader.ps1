#The naming kinda sucks ik, idk why I decided to use spontantous capitalization whenver I felt like it, I'll change it maybe...
$CanvasURL = "https://canvas.ualberta.ca"
$Token = "PASTE YOUR CANVAS API ACCESS TOKEN HERE" #Account -> Settings -> new access token
$Dest = "C:\Users\total\OneDrive\Desktop\Y3\T1\ECE 325\Lectures"

$Headers = @{
	Authorization = "Bearer $Token"
}

#Canvas page that shows all our courses
$resp = Invoke-WebRequest -Uri "$CanvasURL/api/v1/courses?enrollment_state=active&per_page=100" -Headers $Headers

$Courses = $resp.Content | ConvertFrom-Json

#Course we want to download, index represents the course
$CourseID = $Courses[5].id

#Course webpage
$Course = Invoke-WebRequest -Uri "$CanvasURL/api/v1/courses/$CourseID/modules?per_page=100" -Headers $Headers

$Modules = $Course.Content | ConvertFrom-Json

$LectureID = $Modules[1].id # we know the lectures are index 2 because we piped Modules into Select id, name

#go into Lecture slides
$LectureSlides = iwr -Uri "$CanvasURL/api/v1/courses/$CourseID/modules/$LectureID/items?per_page=100" -Headers $Headers

#Convert Lecture Content from JSON
$Slides = $LectureSlides.Content | ConvertFrom-Json

#We want to loop through all the slides and download them
foreach ($slide in $Slides){
    if($slide.type -eq "File"){

    $SlideID = $slide.content_id
    $fileResp = Invoke-WebRequest -Uri "$CanvasURL/api/v1/files/$SlideID" -Headers $Headers

    $file = $fileResp.Content | ConvertFrom-Json

    #Download File
    iwr -Uri $file.url -OutFile "$Dest\$($file.display_name)"

    }
}
