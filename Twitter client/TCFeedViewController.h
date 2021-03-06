//
//  ViewController.h
//  Twitter client
//
//  Created by Alexander on 9/21/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal, RACCommand, TCAccountViewModel, CEObservableMutableArray;

@interface TCFeedViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logInButton;
@end

@interface TCFeedViewModel : NSObject
@property (nonatomic, strong) NSString *navigationItemTitle;
@property (nonatomic, strong) CEObservableMutableArray *twitts;

- (void)setAccountViewModel:(TCAccountViewModel *)accountViewModel;
- (RACSignal *)signalExtractAccounts;
- (RACSignal *)signalPullToRefresh;
@end

