//
//  TCFeedOnlineViewModel.m
//  Twitter client
//
//  Created by Alexander on 9/25/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "TCFeedOnlineFetch.h"
#import <Social/Social.h>
#import "TCTwitterPaths.h"
#import "ACAccountViewModel.h"
#import "TCCoreDataManager.h"

@implementation TCFeedOnlineFetch

+ (void)fetchWith:(ACAccountViewModel *)accountViewModel
complitionHandler:(void (^)(CEObservableMutableArray *result, NSError *error))handler
{
  @try {
    __weak __typeof (self) weakSelf = self;
    SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[TCTwitterPaths feedPath]] parameters:@{@"count" : @"50", @"screen_name" : accountViewModel.userName}];
    
    feedRequest.account = [accountViewModel account];
    [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        
        id responseJson = [weakSelf jsonFromData:responseData];
        TCCoreDataManager *coreDataManager = [[TCCoreDataManager alloc] initWithTwitterFeed:responseJson forAccount:accountViewModel];
        [coreDataManager start];
        handler([coreDataManager twitts], error);
        
      });
      
    }];
  } @catch (NSException *exception) {
    NSLog(@"TCFeedOnlineFetch fetch error");
  } @finally {
    
  }  
}

+ (id)jsonFromData:(NSData *)data {
  
  if (!data) return nil;
  
  NSError *error;
  
  id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
  return result;
}
@end
