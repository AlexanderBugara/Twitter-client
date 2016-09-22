//
//  ViewController.h
//  Twitter client
//
//  Created by Alexander on 9/21/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;

@interface TCFeedViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logInButton;

@end

@interface TCFeedViewModel : NSObject
@property (nonatomic, strong) NSString *userName;
- (RACSignal *)signalGetTwitterAccounts;
@end

