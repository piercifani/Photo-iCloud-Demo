//
//  PSCloudDelegate.h
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/18/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSCloudProtocol <NSObject>

-(void) documentsUpdated;

@end

@interface PSCloudDelegate : NSObject
{
    id<PSCloudProtocol> delegate;
    NSMetadataQuery *query;

    NSMutableDictionary *documents;
}

+ (id)sharedDelegate;
+ (BOOL)checkIfiCloudAvaiable;

- (void)setDelegate:(id<PSCloudProtocol>)aDelegate;

- (void) createNewPictureWithName:(NSString *)aName andImage:(UIImage *)aImage;
- (void) deleteFile:(NSString *)aName;

- (void) eraseCloudDirectory;

@property (nonatomic, retain) NSMetadataQuery *query;

@property (nonatomic, retain) NSMutableDictionary *documents;

@end
