/**
 * These scripts are general to the SCORMY app.  Initialization and unload occur here as well
 * as scripts to control the UI and user interactions on the page.
 * 
 */

/// initialize the page
$( document ).ready(function() {
    console.log("document-ready->init()");
    init();
});


/// call the LMS exit functions when 
/// the browser closes
$(window).on("beforeunload", function() { 
    console.log("beforeunload -> exit()");
    doExit();
})

/**
 * Check the LMS API is valid before loading the video API.
 * Then load the API from YouTube.
 */
function init(){
    const lmsMessage = initLMS();
    if (lmsMessage.length > 0){
        showErrorMessage(lmsMessage);
    }else{
        loadVideoAPI()
    }

}

/**
 * This changes the button from Play to Pause
 * by toggling the icon
 * @param {String} buttonId 
 * @param {boolean} isPlaying 
 */
function setButtonState(buttonId, isPlaying){

    let button = $('#' + buttonId);

    if (isPlaying){
        button.html("<span class=\"glyphicon glyphicon-pause\"></span>");
    }else{
        button.html("<span class=\"glyphicon glyphicon-play\"></span>");
    }
}

/**
 * This method is called when the user hits the exist button.
 */

function exit(){
    // status
    let complete = 0;

    // pause the video
    if (player)  player.pauseVideo();

    // percent complete
    const percentComplete = getPercentComplete();

    // when the video ends, stop the tracking
    let message = "";
    if (percentComplete < requiredPercentage){
        message = "<p>Required: " + requiredPercentage + "%.</p>";
        message += "<p>Watched: " + percentComplete + "%.</p>";
        message += "<p>Status: <span class='text-danger'>Incomplete</span></p>";
        message += "<p>The <span class='glyphicon glyphicon-play-circle'></span> button plays skipped portions of the video.</p>";
        message += "<p>Do you sure you wish to exit?</p>";
    }else{
        message = "<p>Required: " + requiredPercentage + "%.</p>";
        message += "<p>Watched: " + percentComplete + "%.</p>";
        message += "<p>Status: <span class='text-success'>Complete</span></p>";
        message += "<p>Do you sure you wish to exit?</p>";
        complete = 1;
    }

    bootbox.confirm({
        message: message,
        buttons: {
            confirm: {
                label: 'Yes',
                className: 'btn-success'
            },
            cancel: {
                label: 'No',
                className: 'btn-danger'
            }
        },
        callback: function (result) {
            if (result){
                doExit();
            }else{
                player.playVideo();
            }
            console.log('This was logged in the callback: ' + result);
        }
    });
}

/**
 * Shows errors in a div layer named <b>errorMessage</b>
 * if the debug option is true, it also writes to the console.log
 * 
 * @param {Sting} message 
 * @param {boolean} debug 
 */
function showErrorMessage(message, debug){

    // hide buttons
    $('#buttons').hide();

    let messageObj = $('#errorMessage');

    if (debug){
        console.log(message);
    }

    let existingMessage = messageObj.html();
    messageObj.html(existingMessage + "<br>" + message);

}