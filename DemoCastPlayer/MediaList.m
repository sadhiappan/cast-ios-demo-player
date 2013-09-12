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

#import "MediaList.h"
#import "Media.h"

@interface MediaList () <GCKSimpleHTTPRequestDelegate, NSXMLParserDelegate> {
  GCKSimpleHTTPRequest *_request;
  NSMutableArray *_list;
}

@property(nonatomic, readwrite) BOOL loaded;

@end

@implementation MediaList

- (id)init {
  if (self = [super init]) {
    _list = [[NSMutableArray alloc] init];
  }
  return self;

}

- (void)loadFromURL:(NSURL *)url {
  [_list removeAllObjects];
  if ([url isFileURL]) {
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSLog(@"httpRequest completed with data length %d", [data length]);
    [self parseWithData:data];
  } else {
    _request = [[GCKSimpleHTTPRequest alloc] init];
    _request.delegate = self;
    [_request startGetRequest:url];
  }
  NSLog(@"loading media list from URL %@", url);
}

- (void)cancelLoad {
  if (_request) {
    [_request cancel];
    _request = nil;
  }
}


- (NSUInteger)count {
  return [_list count];
}

- (Media *)itemAtIndex:(NSUInteger)index {
  return (Media *)[_list objectAtIndex:index];
}

#pragma mark - GCKSimpleHTTPRequestDelegate

- (void)httpRequest:(GCKSimpleHTTPRequest *)request
    didCompleteWithStatusCode:(NSInteger)status
                     finalURL:(NSURL *)finalURL
                      headers:(NSDictionary *)headers
                         data:(GCKMimeData *)data {
  NSLog(@"httpRequest completed with %d", status);

  if (status == kGCKHTTPStatusOK) {
    [self parseWithData:data.data];
  } else {
    NSError *error = [[NSError alloc] initWithDomain:@"HTTP" code:status userInfo:nil];
    [self.delegate mediaList:self didFailToLoadWithError:error];
  }
}

- (void)parseWithData:(NSData *)xml {
  NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xml];
  [xmlParser setDelegate:self];
  [xmlParser parse];
  self.loaded = YES;
  [self.delegate mediaListDidLoad:self];
}

- (void)httpRequest:(GCKSimpleHTTPRequest *)request didFailWithError:(NSError *)error {
  NSLog(@"httpRequest failed with %@", error);
  [self.delegate mediaList:self didFailToLoadWithError:error];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qName
         attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"media"]) {
    NSString *title = [attributeDict valueForKey:@"title"];
    NSString *artist = [attributeDict valueForKey:@"artist"];
    NSString *urlString = [attributeDict valueForKey:@"url"];
    NSString *mimeType = [attributeDict valueForKey:@"mimeType"];
    NSString *imageUrlString = [attributeDict valueForKey:@"imageUrl"];
    if (!title || !urlString || !mimeType) return;
    NSURL *imageUrl = nil;
    if (imageUrlString) {
      imageUrl = [NSURL URLWithString:imageUrlString];
    }

    Media *media = [[Media alloc] initWithTitle:title
                                         artist:artist
                                            url:[NSURL URLWithString:urlString]
                                       mimeType:mimeType
                                       imageURL:imageUrl];
    [_list addObject:media];
  }
}

@end
