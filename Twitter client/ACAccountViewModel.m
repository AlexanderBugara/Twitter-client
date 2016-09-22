//
//  ACAccountViewModel.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import "ACAccountViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Accounts/Accounts.h>

@interface ACAccountViewModel()
@property (nonatomic, strong) ACAccount *account;
@end

@implementation ACAccountViewModel

- (id)initWithAccount:(ACAccount *)account {
  if (self = [super init]) {
    _account = account;
  }
  return self;
}

- (NSString *)userName {
  return self.account.username;
}

- (ACAccount *)account {
  return _account;
}

@end
