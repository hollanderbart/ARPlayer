//
//  Utils.h
//  ARPlayer
//
//  Created by Maxim Makhun on 9/24/17.
//  Copyright © 2017 Maxim Makhun. All rights reserved.
//

@import Foundation;
@import SceneKit;

extern NSString * const kMediaPlayerNode;
extern NSString * const kTVNode;
extern NSString * const kVideoRendererNode;
extern NSString * const kPlayNode;
extern NSString * const kStopNode;
extern NSString * const kNextTrackNode;
extern NSString * const kPreviousTrackNode;

@interface Utils : NSObject

+ (void)handleTouch:(SCNNode *)node;

+ (SCNVector3)getBoundingBox:(SCNNode *)node;

+ (void)getStream:(NSString *)channel :(void (^)(NSURL* streamUrl))finishBlock;

+ (void)getAllStreams:(void (^)(NSArray<NSURL*>* allStreamUrls))finishBlock;

+ (NSArray<NSURL *> *)playlist;

@end
