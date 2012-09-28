//
//  LearnOpenCVViewController.m
//  LearnOpenCV
//
//  Created by Lj Tao on 12-7-14.
//  Copyright (c) 2012年 xmu. All rights reserved.
//

#import "LearnOpenCVViewController.h"

//Filename where the Haar Cascade is stored.
static const char *CASCADE_NAME = "haarcascade_frontalface_alt.xml";

//Temporary storage for the cascade. Due to its size, it is best to make it 
static CvMemStorage *cvStorage = NULL;

//Pointer to the cascade, we also only need one.
static CvHaarClassifierCascade *haarCascade = NULL;

@interface LearnOpenCVViewController ()

@end

@implementation LearnOpenCVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    cvStorage = cvCreateMemStorage(0);
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:CASCADE_NAME]];
    haarCascade = (CvHaarClassifierCascade *)cvLoad([resourcePath UTF8String], 0, 0, 0);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//convert UIImages to IplImages
- (IplImage *)iplImageFromUIImage:(UIImage *)image{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplImage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplImage->imageData, iplImage->width, iplImage->height, iplImage->depth, iplImage->widthStep, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGRect imageRect = CGRectMake(0, 0, iplImage->width, iplImage->height);
    CGContextDrawImage(contextRef, imageRect, imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    return iplImage;    
}

//convert IplImages back to UIImages
- (UIImage *)uiImageFromIplImage:(IplImage *)image{
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge_retained CFDataRef)data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = CGImageCreate(image->width, image->height, image->depth, image->depth * image->nChannels, image->widthStep, colorSpace, kCGImageAlphaLast|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CGImageRelease(imageRef);
    
    return uiImage;
}

- (IBAction)detectFaces{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *) picker
didFinishPickingMediaWithInfo:(NSDictionary *) info {
    // Load up the image selected in the picker.
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    IplImage *iplImage = [self iplImageFromUIImage:originalImage];
    // Do some CV magic here.
    // Clear the memory storage from any previously detected faces.
    cvClearMemStorage(cvStorage);
    
    //Detect the faces and store their rectangles in the sequence.
    CvSeq *faces = cvHaarDetectObjects(iplImage,//Input images
                                       haarCascade,//Cascade to be used
                                       cvStorage,//Temporary storage
                                       1.1,//Size increase for features at each scan
                                       2,//Min number of neighboring rectangle matches
                                       CV_HAAR_DO_CANNY_PRUNING,//Optimization flags
                                       cvSize(30, 30),
                                       cvSize(30, 30));
    //CvSeq is essentiallly a linked list with tree features.
    //faces is bounding rectangles for each face found in iplImage.
    for (int i = 0; i < faces->total; i++) {
        //cvGetSeqElem is used for random access to CvSeqs.
        CvRect *rect = (CvRect *)cvGetSeqElem(faces, i);
        [self drawOnFaceAt:rect inImage:iplImage];
    }
    
    UIImage *newImage = [self uiImageFromIplImage:iplImage];
    // IplImages must be deallocated manually.
    cvReleaseImage(&iplImage);
    [imageView setImage:newImage];
    
    //Optional:save image.
    UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil);
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)drawOnFaceAt:(CvRect *)rect inImage:(IplImage *)image {
    // To draw a rectangle you must input points instead of a rectangle.
    cvRectangle(image, cvPoint(rect->x, rect->y),
                cvPoint(rect->x + rect->width, rect->y + rect->height),
                cvScalar(255, 0, 0, 255) /*RGBA*/,4,8,0);
}

@end
