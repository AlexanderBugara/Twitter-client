//
//  TCCoreDataManager.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import "TCCoreDataManager.h"
#import "TCTwittViewModel.h"
#import "AppDelegate.h"
#import "Twitt+CoreDataClass.h"
#import "ACAccountViewModel.h"
#import "Account+CoreDataClass.h"

@interface TCCoreDataManager ()
@property (nonatomic, strong) id twitterFeed;
@property (nonatomic, strong) ACAccountViewModel *accountViewModel;
@end

@implementation TCCoreDataManager

- (id)initWithTwitterFeed:(id)twitterFeed forAccount:(ACAccountViewModel *)accountViewModel {
  if (self = [super init]) {
    _twitterFeed = twitterFeed;
    _accountViewModel = accountViewModel;
  }
  return self;
}

- (void)start {
  @try {
    for (NSDictionary *item in [self feedArray]) {
      TCTwittViewModel *twittModel = [[TCTwittViewModel alloc] initWithJson:item managedObjectContext:[self managedObjectContext]];
      [self.accountViewModel addTwittViewModel:twittModel];
    }
    [self.accountViewModel saveContext];
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

- (NSManagedObjectContext *)managedObjectContext {
  return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

- (CEObservableMutableArray *)twitts {
  return [self.accountViewModel twitts];
}
@end
