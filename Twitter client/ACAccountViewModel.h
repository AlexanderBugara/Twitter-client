//
//  ACAccountViewModel.h
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;

@interface ACAccountViewModel : NSObject
- (NSString *)userName;
- (id)initWithAccount:(ACAccount *)account;
- (ACAccount *)account;
@end
