//
//  BarcodeScanViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "BarcodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MLKit.h>
#import "AlertManager.h"
#import "DealsViewController.h"
#import "APIManager.h"
@interface BarcodeScanViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (strong, nonatomic) NSString *barcode;

@property BOOL alreadyScanned;

@end

NSString *const dealsSegue = @"dealsSegue";

@implementation BarcodeScanViewController

-(void)viewDidLoad{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkPermissions)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [APIManager fetchDealsFromEbayAPI:@"hi"];
//    [APIManager fetchDealsFromUPCDatabase:@"he"];
//    [APIManager fetchDealsFromSearchUPCAPI:@"hi"];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.alreadyScanned = NO;
    
    [self checkPermissions];
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)checkPermissions {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            [self setupCaptureSession];
            break;
            
        case AVAuthorizationStatusRestricted:
            [AlertManager videoPermissionAlert:self];
            break;
            
        case AVAuthorizationStatusDenied:
            [AlertManager videoPermissionAlert:self];
            break;
        
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    [self setupCaptureSession];
                }
                else {
                    [AlertManager videoPermissionAlert:self];
                }
            }];
            break;
    }
}

- (void)setupCaptureSession {
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!backCamera) {
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if (!error) {
        self.videoDataOutput = [AVCaptureVideoDataOutput new];
        NSDictionary *newSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
        self.videoDataOutput.videoSettings = newSettings;
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        if ([self.captureSession canAddInput:input] && [self.captureSession canAddOutput:self.videoDataOutput]) {
            [self.captureSession addInput:input];
            [self.captureSession addOutput:self.videoDataOutput];
            dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
            [self.videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
            [self setupLivePreview];
        }
    }
    else {
        NSLog(@"Error Unable to initialize back camera: %@", error.localizedDescription);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:sampleBuffer];
    image.orientation = [self imageOrientationFromDeviceOrientation:UIDevice.currentDevice.orientation cameraPosition:AVCaptureDevicePositionBack];
    
    MLKBarcodeScanner *barcodeScanner = [MLKBarcodeScanner barcodeScanner];
    [barcodeScanner processImage:image completion:^(NSArray<MLKBarcode *> * _Nullable barcodes, NSError * _Nullable error) {
        if (error) {
            return;
        }
        if (barcodes.count > 0 && !self.alreadyScanned) {
            self.barcode = barcodes.firstObject.rawValue;
            [self performSegueWithIdentifier:dealsSegue sender:nil];
        }
        else {
            return;
        }
    }];
}

-(UIImageOrientation)imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
                         cameraPosition:(AVCaptureDevicePosition)cameraPosition {
  switch (deviceOrientation) {
    case UIDeviceOrientationPortrait:
      return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationLeftMirrored
                                                            : UIImageOrientationRight;

    case UIDeviceOrientationLandscapeLeft:
      return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationDownMirrored
                                                            : UIImageOrientationUp;
    case UIDeviceOrientationPortraitUpsideDown:
      return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationRightMirrored
                                                            : UIImageOrientationLeft;
    case UIDeviceOrientationLandscapeRight:
      return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationUpMirrored
                                                            : UIImageOrientationDown;
    case UIDeviceOrientationUnknown:
    case UIDeviceOrientationFaceUp:
    case UIDeviceOrientationFaceDown:
    return UIImageOrientationUp;
  }
}

-(void)setupLivePreview {
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    if (self.videoPreviewLayer) {
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self.scanView.layer addSublayer:self.videoPreviewLayer];
        [self.view insertSubview:self.scanView atIndex:0];
        self.videoPreviewLayer.frame = self.scanView.bounds;
        if (!self.captureSession.isRunning) {
            [self.captureSession startRunning];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"dealsSegue"]) {
        DealsViewController *dealsController = [segue destinationViewController];
        dealsController.barcode = self.barcode;
        self.alreadyScanned = YES;
    }
}
@end
