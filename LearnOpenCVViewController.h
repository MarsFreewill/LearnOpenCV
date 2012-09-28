//
//  LearnOpenCVViewController.h
//  LearnOpenCV
//
//  Created by Lj Tao on 12-7-14.
//  Copyright (c) 2012年 xmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cv.h"

@interface LearnOpenCVViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIImageView *imageView;
    
}

- (IplImage *)iplImageFromUIImage:(UIImage *)image;
- (UIImage *)uiImageFromIplImage:(IplImage *)image;

- (IBAction)detectFaces;
- (void)imagePickerController;
- (void)drawOnFaceAt;

@end
