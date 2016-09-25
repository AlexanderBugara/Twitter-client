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
#import "CETableViewBindingHelper.h"
#import "CEObservableMutableArray.h"
#import "Reachability.h"
#import "TCFeedOnlineFetch.h"
#import "AppDelegate.h"
#import "TCTwittViewModel.h"

@interface TCFeedViewModel ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountViewModel *selectedAccountViewModel;
@property (assign) BOOL isOfflineMode;
@end

@implementation TCFeedViewModel

- (void)extractAccounts {
  
  __weak __typeof (self) weakSelf = self;
  [self.accountStore requestAccessToAccountsWithType:[self accountType] options:nil completion:^(BOOL granted, NSError *error) {
    if (granted) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *accounts = [weakSelf.accountStore accountsWithAccountType:[weakSelf accountType]];
        weakSelf.accounts = [self viewModelsForAccounts:accounts];
      });
      
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

- (void)setAccountViewModel:(ACAccountViewModel *)accountViewModel {
  _selectedAccountViewModel = accountViewModel;
  [self setNavigationItemTitle:accountViewModel.userName];
}

- (BOOL)isNetworkReachable {
  NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
  return (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN);
}

- (void)pullFeed {
  if ([self isNetworkReachable]) {
    
    [self clearFeed];
    
    __weak __typeof (self) weakSelf = self;
    [TCFeedOnlineFetch fetchWith:self.selectedAccountViewModel complitionHandler:^(CEObservableMutableArray *result) {
      weakSelf.twitts = result;
    }];
  } else {
    [self.selectedAccountViewModel extractOfflineTwitts];
    self.twitts = [self.selectedAccountViewModel twitts];
  }
}

- (void)clearFeed {  
  for (TCTwittViewModel *twitterViewModel in self.twitts) {
    [twitterViewModel markAsDeleteTwitt];
  }
  [self.twitts removeAllObjects];
  [self saveManagedObgectContext];
}

- (void)saveManagedObgectContext {
  [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
}

@end


@interface TCFeedViewController ()
@property (nonatomic, strong) TCFeedViewModel *viewModel;
@property (nonatomic, strong) NSArray *accounts;
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
  
  UINib *nib = [UINib nibWithNibName:@"TCTwitterCell" bundle:nil];
  [CETableViewBindingHelper bindingHelperForTableView:self.tableView
                                          sourceSignal:[RACObserve(_viewModel, twitts) deliverOnMainThread]
                                      selectionCommand:nil
                                          templateCell:nib];
  
  UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
  refresh.tintColor = [UIColor grayColor];
  refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
  [refresh addTarget:self action:@selector(pullToRefreshAction:) forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refresh;
  
}

- (void)pullToRefreshAction:(id)sender {
  @weakify(self);
  [RACObserve(_viewModel, twitts) subscribeNext:^(id x) {
    [self_weak_.refreshControl endRefreshing];
  }];
  [self.viewModel pullFeed];
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
      [weakSelf.viewModel setAccountViewModel:viewModel];
      [weakSelf.viewModel pullFeed];
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
