//
//  TCTwittViewModelTests.m
//  Twitter client
//
//  Created by Alexander on 10/2/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "Kiwi.h"
#import "TCAccountViewModel.h"
#import <Accounts/Accounts.h>

SPEC_BEGIN(TCAccountViewModelTests)

describe(@"TCAccountViewModel", ^{
  context(@"creating from core data object", ^{
    ACAccount *account = [ACAccount mock];
    [account stubMessagePattern:[[KWMessagePattern alloc] initWithSelector:@selector(identifier)] withBlock:^id(NSArray *params) {
      return @"useridentifier";
    }];
    
    [account stubMessagePattern:[[KWMessagePattern alloc] initWithSelector:@selector(username)] withBlock:^id(NSArray *params) {
      return [NSString stringWithFormat:@"myscreen_username"];
    }];
    
    TCAccountViewModel *accountViewModel = [[TCAccountViewModel alloc] initWithAccount:account];
    it(@"should be mutched username property", ^{
      [[[[accountViewModel account] username] should] equal:@"myscreen_username"];
    });
    it(@"should be mutched useridentifier property", ^{
      [[[[accountViewModel account] identifier] should] equal:@"useridentifier"];
    });
    it(@"shold be mutched account with property account ", ^{
      [[[accountViewModel account] should] equal:account];
    });
    
  });
});

SPEC_END
