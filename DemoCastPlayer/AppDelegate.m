// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


#import "AppDelegate.h"
#import "MediaList.h"

NSString *const kReceiverAppName = @"GoogleCastPlayer";

@interface AppDelegate () <GCKLoggerDelegate>

@property(nonatomic, strong, readwrite) GCKContext *context;
@property(nonatomic, strong, readwrite) GCKDeviceManager *deviceManager;
@property(nonatomic, strong, readwrite) MediaList *mediaList;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *appIdentifier = [info objectForKey:@"CFBundleIdentifier"];
  [GCKLogger sharedInstance].delegate = self;
  self.context = [[GCKContext alloc] initWithUserAgent:appIdentifier];
  self.deviceManager = [[GCKDeviceManager alloc] initWithContext:self.context];
  [self populateRegistrationDomain];

  self.mediaList = [[MediaList alloc] init];

  return YES;
}

- (void)populateRegistrationDomain {
   NSURL *settingsBundleURL = [[NSBundle mainBundle] URLForResource:@"Settings"
                                                      withExtension:@"bundle"];
  NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
  [self loadDefaults:appDefaults
           fromSettingsPage:@"Root.plist"
      inSettingsBundleAtURL:settingsBundleURL];
  [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadDefaults:(NSMutableDictionary *)appDefaults
         fromSettingsPage:(NSString *)plistName
    inSettingsBundleAtURL:(NSURL *)settingsBundleURL {
  NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfURL:
                                [settingsBundleURL URLByAppendingPathComponent:plistName]];
  NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];

  for (NSDictionary *prefItem in prefSpecifierArray) {
    NSString *prefItemType = prefItem[@"Type"];
    NSString *prefItemKey = prefItem[@"Key"];
    NSString *prefItemDefaultValue = prefItem[@"DefaultValue"];

    if ([prefItemType isEqualToString:@"PSChildPaneSpecifier"]) {
      NSString *prefItemFile = prefItem[@"File"];
      [self loadDefaults:appDefaults fromSettingsPage:prefItemFile
           inSettingsBundleAtURL:settingsBundleURL];
    } else if (prefItemKey && prefItemDefaultValue) {
       [appDefaults setObject:prefItemDefaultValue forKey:prefItemKey];
    }
  }
}

#pragma mark - GCKLoggerDelegate

- (void)logFromFunction:(const char *)function message:(NSString *)message {
  NSLog(@"%s  %@", function, message);
}

@end
