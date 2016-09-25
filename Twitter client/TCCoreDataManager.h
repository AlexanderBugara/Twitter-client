//
//  TCCoreDataManager.h
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccountViewModel, CEObservableMutableArray;

@interface TCCoreDataManager : NSObject
- (id)initWithTwitterFeed:(id)twitterFeed forAccount:(ACAccountViewModel *)accountViewModel;
- (CEObservableMutableArray *)start;
@end
