//
//  ViewController.m
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/16/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "DetailViewController.h"
#import "ViewController.h"
#import "PSCloudDelegate.h"
#import "PSFile.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize iDocument, iCloudDelegate, filenameArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    iCloudDelegate = [PSCloudDelegate sharedDelegate];
    [iCloudDelegate setDelegate:self];
}

- (void)viewDidUnload
{
    [iTable release];
    iTable = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }

}

- (void)dealloc {
    self.iDocument = nil;
    self.filenameArray = nil;
    [iTable release];
    [super dealloc];
}

#pragma mark iCloud Delegate

-(void) documentsUpdated;
{
    NSLog(@"documentsUpdated");
    self.filenameArray = [iCloudDelegate.documents allKeys];
    [iTable reloadData];
}

#pragma mark Alert View Stuff

- (IBAction)newFile:(id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Enter Picture URL"
                                                      message:nil
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                            otherButtonTitles:@"Continue", nil];
    
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 1) {

        UITextField *urlField = [alertView textFieldAtIndex:0];
        NSString *urlString = urlField.text;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,  0);

        dispatch_async(queue, ^{
            
            NSURL* url = [NSURL URLWithString:urlString];
            NSData* imageData = [[NSData alloc] initWithContentsOfURL:url];
            
            if (imageData == nil) {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error Downloading from URL"
                                                                  message:nil
                                                                 delegate:nil 
                                                        cancelButtonTitle:@"Dismiss" 
                                                        otherButtonTitles:nil];
                
                [message show];
                
                return;

            }
            
            UIImage* image = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [iCloudDelegate createNewPictureWithName:[url lastPathComponent] andImage:image];
            });
            
            [imageData release];
            
        });

    
    }
}

#pragma mark Table Shit

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

{
    return [filenameArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }

    NSString *fileName = [filenameArray objectAtIndex:indexPath.row];
    PSFile *aFile = [iCloudDelegate.documents objectForKey:fileName];
    
    if (aFile.iState == EStateReady) {
        cell.textLabel.text = aFile.iFilename;
    } else {
        if (aFile.iState == EStateDownloading) {
            cell.textLabel.text = @"Downloading...";
        } else if (aFile.iState == EStateUploading) {
            cell.textLabel.text = @"Uploading...";
        } else {
            cell.textLabel.text = @"Unkown state...";
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSFile *aFile = [iCloudDelegate.documents objectForKey:[filenameArray  objectAtIndex:indexPath.row]];

    NSURL *fileURL = aFile.iURL;
    
    DetailViewController *iDetailViewController = [[[DetailViewController alloc] initWithFileAtPath:fileURL] autorelease];
    [self presentModalViewController:iDetailViewController animated:YES];

}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView 
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSUInteger row = [indexPath row];
    NSUInteger count = [filenameArray count];
	
    if (row < count) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSString *fileName = [filenameArray objectAtIndex:indexPath.row];
        [iCloudDelegate deleteFile:fileName];
        
    }    
}


@end
