//
//  TCFeedOnlineViewModel.h
//  Twitter client
//
//  Created by Alexander on 9/25/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccountViewModel, CEObservableMutableArray;

@interface TCFeedOnlineFetch : NSObject
+ (void)fetchWith:(ACAccountViewModel *)accountViewModel
complitionHandler:(void (^)(CEObservableMutableArray *result, NSError *error))handler;
@end
