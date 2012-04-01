//
//  DetailViewController.m
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/31/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "DetailViewController.h"
#import "PSPicture.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize iPicture;

- (id)initWithFileAtPath:(NSURL *)path
{
    self = [super init];
    if (self) {
        // Custom initialization
        iPicture = [[PSPicture alloc] initWithFileURL:path];
        [iPicture openWithCompletionHandler:^(BOOL succes){
            if (succes) {
//                NSLog(@"Opened Succesfully");
                [myImageView setImage:iPicture.iPhoto];
            } else {
                NSLog(@"Could not open");
            }
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [myImageView release];
    myImageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (YES);
}

- (void)dealloc {
    [iPicture closeWithCompletionHandler:^(BOOL succes){

    }];
    
    self.iPicture = nil;
    [myImageView release];
    [super dealloc];

}
- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
