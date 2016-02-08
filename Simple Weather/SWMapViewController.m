//
//  SWMapViewController.m
//  Simple Weather
//
//  Created by Stolyarenko on 02.02.16.
//  Copyright © 2016 Stolyarenko K.S. All rights reserved.
//
#import "SWMapViewController.h"
#import <MapKit/MapKit.h>

static NSString *const BasicUrl = @"http://api.openweathermap.org";
static NSString *const UserCityNameUrl = @"/data/2.5/weather?lat=%@&lon=%@&appid=37e0cb1eed95e56934c68507ca80d49f";

@interface SWMapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end




@implementation SWMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestAlwaysAuthorization];
}
- (void)configurationScreenWithDictionary:(NSDictionary *)weatherDictionary {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //write to file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"weather.txt"];
        NSDictionary *dict = weatherDictionary;
        
        BOOL success = [dict writeToFile:filePath atomically:YES];
        if (!success) {
            NSLog(@"error writing");
        }
        //back to previous controller
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 200, 200);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    NSLog(@"Location found from Map: %f %f",region.center.latitude,region.center.longitude);
}

//request to server by tap on the city
- (IBAction)tapMap:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D mapCoordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    //anotation pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = mapCoordinate;
    annotation.title = @"Your City";
    annotation.subtitle = @"Back to main screen";
    [self.mapView addAnnotation:annotation];
    
    //get coordinates
    NSString* latt = [NSString stringWithFormat:@"%f", mapCoordinate.latitude];
    NSString* longg = [NSString stringWithFormat:@"%f", mapCoordinate.longitude];
    NSLog(@"Location found from Ma %@ %@",latt,longg);

    //session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //url
    NSString *urlString = [BasicUrl stringByAppendingString:UserCityNameUrl];
    urlString = [NSString stringWithFormat:urlString, latt,longg];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //request
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                                
                                                //parsing request
                                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                [strongSelf configurationScreenWithDictionary:json];
                                            }];
    [dataTask resume];

}


@end
