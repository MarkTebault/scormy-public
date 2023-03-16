/**
 * SCORM TRACKING
 * 
 * Tracking variables are used to track a user's progress watching the video.
 * Once initialized, an array of zeros is updated for each block of the video watched.
 * When all the values in the array are changed from 0 to 1, the progress is 100%.
 * 
 * For example:  Assume a video is 1 minute long.  Assume the trackingBlockSize is 5.
 *   This means the array will have 12 0s                       [0,0,0,0,0,0,0,0,0,0,0,0] 
 *   When the user watchs the 1st 5 seconds, the array becomes  [1,0,0,0,0,0,0,0,0,0,0,0] 
 *   If the user skips to the end and watches the last 5, then  [1,0,0,0,0,0,0,0,0,0,0,1] 
 *   This prevents the user from skipping ahead and cheating.
 * 
 */

// duration of the blocks we are tracking
// example: 5 means we track every 5 seconds of the video
const trackingBlockSize = 5;

// the number of tracking blocks
// this is the duration divided by the block size
let numTrackingBlocks = 0;

// used to track video progress
// the array contains a number for every trackingBlock
// for example, a 30 second video with 5 second blocks would have
// a tracking array with 6 numbers (numTrackingBlocks):  0,0,0,0,0,0
// when each 5 second block is viewed, the number is changed to 1
let trackingArray;

// This is the ID of the interval method
// it is needed to cancel the interval when complete
let trackingInterval;

// the tracking interval delay
// value is in milliseconds
let trackingDelay = 1000; 

// video length
let duration = 0;



/**
 * Initializes the tracking variables
 */
 function initializeTracking(){
    // set the total length of video in seconds
    duration = player.getDuration();

    // the trackingDuration is the number of blocks we will track based on the 
    // tracking block duration and actual duration
    const trackingDuration = duration - (duration % trackingBlockSize);

    // the numTrackingBlocks is the number of tracking blocks
    numTrackingBlocks = Math.round(trackingDuration/trackingBlockSize);

    // the trackingArrayLength is the array length needed
    const trackingArrayLength = numTrackingBlocks + 1;

    // the tracking array is a series of 0s that turn to 1 when that block is watched
    // suspendData comes from the LMS.  This is stored when the user exits the course
    // and returns
    if (suspendData != 'undefined' && suspendData.length > 0){
        // convert the suspendData to and array
        trackingArray = suspendData.split(",");

        // and go to the first unwatched part of the video
        seek();
    }else{
        trackingArray = new Array(trackingArrayLength).fill(0);
    }

    trackProgress();

}

/**
* Starts the tracking interval
*/
function startTracking(){
   // track user progress every {trackingDelay} milliseconds
   trackingInterval = setInterval(trackProgress, trackingDelay);
}

/**
* clears the tracking interval
*/
function stopTracking(){
   clearInterval(trackingInterval);
}
/**
* tracks user progress
*/
function trackProgress(){
   // percent complete
   const percentComplete = getPercentComplete();

   // when the video ends, stop the tracking
   if (percentComplete >= requiredPercentage){
       stopTracking();
       markComplete();
   }
}

/// this method is called to start return the percent complete
function getPercentComplete(){
   // get current time in video in seconds
   const timeInVideo = Math.round(player.getCurrentTime());

   // get the index into the tracking array
   const index = Math.round(timeInVideo/trackingBlockSize);

   // update tracking array to show this 5 second block has been watched
   trackingArray[index] = 1;
   
   // calculate the percentage of the video watched
   const blocksCompleteArray = trackingArray.filter(item => {return item == 1});
   const blocksComplete = blocksCompleteArray.length;


   // percent complete
   let percentComplete = Math.round((blocksComplete * 100)/numTrackingBlocks);

   // just catch weird exceptions
   if (percentComplete > 100) percentComplete = 100;
   return percentComplete;
}

/**
 * Find the first spot the user has not watched 
 * @returns seconds into video to seek to or 0
 */
function getFirstSeekPoint(){

    // each watched block is 1, so the first 0 indicates
    // a block that has not been watched.  So find the first
    // 0 block and then seek to that location.
    const firstZero = trackingArray.findIndex(item =>{
        return item == 0;
    });

    let seekTo = 0;
    // if all tracking Array are set to 1, then undefined is returned.
    if (firstZero != 'undefined'){
        seekTo =  (firstZero * trackingBlockSize)-1;
        
    }
    return seekTo;

}