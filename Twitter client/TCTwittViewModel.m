//
//  TCTwittViewModel.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCTwittViewModel.h"
#import "Twitt+CoreDataClass.h"
#import "AppDelegate.h"
#import "User+CoreDataClass.h"
#import "Account+CoreDataClass.h"
#import "AppDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TCTwittViewModel ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *cashedImage;
@property (nonatomic, strong) Twitt *twitt;
@property (nonatomic, strong) ACAccount *account;
@end

@implementation TCTwittViewModel

- (id)initWithJson:(NSDictionary *)json account:(ACAccount *)account
managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  
  if (self = [super init]) {
    _twitt = [[Twitt alloc] initWithEntity:[Twitt entity] insertIntoManagedObjectContext:managedObjectContext];
    _twitt.text = json[@"text"];
    _twitt.user = [self authorWithJson:json[@"user"] managedObjectContext:managedObjectContext];
    _twitt.id_ = [json[@"id"] integerValue];
    _text = _twitt.text;
    _username = _twitt.user.screen_name;
    _account = account;
  }
  return self;
}

- (id)initWithTwitt:(Twitt *)twitt {
  
  if (self = [super init]) {
    _twitt = twitt;
    _text = _twitt.text;
    _username = _twitt.user.screen_name;
  }
  
  return self;
}

- (Twitt *)twitt {
  return _twitt;
}

- (User *)authorWithJson:(NSDictionary *)json managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  User *user = [[User alloc] initWithEntity:[User entity] insertIntoManagedObjectContext:managedObjectContext];
  user.profile_image_url = json[@"profile_image_url"];
  user.screen_name = json[@"screen_name"];
  user.profile_image_url_https = json[@"profile_image_url_https"];
  return user;
}

- (void)markAsDeleteTwitt {
  [[self managedObjectContext] deleteObject:self.twitt];
}

- (NSManagedObjectContext *)managedObjectContext {
  return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

- (RACSignal *)signalUserImage {
  
  RACScheduler *scheduler = [RACScheduler
                             schedulerWithPriority:RACSchedulerPriorityBackground];
  
  __weak __typeof(self) weakSelf = self;
  return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    
    SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[weakSelf imagePath]] parameters:nil];
    
    feedRequest.account = weakSelf.account;
    
    [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
      
      [subscriber sendNext:responseData];
      [subscriber sendCompleted];
      
    }];
    
    
    return nil;
  }] subscribeOn:scheduler];
  
}


- (NSString *)imagePath {
  return [self.twitt.user profile_image_url_https];
}

- (UIColor *)backgroundColor {
  return [UIColor whiteColor];
}

- (UIColor *)userNameColor {
  return [UIColor blackColor];
}

@end
