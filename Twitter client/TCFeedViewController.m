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
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation TCFeedViewModel

- (id)init {
  
  if (self = [super init]) {
      [[self reachability] startNotifier];
  }
  return self;
  
}


- (RACSignal *)signalExtractAccounts {
  
  __weak __typeof (self) weakSelf = self;
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [weakSelf.accountStore requestAccessToAccountsWithType:[weakSelf accountType] options:nil completion:^(BOOL granted, NSError *error) {
      if (granted) {
        dispatch_sync(dispatch_get_main_queue(), ^{
          NSArray *accounts = [weakSelf.accountStore accountsWithAccountType:[weakSelf accountType]];
          [subscriber sendNext:[weakSelf viewModelsForAccounts:accounts]];
          [subscriber sendCompleted];
        });
        
      } else if (error) {
        [subscriber sendError:error];
      }
      
    }];
   return nil;
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

- (void)saveManagedObgectContext {
  [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
}

- (Reachability *)reachability {
  if (_reachability == nil) {
    _reachability = [Reachability reachabilityForInternetConnection];
  }
  return _reachability;
}


- (RACSignal *)signalPullToRefresh {
  
  __weak __typeof (self) weakSelf = self;
  
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    
      if ([self isNetworkReachable]) {
          [self.selectedAccountViewModel deleteTwitts];
      } else {
        
          [[self reachability] startNotifier];
          [self.selectedAccountViewModel extractOfflineTwitts];
          [subscriber sendNext:[self.selectedAccountViewModel twitts]];
      }
    
      [TCFeedOnlineFetch fetchWith:self.selectedAccountViewModel complitionHandler:^(CEObservableMutableArray *result, NSError *error) {
        
        if (error) {
          [subscriber sendError:error];
        } else {
          weakSelf.twitts = result;
          [subscriber sendNext:result];
        }
        [subscriber sendCompleted];
        
      }];
  
    return nil;
  }];
}


@end


@interface TCFeedViewController ()
@property (nonatomic, strong) TCFeedViewModel *viewModel;
@end

@implementation TCFeedViewController

- (void)viewDidLoad {
  [super viewDidLoad];
 
  [self configure];
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
  
  UINib *nib = [UINib nibWithNibName:@"TCTwitterCell" bundle:nil];
  [CETableViewBindingHelper bindingHelperForTableView:self.tableView
                                          sourceSignal:[RACObserve(_viewModel, twitts) deliverOnMainThread]
                                      selectionCommand:nil
                                          templateCell:nib];
  
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.tintColor = [UIColor grayColor];
  refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
  self.refreshControl = refreshControl;
  __weak __typeof(self) weakSelf = self;
  
  self.refreshControl.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    return [weakSelf.viewModel signalPullToRefresh];
  }];
  
  [self.refreshControl.rac_command.errors subscribeNext:^(NSError *error) {
    [weakSelf showError:error];
  }];

//  [[self.refreshControl.rac_command.executionSignals concat] subscribeNext:^(NSArray *x) {
//    [weakSelf displaySelectionOfAccounts:x];
//  }];
  
  
  [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kReachabilityChangedNotification object:nil]
    takeUntil:[self rac_willDeallocSignal]]
   subscribeNext:^(id x) {
     [[weakSelf.viewModel signalPullToRefresh] subscribeNext:nil];
   }];
  
  self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    return [self signalComposeNewTwitt];
  }];
  
  self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    return [self.viewModel signalExtractAccounts];
  }];
  
  [[self.navigationItem.leftBarButtonItem.rac_command.executionSignals concat] subscribeNext:^(NSArray *x) {
    [weakSelf displaySelectionOfAccounts:x];
  }];
}

- (UIAlertAction *)actionWithTitle:(NSString *)title
                           handler:(void (^ __nullable)(void)) block {
  
  return [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      block();
  }];
}

- (void)displaySelectionOfAccounts:(NSArray *)accounts {
  if ([accounts count] == 0 || accounts == nil) return;
  
  UIAlertController *accountSelection = [[UIAlertController alloc] init];

  __weak __typeof (self) weakSelf = self;
  for (ACAccountViewModel *viewModel in accounts) {
    [accountSelection addAction:[self actionWithTitle:viewModel.userName handler:^{
      [weakSelf.viewModel setAccountViewModel:viewModel];
      [weakSelf.viewModel signalPullToRefresh];
    }]];
  }
  [self presentViewController:accountSelection animated:YES completion:nil];
}

- (RACSignal *)signalComposeNewTwitt {
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
      SLComposeViewController *composerViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
      [self presentViewController:composerViewController animated:YES completion:nil];
      
      __weak __typeof (self) weakSelf = self;
      
      composerViewController.completionHandler = ^(SLComposeViewControllerResult result) {
        
        if (result == SLComposeViewControllerResultDone) {
          //[[weakSelf.viewModel signalPullToRefresh] subscribeNext:];
          //[[weakSelf.viewModel pullToRefreshSignal] ];
         
        }
         [subscriber sendCompleted];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self dismissViewControllerAnimated:NO completion:nil];
        });
        
      };
      
    }
    return nil;
  }];
}

- (void)showError:(NSError *)error {
  
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
  
  __weak __typeof (self) weakSelf = self;
  [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
    [weakSelf dismissViewControllerAnimated:YES completion:nil];
  }]];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}

@end
