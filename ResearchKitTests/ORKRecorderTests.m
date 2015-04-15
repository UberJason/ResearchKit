/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <XCTest/XCTest.h>
#import <ResearchKit/ResearchKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ORKLocationRecorder.h"
#import "ORKAccelerometerRecorder.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKPedometerRecorder.h"
#import "ORKTouchRecorder.h"
#import "ORKAudioRecorder.h"
#import "ORKHealthQuantityTypeRecorder.h"
#import <CoreMotion/CoreMotion.h>
#import "ORKHelpers.h"
#import "ORKRecorder_Internal.h"
#import "ORKRecorder_Private.h"

@interface ORKMockLocationManager : CLLocationManager

@end

@implementation ORKMockLocationManager

- (void)setPausesLocationUpdatesAutomatically:(BOOL)pausesLocationUpdatesAutomatically {
    
}

@end

@interface ORKMockLocationRecorder : ORKLocationRecorder


@end

@implementation ORKMockLocationRecorder

- (CLLocationManager *)createLocationManager {
    return [[ORKMockLocationManager alloc] init];
}

@end

@interface ORKMockTouch : UITouch

@end

@implementation ORKMockTouch

- (CGPoint)locationInView:(UIView *)view {
    return CGPointMake(11.0, 12.0);
}

- (NSTimeInterval)timestamp {
    return 3000.0;
}

- (UITouchPhase)phase {
    return UITouchPhaseMoved;
}

@end

@interface ORKMockMotionManager : CMMotionManager

- (void)injectMotion:(CMDeviceMotion *)motion;

- (void)injectAccelerometerData:(CMAccelerometerData *)accelerometerData;

@end

@implementation ORKMockMotionManager {
    CMDeviceMotionHandler _motionHandler;
    CMAccelerometerHandler _accelerometerHandler;
}

- (void)injectMotion:(CMDeviceMotion *)motion {
    _motionHandler(motion, nil);
}

- (void)injectAccelerometerData:(CMAccelerometerData *)accelerometerData {
    _accelerometerHandler(accelerometerData, nil);
}

- (void)startDeviceMotionUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMDeviceMotionHandler)handler {
    _motionHandler = handler;
    [super startDeviceMotionUpdatesToQueue:queue withHandler:handler];
}

- (void)startAccelerometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMAccelerometerHandler)handler {
    _accelerometerHandler = handler;
    [super startAccelerometerUpdatesToQueue:queue withHandler:handler];
}

- (BOOL)isAccelerometerAvailable {
    return YES;
}

- (BOOL)isDeviceMotionAvailable {
    return YES;
}

@end

@interface ORKMockPedometer : CMPedometer

- (void)injectData:(CMPedometerData *)data;

@end

@implementation ORKMockPedometer {
    CMPedometerHandler _handler;
}

- (void)injectData:(CMPedometerData *)data {
    _handler(data, nil);
}

- (void)startPedometerUpdatesFromDate:(NSDate *)start withHandler:(CMPedometerHandler)handler {
     _handler = handler;
}

+ (BOOL)isStepCountingAvailable {
    return YES;
}

@end

@interface ORKMockAccelerometerRecorder : ORKAccelerometerRecorder

@property (nonatomic ,strong) ORKMockMotionManager* mockManager;

@end

@implementation ORKMockAccelerometerRecorder

- (CMMotionManager *)createMotionManager {
    return _mockManager;
}

@end

@interface ORKMockAccelerometerData : CMAccelerometerData

@end

@implementation ORKMockAccelerometerData

- (CMAcceleration)acceleration {
    return (CMAcceleration){.x=0.1, .y=0.12, .z=0.123};
}

- (NSTimeInterval)timestamp {
    return 1000.0;
}

@end

@interface ORKMockPedometerRecorder : ORKPedometerRecorder

@property (nonatomic ,strong) ORKMockPedometer* mockPedometer;

@end

@implementation ORKMockPedometerRecorder

- (CMPedometer *)createPedometer {
    return _mockPedometer;
}

@end

@interface ORKMockPedometerData : CMPedometerData
@end

@implementation ORKMockPedometerData

- (NSDate *)startDate {
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:1000.0];
}

- (NSDate *)endDate {
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:1001.0];
}

- (NSNumber *)numberOfSteps {
    return @(2);
}

- (NSNumber *)distance {
    return @(1.2);
}

- (NSNumber *)floorsAscended {
    return @(0.1);
}

- (NSNumber *)floorsDescended {
    return @(0);
}

@end

@interface ORKMockDeviceMotionRecorder : ORKDeviceMotionRecorder

@property (nonatomic ,strong) ORKMockMotionManager* mockManager;

@end

@implementation ORKMockDeviceMotionRecorder

