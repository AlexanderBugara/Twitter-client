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
#import "TCTwitterPaths.h"
#import <Social/Social.h>
#import "TCCoreDataManager.h"

@interface TCFeedViewModel ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountViewModel *selectedAccountViewModel;
@property (nonatomic, strong) NSArray *twitts;
@end

@implementation TCFeedViewModel

- (void)extractAccounts {
  
  __weak __typeof (self) weakSelf = self;
  [self.accountStore requestAccessToAccountsWithType:[self accountType] options:nil completion:^(BOOL granted, NSError *error) {
    if (granted) {
      NSArray *accaunts = [weakSelf.accountStore accountsWithAccountType:[weakSelf accountType]];
      weakSelf.accounts = [self viewModelsForAccounts:accaunts];
      
    } else {
      
    }
  }];
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

- (void)setAccauntViewModel:(ACAccountViewModel *)accountViewModel {
  _selectedAccountViewModel = accountViewModel;
  [self setNavigationItemTitle:accountViewModel.userName];
}

- (void)downloadTwitterFeed {
  SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[TCTwitterPaths feedPath]] parameters:@{@"count" : @"50", @"screen_name" : @"test"}];
  
  feedRequest.account = [self account];
  __weak __typeof (self) weakSelf = self;
  [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
      id responseJson = [weakSelf jsonFromData:responseData];
      TCCoreDataManager *coreDataManager = [[TCCoreDataManager alloc] initWithTwitterFeed:responseJson];
      [coreDataManager start];
  }];
}

- (ACAccount *)account {
  return [self.selectedAccountViewModel account];
}

- (id)jsonFromData:(NSData *)data {
  NSError *error;
  return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
}
@end


@interface TCFeedViewController ()
@property (nonatomic, strong) TCFeedViewModel *viewModel;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) NSArray *twitts;
@end

@implementation TCFeedViewController

- (IBAction)loginAction:(id)sender {
  [self.viewModel extractAccounts];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configure];
  [self.viewModel extractAccounts];
}

- (TCFeedViewModel *)viewModel {
  if (!_viewModel) {
    _viewModel = [TCFeedViewModel new];
  }
  return _viewModel;
}

- (void)configure {
  @weakify(self);
  RAC(self_weak_, navigationItem.title) = [RACObserve(self_weak_, viewModel.navigationItemTitle) deliverOnMainThread];
  RAC(self_weak_, accounts) = [RACObserve(self_weak_, viewModel.accounts) deliverOnMainThread];
  RAC(self_weak_, twitts) = [RACObserve(self_weak_, viewModel.twitts) deliverOnMainThread];
}

- (UIAlertAction *)actionWithTitle:(NSString *)title
                           handler:(void (^ __nullable)(void)) block {
  
  return [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      block();
  }];
}

- (void)setAccounts:(NSArray *)accounts {
  _accounts = accounts;
  [self displaySelectionOfAccounts:accounts];
}

- (void)displaySelectionOfAccounts:(NSArray *)accounts {
  if ([accounts count] == 0 || accounts == nil) return;
  
  UIAlertController *accountSelection = [[UIAlertController alloc] init];

  __weak __typeof (self) weakSelf = self;
  for (ACAccountViewModel *viewModel in accounts) {
    [accountSelection addAction:[self actionWithTitle:viewModel.userName handler:^{
      [weakSelf.viewModel setAccauntViewModel:viewModel];
      [weakSelf.viewModel downloadTwitterFeed];
    }]];
  }
  [self presentViewController:accountSelection animated:YES completion:nil];
}

- (IBAction)presentTwittSubmitter:(id)sender {
  
  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
    SLComposeViewController *composerViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self presentViewController:composerViewController animated:YES completion:nil];
  }
  
}
@end
