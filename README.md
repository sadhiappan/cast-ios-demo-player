cast-ios-demo-player
====================

This iOS Cast Demo Player shows basic casting of video, audio, and image files to Chromecast and how to create/end/resume/destroy session.

To build this:

(1) In CastViewController.m, replace @"[YOUR_APP_NAME]" with your long hex app identifier from your Google whitelist email.
When you are done, it will look something like:

static NSString *kReceiverAppName = @"abcdef-1abc-4def-9876-123456789";

(2) In the Xcode project, correct the path to your copy of the GCKFramework.framework. One way to do this:

(2.a) The left column of Xcode project window should show the File Navigator, and the right column should show the File Inspector.

(2.b) Select GCKFramework.framework in the Frameworks group in the File Navigator.

(2.c) in the File Inspector click the icon on the far right, just below the Location popup dialog item. It will give you an 'Open' dialog box where you can navigate to the your copy of GCKFramework.framework .

