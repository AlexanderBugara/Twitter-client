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

@interface TCTwittViewModel ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) UIImage *cashedImage;
@property (nonatomic, strong) Twitt *twitt;
@end

@implementation TCTwittViewModel

- (id)initWithJson:(NSDictionary *)json 
           account:(Account *)account
managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  
  if (self = [super init]) {
    _twitt = [[Twitt alloc] initWithEntity:[Twitt entity] insertIntoManagedObjectContext:managedObjectContext];
    _twitt.text = json[@"text"];
    _twitt.user = [self authorWithJson:json[@"user"] managedObjectContext:managedObjectContext];
    [account addTwittsObject:_twitt];
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
  return user;
}

@end
