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

@end

@implementation TCTwitterCell

- (void)bindViewModel:(id)viewModel {
  
  TCTwittViewModel *twitterViewModel = (TCTwittViewModel *)viewModel;
  
  RAC(self, username.text) = [RACObserve(twitterViewModel, username) deliverOnMainThread];
  RAC(self, text.text) = [RACObserve(twitterViewModel, text) deliverOnMainThread];
}

@end
