//
//  RWView.h
//  RWTwitterSearch
//
//  Created by Colin Eberhardt on 25/04/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol InterfaceCastomisation <NSObject>
- (UIColor *)backgroundColor;
- (UIColor *)userNameColor;
@end


/// A protocol which is adopted by views which are backed by view models.
@protocol CEReactiveView <NSObject>

/// Binds the given view model to the view
- (void)configureWithViewModel:(id <InterfaceCastomisation> )viewModel;

@end
