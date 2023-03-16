/**
 * These scripts are general to the SCORMY app.  Initialization and unload occur here as well
 * as scripts to control the UI and user interactions on the page.
 * 
 */

var interval;

/// initialize the page
$(document).ready(function () {
    console.log("document-ready->init()");
    init();
    resize();
});

$(window).resize(resize);


/// call the LMS exit functions when 
/// the browser closes
$(window).on("beforeunload", function () {
    console.log("beforeunload -> exit()");
    doExit();
})



/**
 * Check the LMS API is valid before loading the video API.
 * Then load the API from YouTube.
 */
function init() {
    const lmsMessage = initLMS();
    if (lmsMessage.length > 0) {
        showErrorMessage(lmsMessage);
    } else {
        // set an interval 5 minutes
        // this will keep the session alive until the user closes the browser window.
        // mainly to record the time in course. 
        let delay = 5 * 60000000;
        interval = setInterval(updateProgress, delay);
    }
}




/**
 * Shows errors in a div layer named <b>errorMessage</b>
 * if the debug option is true, it also writes to the console.log
 * 
 * @param {Sting} message 
 * @param {boolean} debug 
 */
function showErrorMessage(message, debug) {

    let messageObj = $('#errorMessage');

    if (debug) {
        console.log(message);
    }

    let existingMessage = messageObj.html();
    messageObj.html(existingMessage + "<br>" + message);

}

function resize() {
    var win = $(this); //this = window
    var w = win.width() - 25;
    var h = win.height() - 25;

    // get iFrame height and width
    var frame = $('iframe');
    var fh = frame.height();
    var fw = frame.width();

    // now calculate height usign aspect ratio and width
    var nh = Math.round((fh / fw) * w);

    // if the new height is greater than the window height, then go the other way
    if (nh > h) {
        var nw = Math.round((fw / fh) * h);
        frame.height(h);
        frame.width(nw);
    } else {
        frame.height(nh);
        frame.width(w);
    }

}