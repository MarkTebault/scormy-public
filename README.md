# SCORMY

SCORMY is an app used to wrap YouTube videos and other online content in a SCORM-compliant wrapper for use in learning management systems.  This is a real app available for download on the Microsoft Store and Apple Store.

This is my first Flutter app and I really appreciate the public information I used to help me learn Flutter.  I want to return the favor and make the code available for others to view in case it helps someone else learn.  I am not a Flutter guru, so keep in mind when viewing the code.

## Getting Started

The App copies course templates from the assets bundle into temporary storage on the current device.  It then takes input from the user and updates key properties of the files such as course title and content.  The files are then copied to a folder and compressed into a ZIP archive.

On desktop applications, the file is saved to a local drive.  One mobile devices the file is emailed to a presumably an LMS administrator.  This is due to the complexity in retrieving and sharing files from a mobile device.

I chose not to release the Android or Linux version basically due to lack of demand and lack of time to test those systems.

## Course Templates
There are two course templates:  youtube and embed.  The files are in a single folder due to an issue with the compression into ZIP.  The folders shown as 0 byte compressed files, which caused the SCORM parsor to complain.  I fixed it by removing all folders.

I purposely kept this extremely simple.  I will continue to build it and make it more complex over time, so look for updates.

## Disclaimer
I attempted to remove all private information.  If you find something that you feel should be private, pleae let me know so I can remove it.

It is also unlikely the code will complile as is.  You will need to update your system to address any issues due to my removing some key values.

I am making this available for information purposes only.  It would be bad karma if you used it to compete with me :)

## Apps
If you want to download the actual apps, you can get them here:

 - [Get SCORM from Microsoft Store](https://www.microsoft.com/store/apps/9PLXXW8783CJ)
 - [Get SCORMY from Apple Mac Store](https://apple.co/3I9QEhO)
 - [Get SCORMY from Apple App Store](https://apple.co/3I9QEhO)



