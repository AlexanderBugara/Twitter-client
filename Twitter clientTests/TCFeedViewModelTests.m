//
//  TCFeedViewModelSpec.m
//  Twitter client
//
//  Created by Alexander on 9/23/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "Kiwi.h"
#import "TCFeedViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Accounts/Accounts.h>
#import "ACAccountViewModel.h"

@interface TCFeedViewModel(TCFeedViewModelTests)
- (id)jsonFromData:(NSData *)data;
- (RACSignal *)signalExtractAccounts:(NSArray * (^)(void))listAccountsBlock
                          permission:(RACSignal * (^)(void))permissionBlock;
@end


SPEC_BEGIN(TCFeedViewModelTests)

describe(@"get accounts", ^{
  
  __block NSMutableArray *accounts = nil;
  int accountsNumber = 4;
  __block RACSignal *signal = nil;
  __block TCFeedViewModel *feedViewModel = nil;
  
  beforeEach(^{
    feedViewModel = [TCFeedViewModel new];
    accounts = [NSMutableArray array];
    
    for (int i = 0; i < accountsNumber; i++) {
      ACAccount *account = [ACAccount mock];
      [account stubMessagePattern:[[KWMessagePattern alloc] initWithSelector:@selector(identifier)] withBlock:^id(NSArray *params) {
        return [NSString stringWithFormat:@"%d",i];
      }];
      
      [account stubMessagePattern:[[KWMessagePattern alloc] initWithSelector:@selector(username)] withBlock:^id(NSArray *params) {
        return [NSString stringWithFormat:@"username_%d",i];
      }];
      [accounts addObject:account];
    }
    
    signal = [feedViewModel signalExtractAccounts:^NSArray *{
      return accounts;
    } permission:^RACSignal *{
      return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:RACTuplePack(@(YES), nil)];
        [subscriber sendCompleted];
        return nil;
      }];
    }];
    
  });
  
  it(@"should convert accounts to accounts models", ^{
    
    [signal subscribeNext:^(NSArray *x) {
      [[x should] beKindOfClass:[NSArray class]];
        [[[x should] have:accountsNumber] items];
      
        [x enumerateObjectsUsingBlock:^(ACAccountViewModel * _Nonnull accountViewModel, NSUInteger idx, BOOL * _Nonnull stop) {
          ACAccount *account = accounts[idx];
          [[accountViewModel.account should] equal:account];
          [[accountViewModel.userName should] equal:account.username];
          [[[accountViewModel identifier] should] equal:account.identifier];
        }];
      
    }];
  });
  
  it(@"should be username value match as selected accountviewmodel", ^{
    
    [signal subscribeNext:^(NSArray *x) {
      
      if (accountsNumber > 0) {
        ACAccount *account = accounts[0];
        ACAccountViewModel *accountViewModel = x[0];
        [feedViewModel setAccountViewModel:accountViewModel];
        [[feedViewModel.navigationItemTitle should] equal:[account username]];
      }
      
    }];
  });
  
  
  
});
SPEC_END
