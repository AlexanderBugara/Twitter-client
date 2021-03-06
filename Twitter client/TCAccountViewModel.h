//
//  TCAccountViewModel.h
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount, Account, NSManagedObjectContext, TCTwittViewModel, CEObservableMutableArray;

@interface TCAccountViewModel : NSObject
- (NSString *)userName;
- (id)initWithAccount:(ACAccount *)account;
- (ACAccount *)account;
- (NSString *)identifier;
- (Account *)accountWithContext:(NSManagedObjectContext *)managedOjectContext;
- (void)addTwittViewModel:(TCTwittViewModel *)twittViewModel;
- (CEObservableMutableArray *)twitts;
- (void)saveContext;
- (void)extractOfflineTwitts;
- (void)deleteTwitts;
@end
