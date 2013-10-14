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


#import "MediaTableViewController.h"
#import "AppDelegate.h"
#import "Media.h"

static NSString *const kPrefMediaListURL = @"media_list_url";

@implementation MediaTableViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  appDelegate.mediaList.delegate = self;

  if (!appDelegate.mediaList.loaded) {
    [self onDefaultsChanged:nil];
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onDefaultsChanged:)
                                               name:NSUserDefaultsDidChangeNotification
                                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [appDelegate.mediaList cancelLoad];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSUserDefaultsDidChangeNotification
                                                object:nil];
  [super viewWillDisappear:animated];
}

- (void)showError:(NSString *)message {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                        otherButtonTitles:nil];
  [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [appDelegate.mediaList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"MediaCell"];
  }

  const Media *media = [appDelegate.mediaList itemAtIndex:indexPath.row];
  cell.textLabel.text = media.title;
  cell.detailTextLabel.text = media.mimeType;

  BOOL selected = [self.selectedMediaURL isEqual:media.url];
  cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark
      : UITableViewCellAccessoryNone;

  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Media *media = [appDelegate.mediaList itemAtIndex:indexPath.row];
  [self.selectionDelegate mediaWasSelected:media];

  [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - MediaListDelegate

- (void)mediaListDidLoad:(MediaList *)list {
  [self.tableView reloadData];
}

- (void)mediaList:(MediaList *)list didFailToLoadWithError:(NSError *)error {
  NSString *message = [NSString stringWithFormat:@"Unable to download the media list:\n%@",
                       [error localizedDescription]];
  [self showError:message];
}

#pragma mark - Preferences

- (void)onDefaultsChanged:(NSNotification *)notification {
  NSLog(@"preferences changed");
  NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

  NSString *urlText = [standardDefaults stringForKey:kPrefMediaListURL];
  NSURL *url = [NSURL URLWithString:urlText];

  [appDelegate.mediaList loadFromURL:url];
}

@end
