//
//  ViewController.m
//  Twitter client
//
//  Created by Alexander on 9/21/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import "TCFeedViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Accounts/Accounts.h>
#import "ACAccountViewModel.h"

@interface TCFeedViewModel ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation TCFeedViewModel

- (RACSignal *)signalGetTwitterAccounts {
  RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    @weakify(self);
    [self_weak_.accountStore requestAccessToAccountsWithType:[self_weak_ accountType] options:nil completion:^(BOOL granted, NSError *error) {
      if (granted) {
        
        NSArray *accounts = [self_weak_.accountStore accountsWithAccountType:[self_weak_ accountType]];
        
        [subscriber sendNext:[self_weak_ viewModelsForAccounts:accounts]];
        [subscriber sendCompleted];
      } else {
        
      }
    }];
    return nil;
  }];
  return [result deliverOnMainThread];
}

- (NSArray *)viewModelsForAccounts:(NSArray *)accounts {
  
  NSMutableArray *viewModels = [NSMutableArray array];
  
  for (ACAccount *account in accounts) {
    ACAccountViewModel *viewModel = [[ACAccountViewModel alloc] initWithAccount:account];
    [viewModels addObject:viewModel];
  }
  
  return [NSArray arrayWithArray:viewModels];
}

- (ACAccountStore *)accountStore {
  if (_accountStore == nil) {
    _accountStore = [ACAccountStore new];
  }
  return _accountStore;
}

- (ACAccountType *)accountType {
  return [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
}
@end


@interface TCFeedViewController ()
@property (nonatomic, strong) TCFeedViewModel *viewModel;
@property (nonatomic, strong) ACAccountViewModel *selectedAccountViewModel;
@end

@implementation TCFeedViewController

- (IBAction)loginAction:(id)sender {
  [self selectLoginAccaunt];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configure];
  [self selectLoginAccaunt];
}

- (TCFeedViewModel *)viewModel {
  if (!_viewModel) {
    _viewModel = [TCFeedViewModel new];
  }
  return _viewModel;
}

- (void)configure {
  @weakify(self);
  RAC(self_weak_, navigationItem.title) = [RACObserve(self_weak_, viewModel.userName) deliverOnMainThread];
}

- (BOOL)isArrayAndItNotAmpty:(id)obj {
  return ([obj isKindOfClass:[NSArray class]] && [(NSArray *)obj count] > 0);
}

- (UIAlertAction *)actionWithTitle:(NSString *)title
                           handler:(void (^ __nullable)(void)) block {
  
  return [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      block();
  }];
}

- (void)selectLoginAccaunt {
  
  @weakify(self);
  [[self.viewModel signalGetTwitterAccounts] subscribeNext:^(id x) {
    
    if ([self_weak_ isArrayAndItNotAmpty:x]) {
      UIAlertController *accountSelection = [[UIAlertController alloc] init];
      
      for (ACAccountViewModel *viewModel in (NSArray *)x) {
        [accountSelection addAction:[self_weak_ actionWithTitle:viewModel.userName handler:^{
              self_weak_.selectedAccountViewModel = viewModel;
              self_weak_.viewModel.userName = viewModel.userName;
        }]];
      }
      
      [self_weak_ presentViewController:accountSelection animated:YES completion:nil];
    }
  }];
  
}

@end
