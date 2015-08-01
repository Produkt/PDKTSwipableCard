//
//  CardBehaviour-BridgingHeader.h
//  Interactive Animations
//
//  Created by Victor Baro on 23/06/2015.
//  Copyright © 2015 Produkt. All rights reserved.
//


@import UIKit;

#if DEBUG

@interface UIDynamicAnimator (AAPLDebugInterfaceOnly)

/// Use this property for debug purposes when testing.
@property (nonatomic, getter=isDebugEnabled) BOOL debugEnabled;

@end

#endif
