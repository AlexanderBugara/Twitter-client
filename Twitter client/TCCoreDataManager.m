//
//  TCCoreDataManager.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import "TCCoreDataManager.h"
#import "TCTwittViewModel.h"
#import "Account+CoreDataClass.h"
#import "AppDelegate.h"
#import "Twitt+CoreDataClass.h"
#import "ACAccountViewModel.h"

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

- (NSArray *)start {
  @try {
    Account *account = [self currentAccount];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *item in [self feedArray]) {
      TCTwittViewModel *twittModel = [[TCTwittViewModel alloc] initWithJson:item account:account managedObjectContext:[self managedObjectContext]];
      [result addObject:twittModel];
    }
    return result;
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

- (Account *)currentAccount {
  NSFetchRequest *fetchRequest = [Account fetchRequest];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@",[self.accountViewModel identifier]];
  fetchRequest.predicate = predicate;
  NSError *error;
  NSArray *accounts = [fetchRequest execute:&error];
  
  Account *result = nil;
  if ([accounts count] > 0) {
    result = accounts[0];
  } else {
    result = [[Account alloc] initWithEntity:[Account entity] insertIntoManagedObjectContext:[self managedObjectContext]];
  }
  return result;
}

- (NSManagedObjectContext *)managedObjectContext {
  return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}
@end