- (CMMotionManager *)createMotionManager {
    return _mockManager;
}

@end

@interface ORKMockAttitude : CMAttitude

@end

@implementation ORKMockAttitude

- (CMQuaternion)quaternion {
    return (CMQuaternion){.x=0.1, .y=0.12, .z=0.123, .w=0.1234};
}

@end

@interface ORKMockDeviceMotion : CMDeviceMotion

@end

@implementation ORKMockDeviceMotion

- (NSTimeInterval)timestamp {
    return 1000.0;
}

- (CMAttitude *)attitude {
    return [ORKMockAttitude new];
}

- (CMRotationRate)rotationRate {
    return (CMRotationRate){.x=0.1, .y=0.12, .z=0.123};
}

- (CMAcceleration)gravity {
    return (CMAcceleration){.x=0.2, .y=0.23, .z=0.234};
}

- (CMAcceleration)userAcceleration {
    return (CMAcceleration){.x=0.3, .y=0.34, .z=0.345};
}

- (CMCalibratedMagneticField)magneticField {
    return (CMCalibratedMagneticField){.field=(CMMagneticField){.x=0.4, .y=0.45, .z=0.456}, .accuracy=CMMagneticFieldCalibrationAccuracyHigh};
}

@end

static BOOL ork_doubleEqual(double x, double y) {
    static double K = 1;
    return (fabs(x-y) < K * DBL_EPSILON * fabs(x+y) || fabs(x-y) < DBL_MIN);
}

#pragma mark - ORKRecorderTests
#pragma mark -

@interface ORKRecorderTests : XCTestCase <ORKRecorderDelegate>

@end

@implementation ORKRecorderTests {
    NSString  *_outputPath;
    ORKResult *_result;
    NSArray   *_items;
}

static const NSInteger kNumberOfSamples = 5;

- (void)setUp {
    [super setUp];
    
    if (_outputPath == nil) {
        
        _outputPath = [NSBundle bundleForClass:[self class]].bundlePath;
        _outputPath = [_outputPath stringByAppendingPathExtension:@"testdir"];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:_outputPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Failed to create directory %@", error);
        }
    }
    
    _result = nil;
    _items = nil;
}

- (void)tearDown {
    [super tearDown];
}

- (void)recorder:(ORKRecorder *)recorder didCompleteWithResult:(ORKResult *)result {
     NSLog(@"didCompleteWithResult: %@", result);
    _result = result;
}

- (void)recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    _result = nil;
}

- (ORKRecorder *)createRecorder:(ORKRecorderConfiguration *)conf {
    ORKRecorder *recorder = [conf recorderForStep:[[ORKStep alloc] initWithIdentifier:@"step"]
                                                                    outputDirectory:[NSURL fileURLWithPath:_outputPath]];
    recorder.delegate = self;
    return recorder;
}

- (void)checkResult {
    
    XCTAssertNotNil(_result, @"");
    XCTAssert([_result isKindOfClass:[ORKFileResult class]], @"");
    
    ORKFileResult *fileResult = (ORKFileResult *)_result;
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileResult.fileURL ] options:(NSJSONReadingOptions)0 error:&error];
    XCTAssertNil(error, @"");
    XCTAssertNotNil(dict, @"");
    
    NSArray* items = dict[@"items"];
    XCTAssertEqual(items.count, kNumberOfSamples, @"");
    
    _items = items;
}

