//
//  TCCoreDataManager.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import "TCCoreDataManager.h"
#import "TCTwittViewModel.h"

@interface TCCoreDataManager ()
@property (nonatomic, strong) id twitterFeed;
@end

@implementation TCCoreDataManager

- (id)initWithTwitterFeed:(id)twitterFeed {
  if (self = [super init]) {
    _twitterFeed = twitterFeed;
  }
  return self;
}

- (void)start {
  @try {
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *item in [self feedArray]) {
      TCTwittViewModel *twittModel = [[TCTwittViewModel alloc] initWithTitle:@"" imagePath:@""];
      [result addObject:twittModel];
    }
    
  } @catch (NSException *exception) {
    
  } @finally {
    
  }
}

- (NSArray *)feedArray {
  
  NSArray *result = nil;
  if ([self.twitterFeed isKindOfClass:[NSArray class]]) {
    result = self.twitterFeed;
  }
  return result;
}

@end
