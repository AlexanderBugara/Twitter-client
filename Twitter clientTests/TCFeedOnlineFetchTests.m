//
//  TCFeedOnlineFetchTests.m
//  Twitter client
//
//  Created by Alexander on 10/2/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "Kiwi.h"
#import "TCFeedOnlineFetch.h"

@interface TCFeedOnlineFetch (TCFeedOnlineFetchTests)
+ (id)jsonFromData:(NSData *)data;
@end


SPEC_BEGIN(TCFeedOnlineFetchTests)

describe(@"testing... TCFeedOnlineFetch", ^{
  context(@"When got twitter feed data and convert it to JSON", ^{
    it(@"it returns nil", ^{
      id result = [TCFeedOnlineFetch jsonFromData:nil];
      [[result should] beNil];
    });
  });
});


SPEC_END
