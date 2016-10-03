//
//  TCTwittViewModelTests.m
//  Twitter client
//
//  Created by Alexander on 10/2/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "Kiwi.h"
#import "TCTwittViewModel.h"
#import <Accounts/Accounts.h>
#import "AppDelegate.h"


@interface  TCTwittViewModel ()
- (Twitt *)twittFromJSON:(NSDictionary *)json;
- (NSString *)imagePath;
@property (nonatomic, strong) ACAccount *account;
@end

SPEC_BEGIN(TCTwittViewModelTests)

describe(@"TCTwittViewModel", ^{
  context(@"creating from JSON data", ^{
    
    NSDictionary *twittJSON = @{@"contributors":[NSNull null],
    @"coordinates": [NSNull null],
    @"created_at": @"Wed Sep 28 04:12:28 +0000 2016",
    @"entities": @{
      @"hashtags": @[],
      @"symbols": @[],
      @"urls": @[],
      @"user_mentions": @[]
    },
    @"favorite_count": @0,
    @"favorited": @0,
    @"geo": [NSNull null],
    @"id": @780983489038544896,
    @"id_str": @780983489038544896,
    @"in_reply_to_screen_name":[NSNull null],
    @"in_reply_to_status_id":[NSNull null],
    @"in_reply_to_status_id_str":[NSNull null],
    @"in_reply_to_user_id":[NSNull null],
    @"in_reply_to_user_id_str":[NSNull null],
    @"is_quote_status": @0,
    @"lang": @"und",
    @"place": [NSNull null],
    @"retweet_count": @0,
    @"retweeted": @0,
    @"source": @"<a href:\"http://www.apple.com\" rel:\"nofollow\">iOS</a>",
    @"text": @"777777",
    @"truncated" : @0,
    @"user" :     @{
      @"contributors_enabled" : @0,
      @"created_at" : @"Fri Sep 16 03:28:27 +0000 2016",
      @"default_profile" : @1,
      @"default_profile_image" : @1,
      @"description" : @"",
      @"entities" :         @{
        @"description" :             @{
          @"urls" :                 @[],
        },
      },
      @"favourites_count" : @0,
      @"follow_request_sent" : @0,
      @"followers_count" : @0,
      @"following" : @0,
      @"friends_count" : @2,
      @"geo_enabled" : @1,
      @"has_extended_profile" : @0,
      @"id" : @776623754210320385,
      @"id_str" : @776623754210320385,
      @"is_translation_enabled" : @0,
      @"is_translator" : @0,
      @"lang" : @"en",
      @"listed_count" : @0,
      @"location" : @"",
      @"name" : @"usename1",
      @"notifications" : @0,
      @"profile_background_color" : @"F5F8FA",
      @"profile_background_image_url" : [NSNull null],
      @"profile_background_image_url_https" : [NSNull null],
      @"profile_background_tile" : @0,
      @"profile_image_url" : @"http://abs.twimg.com/sticky/default_profile_images/default_profile_5_normal.png",
      @"profile_image_url_https" : @"https://abs.twimg.com/sticky/default_profile_images/default_profile_5_normal.png",
      @"profile_link_color" : @"2B7BB9",
      @"profile_sidebar_border_color" : @"C0DEED",
      @"profile_sidebar_fill_color" : @"DDEEF6",
      @"profile_text_color" : @333333,
      @"profile_use_background_image" : @1,
      @"protected" : @0,
      @"screen_name" : @"myscreen_username",
      @"statuses_count" : @12,
      @"time_zone" : [NSNull null],
      @"url" : [NSNull null],
      @"utc_offset" : [NSNull null],
      @"verified" : @0,
    },
  };
    
    ACAccount *account = [ACAccount mock];
    [account stubMessagePattern:[[KWMessagePattern alloc] initWithSelector:@selector(identifier)] withBlock:^id(NSArray *params) {
      return @"useridentifier";
    }];
    
    [account stubMessagePattern:[[KWMessagePattern alloc] initWithSelector:@selector(username)] withBlock:^id(NSArray *params) {
      return [NSString stringWithFormat:@"myscreen_username"];
    }];
   
    TCTwittViewModel *twitteViewModel = [[TCTwittViewModel alloc] initWithJson:twittJSON account:account];
    it(@"should mutch screen_name with json", ^{
      [[twitteViewModel.username should] equal:[twittJSON valueForKeyPath:@"user.screen_name"]];
    });
    it(@"should mutch text content", ^{
      [[twitteViewModel.text should] equal:twittJSON[@"text"]];
    });
    it(@"should mutch user profile url for https with JSON", ^{
      [[[twitteViewModel imagePath] should] equal:[twittJSON valueForKeyPath:@"user.profile_image_url_https"]];
    });
    it(@"should ACAccount mutch with twitterViewModel account", ^{
      [[[twitteViewModel account] should] equal:account];
    });
    
    
 });
});

SPEC_END
