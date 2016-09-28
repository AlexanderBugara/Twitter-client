//
//  TCTwittViewModel.h
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEReactiveView.h"

@class Twitt, NSManagedObjectContext, Account, RACSignal, ACAccount;

@interface TCTwittViewModel : NSObject<InterfaceCastomisation>
- (id)initWithJson:(NSDictionary *)json account:(ACAccount *)account
managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (Twitt *)twitt;
- (id)initWithTwitt:(Twitt *)twitt;
- (void)markAsDeleteTwitt;
- (RACSignal *)signalUserImage;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *text;
@end
