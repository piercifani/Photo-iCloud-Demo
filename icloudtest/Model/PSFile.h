//
//  PSFile.h
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/31/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    EStateDownloading = 0,
    EStateUploading = 1,
    EStateReady = 2,
    EStateUnknown = 3
} iCloudState;

@interface PSFile : NSObject
{
    NSURL *iURL;
    NSString *iFilename;
    NSDate *iDate;
    iCloudState iState;
}

@property (nonatomic,retain) NSURL *iURL;
@property (nonatomic,retain) NSDate *iDate;
@property (nonatomic,retain) NSString *iFilename;
@property (nonatomic) iCloudState iState;

@end
