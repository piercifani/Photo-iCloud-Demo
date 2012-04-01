//
//  ViewController.h
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/16/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSPicture.h"
#import "PSCloudDelegate.h"

@interface ViewController : UIViewController<PSCloudProtocol, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    PSPicture *iDocument;
    PSCloudDelegate *iCloudDelegate;
    NSArray *filenameArray;
  
    IBOutlet UITableView *iTable;
}

- (IBAction)newFile:(id)sender;

@property (nonatomic, retain) PSPicture *iDocument;
@property (nonatomic, assign) PSCloudDelegate *iCloudDelegate;
@property (nonatomic, retain) NSArray *filenameArray;

@end
