//
//  TCTwittViewModel.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCTwittViewModel.h"

@interface TCTwittViewModel ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) UIImage *cashedImage;
@end

@implementation TCTwittViewModel

- (id)initWithTitle:(NSString *)title 
          imagePath:(NSString *)imagePath {
  
  if (self = [super init]) {
    _title = title;
    _imagePath = imagePath;
  }
  return self;
}

@end
