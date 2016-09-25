//
//  TCFeedViewModelSpec.m
//  Twitter client
//
//  Created by Alexander on 9/23/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "Kiwi.h"
#import "TCFeedViewController.h"


@interface TCFeedViewModel(TCFeedViewModelSpec)
- (id)jsonFromData:(NSData *)data;
@end


SPEC_BEGIN(TCFeedViewModelSpec)

describe(@"testing... TCFeedViewModel", ^{
  context(@"When got twitter feed data and convert it to JSON", ^{
    TCFeedViewModel *feedViewModel = [[TCFeedViewModel alloc] init];
    it(@"it returns nil", ^{
      id result = [feedViewModel jsonFromData:nil];
      [[result should] beNil];
    });
  });
});

SPEC_END
