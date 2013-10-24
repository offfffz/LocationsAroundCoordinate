//
//  ViewController.m
//  TestHugeLocations
//
//  Created by off on 10/24/13.
//  Copyright (c) 2013 off. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *latField;
@property (weak, nonatomic) IBOutlet UITextField *lonField;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UITextField *withinField;
@property (strong, nonatomic) NSMutableArray *locations;
@end

@implementation ViewController

- (NSMutableArray *)locations {
    if (!_locations) {
        _locations = [NSMutableArray array];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mock_locations"
                                                             ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
        for (NSDictionary *location in dict[@"locations"]) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([location[@"lat"] floatValue],
                                                                           [location[@"lon"] floatValue]);
            MyAnnotation *annotation = [[MyAnnotation alloc] init];
            annotation.coordinate = coordinate;
            annotation.title = location[@"name"];
            annotation.radius = [location[@"radius"] floatValue];
            
            [_locations addObject:annotation];
        }
    }
    return _locations;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)findClicked:(id)sender {
    
    [self performSelectorInBackground:@selector(perform) withObject:nil];
}

- (void)perform {
    float lat = [self.latField.text floatValue];
    float lon = [self.lonField.text floatValue];
    float within = [self.withinField.text floatValue];
    NSArray *annotations = [self locationsAtCoordinate:CLLocationCoordinate2DMake(lat, lon) within:within];
    NSLog(@"annotations count: %d", annotations.count);
    
    [self performSelectorOnMainThread:@selector(pinToMapWithAnnotations:)
                           withObject:annotations
                        waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(showAllPins)
                           withObject:nil
                        waitUntilDone:YES];
}

- (void)pinToMapWithAnnotations:(NSArray *)annotations {
    [self.mapview removeAnnotations:self.mapview.annotations];
    [self.mapview addAnnotations:annotations];
}

- (void)showAllPins {
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapview.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    [self.mapview setVisibleMapRect:zoomRect animated:YES];
}

- (NSArray *)locationsAtCoordinate:(CLLocationCoordinate2D)coordinate within:(float)radius{
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        MyAnnotation *location = (MyAnnotation *)evaluatedObject;
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude
                                                      longitude:location.coordinate.longitude];
        float distance = ABS([loc1 distanceFromLocation:loc2]);
        if (distance/1000 <= radius + location.radius) {
            return YES;
        }
        return NO;
    }];
    
    return [self.locations filteredArrayUsingPredicate:filter];
}

@end
