//
//  DetailViewController.h
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/31/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSPicture;

@interface DetailViewController : UIViewController
{

    IBOutlet UIImageView *myImageView;
    PSPicture *iPicture;
}

- (id)initWithFileAtPath:(NSURL *)path;
- (IBAction)dismissView:(id)sender;

@property (nonatomic, retain) PSPicture *iPicture;

@end
