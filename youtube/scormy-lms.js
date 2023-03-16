
let studentId;
let studentName;
let lessonLocation;
let lessonStatus;
let rawScore;
let startTime;
let suspendData = "";


function initLMS(){

    // initialize the LMS
    const results = doLMSInitialize();
    
    if (results != "true"){
        const lmsError = doLMSGetLastError();
        const lmsErrorMessage = "Unable to initialize the LMS. Please exit and try again. Error:" + lmsError;
        return lmsErrorMessage;
    }else{
        studentId      = doLMSGetValue("cmi.core.student_id");
        studentName    = doLMSGetValue("cmi.core.student_name");
        lessonStatus   = doLMSGetValue("cmi.core.lesson_status");
        lessonLocation = doLMSGetValue("cmi.core.lesson_location");
        rawScore       = doLMSGetValue("cmi.core.score.raw");
        suspendData    = doLMSGetValue("cmi.suspend_data");
        startTime      = performance.now();

        if (lessonStatus != 'completed'){
            doLMSSetValue("cmi.core.lesson_status", "incomplete");
            doLMSCommit();
        }

        return "";
    }
}

/**
 * Records the current state of the course to the LMS
 * and then closes the course window.
 */
function doExit(){

    // save the time in session
    const endTime = performance.now();
    sessionTime = getTimeInCourse(startTime, endTime);
    if (sessionTime.indexOf("NaN") == -1){
        doLMSSetValue("cmi.core.session_time",sessionTime);
    }

    // save the suspend data in case they want to return
    doLMSSetValue("cmi.suspend_data", trackingArray);
    doLMSSetValue("cmi.core.lesson_status", lessonStatus);
   
    doLMSCommit();
    
    doLMSFinish();
    window.close();
}


// SCORM wants time in course recorded as hh:MM:ss format
function getTimeInCourse(startTime, endTime){
    const elapsedTime = endTime - startTime;
    let differanceAsDate = new Date(elapsedTime);
    let hr = differanceAsDate.getHours().toString().padStart(4, '0');
    let mn = differanceAsDate.getMinutes().toString().padStart(2, '0');
    let sc = differanceAsDate.getSeconds().toString().padStart(2, '0');
	return hr +":" + mn + ":" + sc;	
}

function markComplete(){
    console.log("markComplete - called");
    lessonStatus = "completed";
    doLMSSetValue("cmi.core.lesson_status","completed");
    doLMSSetValue("cmi.core.exit","");
    doLMSCommit();
}