- (void)testLocationRecorder {
    
    ORKLocationRecorder *recorder = (ORKLocationRecorder *)[self createRecorder:[ORKLocationRecorderConfiguration new]];
    XCTAssertTrue([recorder isKindOfClass:[ORKLocationRecorder class]], @"");
    
    recorder = [[ORKMockLocationRecorder alloc] initWithStep:recorder.step outputDirectory:recorder.outputDirectory];
    recorder.delegate = self;
    [recorder start];
    
    id<CLLocationManagerDelegate> clDelegate = (id<CLLocationManagerDelegate>)recorder;
    
    double latitude = 37.31317;
    double longitude = -122.07238159997;
    double altitude = 11.0;
    double horizontalAccuracy = 12.0;
    double verticalAccuracy = 13.0;
    double course = 14.0;
    double speed = 15.0;
    NSDate *timestamp = [NSDate date];
    
    for (NSInteger i = 0; i < kNumberOfSamples; i++) {
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                                             altitude:altitude
                                                   horizontalAccuracy:horizontalAccuracy
                                                     verticalAccuracy:verticalAccuracy
                                                               course:course
                                                                speed:speed
                                                            timestamp:timestamp];
        
        [clDelegate locationManager:nil didUpdateLocations:@[location]];
    }
    
    [recorder stop];
    [self checkResult];

    for (NSDictionary *sample in _items) {
        
        XCTAssertTrue(ork_doubleEqual(altitude, [sample[@"altitude"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(horizontalAccuracy, [sample[@"horizontalAccuracy"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(verticalAccuracy, [sample[@"verticalAccuracy"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(course, [sample[@"course"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(speed, [sample[@"speed"] doubleValue]), @"");
        XCTAssertEqualObjects(ORKStringFromDateISO8601(timestamp), sample[@"timestamp"], @"");
        XCTAssertTrue(ork_doubleEqual(latitude, [sample[@"coordinate"][@"latitude"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(longitude, [sample[@"coordinate"][@"longitude"] doubleValue]), @"");
    }
}

- (void)testAccelerometerRecorder {
    
    ORKAccelerometerRecorderConfiguration *conf = [[ORKAccelerometerRecorderConfiguration alloc] initWithFrequency:60.0];
    Class recorderClass = [ORKAccelerometerRecorder class];
    ORKAccelerometerRecorder *recorder = (ORKAccelerometerRecorder *)[self createRecorder:conf];
    
    XCTAssertTrue([recorder isKindOfClass:recorderClass], @"");
    
    recorder = [[ORKMockAccelerometerRecorder alloc] initWithFrequency:recorder.frequency step:recorder.step outputDirectory:recorder.outputDirectory];
    recorder.delegate = self;
    ORKMockMotionManager *manager = [ORKMockMotionManager new];
    [(ORKMockAccelerometerRecorder*)recorder setMockManager:manager];
    
    [recorder start];
    
    ORKMockAccelerometerData *data = [ORKMockAccelerometerData new];
    for (NSInteger i = 0; i < kNumberOfSamples; i++) {
        [manager injectAccelerometerData:data];
    }
    
    [recorder stop];
    [self checkResult];
    
    for (NSDictionary *sample in _items) {
        XCTAssertTrue(ork_doubleEqual(data.timestamp, [sample[@"timestamp"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(data.acceleration.x, [sample[@"x"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(data.acceleration.y, [sample[@"y"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(data.acceleration.z, [sample[@"z"] doubleValue]), @"");
    }
}

- (void)testDeviceMotionRecorder {
    
    ORKDeviceMotionRecorderConfiguration *conf = [[ORKDeviceMotionRecorderConfiguration alloc] initWithFrequency:60.0];
    Class recorderClass = [ORKDeviceMotionRecorder class];
    ORKDeviceMotionRecorder *recorder = (ORKDeviceMotionRecorder *)[self createRecorder:conf];
    
    XCTAssertTrue([recorder isKindOfClass:recorderClass], @"");
    
    recorder = [[ORKMockDeviceMotionRecorder alloc] initWithFrequency:recorder.frequency step:recorder.step outputDirectory:recorder.outputDirectory];
    recorder.delegate = self;
    ORKMockMotionManager *manager = [ORKMockMotionManager new];
    [(ORKMockAccelerometerRecorder*)recorder setMockManager:manager];
    
    [recorder start];
    
    ORKMockDeviceMotion *motion = [ORKMockDeviceMotion new];
    for (NSInteger i = 0; i < kNumberOfSamples; i++) {
        [manager injectMotion:motion];
    }
    
    [recorder stop];
    [self checkResult];
    
    for (NSDictionary *sample in _items) {
        XCTAssertTrue(ork_doubleEqual(motion.timestamp, [sample[@"timestamp"] doubleValue]), @"");
        
        XCTAssertTrue(ork_doubleEqual(motion.attitude.quaternion.x, [sample[@"attitude"][@"x"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.attitude.quaternion.y, [sample[@"attitude"][@"y"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.attitude.quaternion.z, [sample[@"attitude"][@"z"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.attitude.quaternion.w, [sample[@"attitude"][@"w"] doubleValue]), @"");
        
        XCTAssertTrue(ork_doubleEqual(motion.gravity.x, [sample[@"gravity"][@"x"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.gravity.y , [sample[@"gravity"][@"y"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.gravity.z , [sample[@"gravity"][@"z"] doubleValue]), @"");
        
        XCTAssertTrue(ork_doubleEqual(motion.magneticField.accuracy, [sample[@"magneticField"][@"accuracy"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.magneticField.field.x, [sample[@"magneticField"][@"x"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.magneticField.field.y, [sample[@"magneticField"][@"y"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.magneticField.field.z , [sample[@"magneticField"][@"z"] doubleValue]), @"");
        
        XCTAssertTrue(ork_doubleEqual(motion.rotationRate.x, [sample[@"rotationRate"][@"x"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.rotationRate.y, [sample[@"rotationRate"][@"y"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.rotationRate.z, [sample[@"rotationRate"][@"z"] doubleValue]), @"");
        
        XCTAssertTrue(ork_doubleEqual(motion.userAcceleration.x, [sample[@"userAcceleration"][@"x"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.userAcceleration.y, [sample[@"userAcceleration"][@"y"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(motion.userAcceleration.z, [sample[@"userAcceleration"][@"z"] doubleValue]), @"");
    }
}

- (void)testPedometerRecorder {
    
    Class recorderClass = [ORKPedometerRecorder class];
    ORKPedometerRecorder *recorder = (ORKPedometerRecorder *)[self createRecorder:[ORKPedometerRecorderConfiguration new]];
    
    XCTAssertTrue([recorder isKindOfClass:recorderClass], @"");
    
    recorder = [[ORKMockPedometerRecorder alloc] initWithStep:recorder.step outputDirectory:recorder.outputDirectory];
    recorder.delegate = self;
    ORKMockPedometer *pedometer = [ORKMockPedometer new];
    [(ORKMockPedometerRecorder*)recorder setMockPedometer:pedometer];
    
    [recorder start];
    
    ORKMockPedometerData *data = [ORKMockPedometerData new];
    for (NSInteger i = 0; i < kNumberOfSamples; i++) {
        [pedometer injectData:data];
    }
    
    [recorder stop];
    [self checkResult];
    
    for (NSDictionary *sample in _items) {
        
        XCTAssertEqualObjects(ORKStringFromDateISO8601(data.startDate), sample[@"startDate"], @"");
        XCTAssertEqualObjects(ORKStringFromDateISO8601(data.endDate), sample[@"endDate"], @"");
        
        XCTAssertTrue(ork_doubleEqual(data.distance.doubleValue, [sample[@"distance"] doubleValue]), @"");
        XCTAssertEqual(data.numberOfSteps.integerValue, [sample[@"numberOfSteps"] integerValue], @"");
        XCTAssertTrue(ork_doubleEqual(data.floorsAscended.doubleValue, [sample[@"floorsAscended"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual(data.floorsDescended.doubleValue, [sample[@"floorsDescended"] doubleValue]), @"");
    }
}

- (void)testTouchRecorder {
    
    Class recorderClass = [ORKTouchRecorder class];
    ORKTouchRecorder *recorder = (ORKTouchRecorder *)[self createRecorder:[ORKTouchRecorderConfiguration new]];
    
    XCTAssertTrue([recorder isKindOfClass:recorderClass], @"");
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    [recorder viewController:[UIViewController new] willStartStepWithView:view];
    [recorder start];
    
    ORKMockTouch *touch = [ORKMockTouch new];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    for (NSInteger i = 0; i < kNumberOfSamples; i++) {
        [recorder performSelector:@selector(view:didDetectTouch:) withObject:view withObject:touch];
    }
    
#pragma clang diagnostic pop
    
    [recorder stop];
    [self checkResult];
    
    for (NSDictionary *sample in _items) {
        
        XCTAssertTrue(ork_doubleEqual([touch locationInView:nil].x, [sample[@"x"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual([touch locationInView:nil].y, [sample[@"y"] doubleValue]), @"");
        XCTAssertTrue(ork_doubleEqual([touch timestamp], [sample[@"timestamp"] doubleValue]), @"");
        XCTAssertEqual([view bounds].size.width, [sample[@"width"] floatValue], @"");
        XCTAssertEqual([view bounds].size.height, [sample[@"height"] floatValue], @"");
        XCTAssertEqual(0, [sample[@"index"] integerValue], @"");
        XCTAssertEqual([touch phase], [sample[@"phase"] integerValue], @"");
    }
}

- (void)testAudioRecorder {
    
    ORKAudioRecorderConfiguration *conf = [[ORKAudioRecorderConfiguration alloc] initWithRecorderSettings:@{}];
    Class recorderClass = [ORKAudioRecorder class];
    ORKAudioRecorder *recorder = (ORKAudioRecorder *)[self createRecorder:conf];
    
    XCTAssertTrue([recorder isKindOfClass:recorderClass], @"");
}

- (void)testHealthQuantityTypeRecorder {
    
    HKUnit *bpmUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
    HKQuantityType *hbQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    ORKHealthQuantityTypeRecorderConfiguration *conf = [[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithHealthQuantityType:hbQuantityType unit:bpmUnit];
    Class recorderClass = [ORKHealthQuantityTypeRecorder class];
    ORKHealthQuantityTypeRecorder *recorder = (ORKHealthQuantityTypeRecorder *)[self createRecorder:conf];
    
    XCTAssertTrue([recorder isKindOfClass:recorderClass], @"");
}

@end
