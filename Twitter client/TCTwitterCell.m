//
//  QuoteTableViewCell.m
//  QuotesListExample
//
//  Created by Colin Eberhardt on 30/10/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import "TCTwitterCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TCTwittViewModel.h"

@interface TCTwitterCell()

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end

@implementation TCTwitterCell

- (void)configureWithViewModel:(id <InterfaceCastomisation> )viewModel {
  
  TCTwittViewModel *twitterViewModel = (TCTwittViewModel *)viewModel;
  
  self.username.text = twitterViewModel.username;
  self.text.text = twitterViewModel.text;
  
  [self setBackgroundColor:[viewModel backgroundColor]];
  [self.username setTextColor:[viewModel userNameColor]];
 
  __weak __typeof (self) weakSelf = self;
  [[[[twitterViewModel signalUserImage]
    deliverOn:[RACScheduler mainThreadScheduler]] map:^id(NSData *value) {
    if (![value isKindOfClass:[NSData class]]) return nil;
    return [UIImage imageWithData:value];
  }] subscribeNext:^(UIImage *x) {
    if ([x isKindOfClass:[UIImage class]]) {
      weakSelf.userImageView.image = x;
    }
  }];
  
}

@end
