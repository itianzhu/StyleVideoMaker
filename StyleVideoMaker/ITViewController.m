//
//  ITViewController.m
//  StyleVideoMaker
//
//  Created by TZ on 13-12-19.
//  Copyright (c) 2013年 iTian. All rights reserved.
//

#import "ITViewController.h"
#import "GPUImage.h"

@interface ITViewController ()

@property (nonatomic,retain) UISlider *progress;
@property (nonatomic,retain) UIButton *movieButton;

@property (nonatomic,retain) GPUImageVideoCamera *camera;
@property (nonatomic,retain) GPUImageMovieWriter *writer;
@property (nonatomic,retain) GPUImageOutput<GPUImageInput> *filter;

@end

@implementation ITViewController

- (void)dealloc
{
    self.progress = nil;
    self.movieButton = nil;
    self.camera = nil;
    self.writer = nil;
    self.filter = nil;
    [super dealloc];
}

- (void)loadView
{
    GPUImageView *view = [[[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.view = view;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)movieDeal
{
    BOOL isSelected = self.movieButton.isSelected;
    [self.movieButton setSelected:!isSelected];
    if (isSelected) {
        [self.filter removeTarget:self.writer];
        self.camera.audioEncodingTarget = nil;
        [self.writer finishRecording];
    }else{
        NSString *fileName = [@"Documents/" stringByAppendingFormat:@"Movie%d.m4v",(int)[[NSDate date] timeIntervalSince1970]];
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        self.writer = [[[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)] autorelease];
        [self.filter addTarget:self.writer];
        self.camera.audioEncodingTarget = self.writer;
        [self.writer startRecording];

    }
}

- (void)setSlide
{
    [(GPUImageSepiaFilter *)self.filter setIntensity:[self.progress value]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.movieButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.movieButton setFrame:CGRectMake(50, [UIScreen mainScreen].bounds.size.height - 40, 320 - 100, 30)];
    self.movieButton.layer.borderWidth  = 2;
    self.movieButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.movieButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.movieButton setTitle:@"start" forState:UIControlStateNormal];
    [self.movieButton setTitle:@"stop" forState:UIControlStateSelected];
    [self.movieButton addTarget:self action:@selector(movieDeal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.movieButton];
    
    self.progress = [[[UISlider alloc] initWithFrame:CGRectMake(10, self.movieButton.frame.origin.y - 20, 300, 10)] autorelease];
    [self.progress addTarget:self action:@selector(setSlide) forControlEvents:UIControlEventValueChanged];
    [self.progress setMinimumValue:0];
    [self.progress setMaximumValue:1.0];
    [self.view addSubview:self.progress];
    
	self.camera = [[[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack] autorelease];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    
    self.filter = [[[GPUImageSepiaFilter alloc] init] autorelease];
    [self.camera addTarget:_filter];
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    [_filter addTarget:filterView];
    
    [self.progress setValue:((GPUImageSepiaFilter *)self.filter).intensity];
    
    [self.camera startCameraCapture];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    self.camera.outputImageOrientation = orient;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
