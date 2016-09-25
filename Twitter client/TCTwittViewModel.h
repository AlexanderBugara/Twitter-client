//
//  TCTwittViewModel.h
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Twitt, NSManagedObjectContext, Account;

@interface TCTwittViewModel : NSObject
- (id)initWithJson:(NSDictionary *)json
managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (Twitt *)twitt;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *text;
@end
