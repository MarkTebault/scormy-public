/**
 * SCORMY PLAYER METHODS
 * 
 * These methods support loading and playing the video
 * 
 */


// variable for the YouTube video player (YT.Player) instance.
let player;

// used for CORS
let origin			= window.location.origin;

/**
 * This loads the YouTube API which in turn loads the video.
 */
 function loadVideoAPI(){   

    // add the youtube api
    var tag = document.createElement('script');

    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
}

/**
 * This is called when the YouTube script loads
 */
 function onYouTubeIframeAPIReady() {
    console.log("onYouTubeIframeAPIReady called");
    player = new YT.Player('player', {
        height: playerHeight,
        width:  playerWidth,
        videoId: videoId,
        origin: origin,
        rel:1,
        playerVars: {
                'playsinline': 1
            },
            events: {
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange
            }
        });
    
}


/**
 * When the video player is ready, start tracking
 */
function onPlayerReady(){
  
    //initialize tracking values
    initializeTracking();
    startTracking();

    // show the buttons
    $('#buttons').show();
}

/**
 * Toggle the play button and pause button depending
 * on if the video is playing or not.  This is separate
 * from the togglePlayPause method since the user could
 * choose to play and pause using the video controls rather
 * than the button.
 */
function onPlayerStateChange(event){
    let isPlaying = event.data == YT.PlayerState.PLAYING;
    setButtonState('btnPlayPause', isPlaying);
}

/**
 * depending on the current state of the video, this will either
 * play the video, or pause the video
 */
function togglePlay(){

    console.log("togglePlay");
  
    const NOTSTARTED    = -1;
    const ENDED         = 0;
    const PLAYING       = 1;
    const PAUSED        = 2;
    const BUFFERING     = 3;
    const VIDEOCUED     = 5;


    let state = player.getPlayerState();

    switch(state){

        case VIDEOCUED:
            player.playVideo();
            startTracking();
            break;
        case NOTSTARTED:
            player.playVideo();
            startTracking();
            break;
        case PLAYING:
            player.pauseVideo();
            stopTracking();
            break;    
        case PAUSED:
            player.playVideo();
            startTracking();
            break;
        default:
            player.pauseVideo();
            stopTracking();
            break;
    }

}

/**
 * If the user skipped the video, this returns the user 
 * to the first point they did not watch.
 */
function seek(){
    const seekPoint = getFirstSeekPoint();
    player.seekTo(seekPoint, true);
}

