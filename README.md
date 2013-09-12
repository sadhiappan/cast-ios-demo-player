cast-ios-demo-player
====================

This iOS Cast Demo Player shows basic casting of video, audio, and image files to Chromecast and how to create/end/resume/destroy a session.

To build this:

(1) In AppDelegate.m, replace @"[YOUR_APP_NAME]" with your long hex app identifier from your Google whitelist email.
When you are done, it will look something like:

static NSString *kReceiverAppName = @"abcdef-1abc-4def-9876-123456789";

(2) In the Xcode project, correct the path to your copy of the GCKFramework.framework. One way to do this:

(2.a) The left column of Xcode project window should show the File Navigator, and the right column should show the File Inspector.

(2.b) Select GCKFramework.framework in the Frameworks group in the File Navigator.

(2.c) In the File Inspector click the icon on the far right, just below the Location popup dialog item. It will give you an 'Open' dialog box where you can navigate to the your copy of GCKFramework.framework .

(2.d) Depending on where GCKFramework.framework is, you may need to add its parent directory to the FRAMEWORK_SEARCH_PATHS build setting so Xcode can find it.

(3) To install the app on a device, you must edit bundle identifier in DemoCastPlayer-Info.plist from com.google.${PRODUCT_NAME:rfc1034identifier} - replace the 'com.google' with the identifier you registered with Apple in https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action

(4) Put an appropriate receiver program on your web site at the URL specified in your your Google whitelist email. Enclosed is a sample receiver.html to get you started.

(5) Put an appropriate media.xml on your website. Enclosed is a sample media.xml to get you started. Put the URL to that media.xml in the Settings.bundle/Root.plist in this project.

 
 