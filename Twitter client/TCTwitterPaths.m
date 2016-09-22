//
//  TCTwitterPaths.m
//  Twitter client
//
//  Created by Alexander on 9/22/16.
//  Copyright © 2016 ABV. All rights reserved.
//

#import "TCTwitterPaths.h"

@implementation TCTwitterPaths

+ (NSString *)feedPath {
 return @"https://api.twitter.com/1.1/statuses/user_timeline.json";
}
@end
