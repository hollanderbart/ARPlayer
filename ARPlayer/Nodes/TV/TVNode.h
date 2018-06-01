//
//  TVNode.h
//  ARPlayer
//
//  Created by Maxim Makhun on 10/1/17.
//  Copyright © 2017 Maxim Makhun. All rights reserved.
//

@import SceneKit;
@import AVFoundation;

//#import "CurrentTimeNode.h"

@interface TVNode : SCNNode

@property(nonatomic, strong, readonly) AVPlayer *player;

//@property(nonatomic, strong, readonly) CurrentTimeNode *currentTimeNode;

- (void)updateVideoNodeWithPlayer:(AVPlayer *)player;

@end
