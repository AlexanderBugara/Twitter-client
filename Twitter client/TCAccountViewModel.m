//
//  TCAccountViewModel.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import "TCAccountViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Accounts/Accounts.h>
#import "Account+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import "TCTwittViewModel.h"
#import "CEObservableMutableArray.h"
#import "Twitt+CoreDataClass.h"
#import "AppDelegate.h"

@interface TCAccountViewModel()
@property (nonatomic, strong) ACAccount *account;
@property (nonatomic, strong) CEObservableMutableArray *twitts;
@property (nonatomic, strong) Account *managedObjectAccount;
@end

@implementation TCAccountViewModel

- (id)initWithAccount:(ACAccount *)account {
  if (self = [super init]) {
    _account = account;
    _managedObjectAccount = [self accountWithContext:[self managedObjectContext]];
    _twitts = [[CEObservableMutableArray alloc] init];
  }
  return self;
}

- (NSString *)userName {
  return self.account.username;
}

- (ACAccount *)account {
  return _account;
}

- (NSString *)identifier {
  return self.account.identifier;
}


- (Account *)fetchAccount:(NSManagedObjectContext *)managedOjectContext {
  
  Account *result = nil;
  
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@",[self identifier]];
  fetchRequest.predicate = predicate;
  NSError *error;
  NSArray *accounts = [managedOjectContext executeFetchRequest:fetchRequest error:&error];
  if ([accounts count] > 0) {
    result = accounts[0];
  }
  
  return result;
}

- (Account *)createAccount:(NSManagedObjectContext *)managedObjectContext {
  
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:managedObjectContext];
  Account *result = [[Account alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
  
  result.username = [self userName];
  result.identifier = [self identifier];
  
  return result;
  
}

- (Account *)accountWithContext:(NSManagedObjectContext *)managedOjectContext {
    Account *result = [self fetchAccount:managedOjectContext];
    if (!result) {
      result = [self createAccount:managedOjectContext];
      [self saveContext];
    }
    return result;
}

- (void)addTwittViewModel:(TCTwittViewModel *)twittViewModel {
  
  self.managedObjectAccount = [self accountWithContext:[[twittViewModel twitt] managedObjectContext]];
  [self.managedObjectAccount addTwittsObject:[twittViewModel twitt]];
  [self.twitts addObject:twittViewModel];
}

- (CEObservableMutableArray *)twitts {
  return _twitts;
}

- (void)saveContext {
  [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
}

- (void)extractOfflineTwitts {
  
  CEObservableMutableArray *result = [CEObservableMutableArray new];
  NSArray *array = [self.managedObjectAccount.twitts allObjects];
  for (Twitt *twitt in array) {
    TCTwittViewModel *twittViewModel = [[TCTwittViewModel alloc] initWithTwitt:twitt];
    [result addObject:twittViewModel];
  }
  self.twitts = result;
  
}

- (NSManagedObjectContext *)managedObjectContext {
  return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

- (void)deleteTwitts {
   NSArray *twitts = [self.managedObjectAccount.twitts allObjects];
  for (Twitt *twitt in twitts) {
    [[self managedObjectContext] deleteObject:twitt];
  }
  [self saveContext];
  [self.twitts removeAllObjects];
}

@end
