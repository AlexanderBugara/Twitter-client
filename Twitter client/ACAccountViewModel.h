//
//  ACAccountViewModel.h
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount, Account, NSManagedObjectContext, TCTwittViewModel, CEObservableMutableArray;

@interface ACAccountViewModel : NSObject
- (NSString *)userName;
- (id)initWithAccount:(ACAccount *)account;
- (ACAccount *)account;
- (NSString *)identifier;
- (Account *)accountWithContext:(NSManagedObjectContext *)managedOjectContext;
- (void)addTwittViewModel:(TCTwittViewModel *)twittViewModel;
- (CEObservableMutableArray *)twitts;
- (void)saveContext;
- (void)extractOfflineTwitts;
@end
