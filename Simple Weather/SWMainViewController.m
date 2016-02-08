//
//  ViewController.m
//  Simple Weather
//
//  Created by Kostya on 20.12.15.
//  Copyright © 2015 Stolyarenko K.S. All rights reserved.
//
#import "SWMainViewController.h"
static NSString *const BasicUrl = @"http://api.openweathermap.org";
static NSString *const WeatherCityNameUrl = @"/data/2.5/weather?q=%@,uk&appid=37e0cb1eed95e56934c68507ca80d49f&mine=true";

@interface SWMainViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidity;
@property (weak, nonatomic) IBOutlet UILabel *weatherstatus;
@property (weak, nonatomic) IBOutlet UILabel *pressure;
@property (weak, nonatomic) IBOutlet UILabel *tempmin;
@property (weak, nonatomic) IBOutlet UILabel *tempmax;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *wind;
@property (strong, nonatomic) IBOutlet UIImageView *sun;
@property (strong, nonatomic) IBOutlet UIImageView *rain;
@property (strong, nonatomic) IBOutlet UIImageView *clouds;
@property (strong, nonatomic) IBOutlet UIImageView *snow;
@property (strong, nonatomic) IBOutlet UIImageView *fog;
@property (strong, nonatomic) IBOutlet UIImageView *drizzle;
@end

@implementation SWMainViewController

- (void)viewDidLoad {[super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];

}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //parsing data by Map
    
   //read from file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"weather.txt"];
    NSDictionary *weatherDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    if (weatherDictionary) {
        [self configurationScreenWithDictionary:weatherDictionary];}

    self.name.text = nil;
    
    //delete file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {NSLog(@"success");}
    else{NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *userCityName = textField.text;
    self.name.text = textField.text;
    userCityName = [userCityName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    textField.text = userCityName;
    
    //session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //url
    NSString *urlString = [BasicUrl stringByAppendingString:WeatherCityNameUrl];
    urlString = [NSString stringWithFormat:urlString, textField.text];
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
    textField.text = nil;
    return YES;
}


//parsing data by name of the city
- (void)configurationScreenWithDictionary:(NSDictionary *)weatherDictionary {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *nameCity = weatherDictionary[@"name"];
        self.cityNameLabel.text = nameCity;
        
        NSDictionary *mainDictionary = weatherDictionary[@"main"];
        
        NSString *temperatureString = mainDictionary[@"temp"];
        NSInteger temp = [temperatureString integerValue];
        self.temperatureLabel.text = [@(temp - 273) description];
        

        NSString *temperatureMINString = mainDictionary[@"temp_min"];
        NSInteger tempMIN = [temperatureMINString integerValue];
        self.tempmin.text = [@(tempMIN - 273) description];
        
   
        NSString *temperatureMAXString = mainDictionary[@"temp_max"];
        NSInteger tempmax = [temperatureMAXString integerValue];
        self.tempmax.text = [@(tempmax - 273) description];
        
        NSString *pressureString = mainDictionary[@"pressure"];
        NSInteger pressure = [pressureString integerValue];
        self.pressure.text = [@(pressure) description];
        

        NSString *humidityString = mainDictionary[@"humidity"];
        NSInteger humidity = [humidityString integerValue];
        self.humidity.text = [@(humidity) description];
        
        NSDictionary *windDictionary = weatherDictionary[@"wind"];
        NSString *windString = windDictionary[@"speed"];
        NSInteger wind = [windString integerValue];
        NSLog(@"%li",(long)wind);
        self.wind.text = [@(wind) description];
        
        NSArray *statusesWeather = weatherDictionary[@"weather"];
        NSDictionary *status = statusesWeather[0];
        NSString *weatherstatusString = status[@"main"];
        self.weatherstatus.text = weatherstatusString;
        
        //configurate images
        
        if ([weatherstatusString isEqualToString:@"Clouds"])
        {
            self.clouds.hidden = NO;
            self.sun.hidden = YES;
             self.fog.hidden = YES;
            self.snow.hidden = YES;
            self.rain.hidden = YES;
            self.drizzle.hidden = YES;
        }
        else if ([weatherstatusString isEqualToString:@"Sun"]||[weatherstatusString isEqualToString:@"Clear"])
        {
            self.sun.hidden = NO;
            self.clouds.hidden = YES;
             self.fog.hidden = YES;
            self.snow.hidden = YES;
            self.rain.hidden = YES;
            self.drizzle.hidden = YES;
        }
        else if ([weatherstatusString isEqualToString:@"Rain"])
        {
            self.sun.hidden = YES;
            self.rain.hidden = NO;
            self.clouds.hidden = YES;
             self.fog.hidden = YES;
            self.snow.hidden = YES;
            self.drizzle.hidden = YES;
        }
        else if ([weatherstatusString isEqualToString:@"Snow"])
        {
            self.sun.hidden = YES;
            self.snow.hidden = NO;
            self.clouds.hidden = YES;
            self.fog.hidden = YES;
            self.rain.hidden = YES;
            self.drizzle.hidden = YES;
        }
        else if ([weatherstatusString isEqualToString:@"Fog"])
        {
            self.fog.hidden = NO;
            self.clouds.hidden = YES;
            self.sun.hidden = YES;
            self.snow.hidden = YES;
            self.rain.hidden = YES;
            self.drizzle.hidden = YES;
        }
        else if ([weatherstatusString isEqualToString:@"Drizzle"])
        {
            self.fog.hidden = YES;
            self.clouds.hidden = YES;
            self.sun.hidden = YES;
            self.snow.hidden = YES;
            self.rain.hidden = YES;
            self.drizzle.hidden = NO;
        }
        
    });
    
}

@end

