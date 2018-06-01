//
//  Utils.m
//  ARPlayer
//
//  Created by Maxim Makhun on 9/24/17.
//  Copyright © 2017 Maxim Makhun. All rights reserved.
//

@import SceneKit;
@import AudioToolbox;

// Utils
#import "Utils.h"
#import "SettingsManager.h"

NSString * const kMediaPlayerNode = @"media_player_node";
NSString * const kTVNode = @"tv_node";
NSString * const kVideoRendererNode = @"video_renderer_node";
NSString * const kPlayNode = @"play_node";
NSString * const kStopNode = @"stop_node";
NSString * const kNextTrackNode = @"next_track_node";
NSString * const kPreviousTrackNode = @"previous_track_node";

@implementation Utils

+ (void)handleTouch:(SCNNode *)node {
    if ([SettingsManager instance].vibrateOnTouch) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if ([SettingsManager instance].animateOnTouch) {
        SCNAction *moveDown = [SCNAction moveBy:SCNVector3Make(0.0f,
                                                               -0.03f,
                                                               0.0f)
                                       duration:0.2f];
        moveDown.timingMode = SCNActionTimingModeEaseInEaseOut;
        SCNAction *moveUp = [SCNAction moveBy:SCNVector3Make(0.0f,
                                                             0.03f,
                                                             0.0f)
                                     duration:0.2f];
        moveUp.timingMode = SCNActionTimingModeEaseInEaseOut;
        SCNAction *moveAction = [SCNAction repeatAction:[SCNAction sequence:@[moveDown, moveUp]]
                                                  count:1];
        [node runAction:moveAction];
    }
}

+ (SCNVector3)getBoundingBox:(SCNNode *)node {
    SCNVector3 min = SCNVector3Zero;
    SCNVector3 max = SCNVector3Zero;
    [node getBoundingBoxMin:&min max:&max];
    
    CGFloat width = max.x - min.x;
    CGFloat height = max.y - min.y;
    CGFloat length = max.z - min.z;
    
    return SCNVector3Make(width, height, length);
}

+ (NSArray<NSURL *> *)playlist {
    return [NSArray arrayWithObjects:
            [NSURL URLWithString:@"http://devstreaming.apple.com/videos/wwdc/2014/609xxkxq1v95fju/609/609_sd_whats_new_in_scenekit.mov"],
            [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample_video_iTunes" ofType:@"mov"]], nil];
}

+ (void)getAllStreams:(void (^)(NSArray<NSURL*>* allStreamUrls))finishBlock {
    NSDictionary *dict = @{ @"NPO1" : @"LI_NL1_4188102",
                            @"NPO2" : @"LI_NL2_4188105",
                            @"NPO3" : @"LI_NL3_4188107",
                            @"NPONieuws": @"LI_NEDERLAND1_221673",
                            @"NPOPolitiek": @"LI_NEDERLAND1_221675",
                            @"NPO101": @"LI_NEDERLAND3_221683",
                            @"NPOCultura": @"LI_NEDERLAND2_221679",
                            @"NPOZappXtra": @"LI_NEDERLAND3_221687",
                            @"NPORadio1": @"LI_RADIO1_300877",
                            @"NPORadio2": @"LI_RADIO2_300879",
                            @"NPO3FM": @"LI_3FM_300881",
                            @"NPORadio4": @"LI_RA4_698901",
                            @"NPOFunX": @"LI_3FM_603983"
                            };
    NSMutableArray<NSURL*>* streams = [[NSMutableArray alloc] init];

    for(id key in dict) {
        NSString *value = [dict objectForKey:key];
        [self getStream:value :^(NSURL *streamUrl) {
            [streams addObject:streamUrl];
            if ([streams count] == [dict count]) {
                finishBlock(streams);
            }
        }];
    }
}

+ (void)getStream:(NSString *)channel :(void (^)(NSURL* streamUrl))finishBlock {
    NSString *api_url = @"http://ida.omroep.nl/app.php/";
    NSString *token_url = @"http://ida.omroep.nl/app.php/auth";
    NSString *url_suffix = @"?adaptive=yes&token=";

    NSURL *apiUrl = [NSURL URLWithString:api_url];
    NSURL *tokenUrl = [NSURL URLWithString:token_url];

    dispatch_async(dispatch_get_main_queue(), ^{

        NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                              dataTaskWithURL:tokenUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                  NSString *token = json[@"token"];

                                                  NSString *secondString = [NSString stringWithFormat:@"%@%@%@%@",
                                                                            apiUrl.absoluteString,
                                                                            channel,
                                                                            url_suffix,
                                                                            token];
                                                  NSURL *secondUrl = [NSURL URLWithString: secondString];

                                                  NSURLSessionDataTask *secondDownloadTask = [[NSURLSession sharedSession]
                                                                                              dataTaskWithURL:secondUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                                                  NSString *thirdDataObjectString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                                                                  NSRange range = [thirdDataObjectString rangeOfString:@"http"];
                                                                                                  NSRange word = [[thirdDataObjectString substringFromIndex:range.location] rangeOfString:@"\","];
                                                                                                  NSString *urlString = [[thirdDataObjectString substringWithRange:NSMakeRange(range.location, word.location)] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                                                                                                  NSURL *finalUrl = [NSURL URLWithString:urlString];
                                                                                                  NSURLSessionDataTask *thirdDownloadTask = [[NSURLSession sharedSession] dataTaskWithURL:finalUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                                                                                                 NSString *finalUrlResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                                                                      NSRange range = [finalUrlResponse rangeOfString:@"http"];
                                                                                                      NSRange word = [[finalUrlResponse substringFromIndex:range.location] rangeOfString:@"\""];
                                                                                                      NSString *urlString = [[finalUrlResponse substringWithRange:NSMakeRange(range.location, word.location)] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                                                                                                      NSURL *finalUrl = [NSURL URLWithString:urlString];
                                                                                                      finishBlock(finalUrl);
                                                                                                                                             }];
                                                                                                  [thirdDownloadTask resume];
                                                                                              }];
                                                  [secondDownloadTask resume];
                                              }];
        [downloadTask resume];
    });
}

@end
