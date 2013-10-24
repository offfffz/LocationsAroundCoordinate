//
//  MyAnnotation.h
//  TestHugeLocations
//
//  Created by off on 10/24/13.
//  Copyright (c) 2013 off. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation:NSObject <MKAnnotation>
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) float radius;
@property (copy, nonatomic) NSString *title;
@end
