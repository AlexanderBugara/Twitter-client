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
#import "TCAccountViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TCTwittViewModel.h"
#import "CEObservableMutableArray.h"

@implementation TCFeedOnlineFetch


+ (RACSignal *)signalNetworkFeedAccount:(TCAccountViewModel *)accountViewModel {
  return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[TCTwitterPaths feedPath]] parameters:@{@"count" : @"50", @"screen_name" : accountViewModel.userName}];
    
    feedRequest.account = [accountViewModel account];
    [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
      
      if (error) {
        [subscriber sendError:error];
      } else {
        [subscriber sendNext:responseData];
        [subscriber sendCompleted];
      }
    }];
    
    return nil;
  }] deliverOnMainThread];
}

+ (void)fetchWith:(TCAccountViewModel *)accountViewModel
complitionHandler:(void (^)(CEObservableMutableArray *result, NSError *error))handler
{
  @try {
   
    __weak __typeof (self) weakSelf = self;
    
    RACSignal *signal = [[[self signalNetworkFeedAccount:accountViewModel] flattenMap:^RACStream *(id value) {
      return [weakSelf signalJsonFromData:value];
    }] flattenMap:^RACStream *(NSArray *twitts) {
      return [weakSelf signalCoreDataImport:twitts accountViewModel:accountViewModel];
    }];
    
    [signal subscribeNext:^(id x) {
      if ([x isKindOfClass:[CEObservableMutableArray class]]) {
        handler(x, nil);
      }
    }];
    
    [signal subscribeError:^(NSError *error) {
      handler(nil, error);
    }];
    
  } @catch (NSException *exception) {
    NSLog(@"TCFeedOnlineFetch fetch error");
  } @finally {
    
  }  
}

+ (RACSignal *)signalJsonFromData:(NSData *)data {
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    if (!data) return nil;
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
      [subscriber sendError:error];
    } else {
      [subscriber sendNext:result];
      [subscriber sendCompleted];
    }
    return nil;
  }];
}

+ (RACSignal *)signalCoreDataImport:(NSArray *)feedArray accountViewModel:(TCAccountViewModel *)accountViewModel{
  
  return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    
    CEObservableMutableArray *result = [[CEObservableMutableArray alloc] init];
    
    for (NSDictionary *item in feedArray) {
      TCTwittViewModel *twittModel = [[TCTwittViewModel alloc] initWithJson:item account:[accountViewModel account]];
      [accountViewModel addTwittViewModel:twittModel];
      [result addObject:twittModel];
    }
    
    [accountViewModel saveContext];
    [subscriber sendNext:result];
    [subscriber sendCompleted];
    
    return nil;
  }] deliverOnMainThread];
  
}

@end
