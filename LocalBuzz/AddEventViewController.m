//
//  AddEventViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "AddEventViewController.h"
#import "TimePickerViewController.h"
#import "LocationSelectionViewController.h"
#import "AFHTTPClient.h"

@interface AddEventViewController ()
{
	@private NSDate *startTime;
	@private NSDate *endTime;
	@private LocationSelectionViewController *locationSelector;
}
@end

@implementation AddEventViewController
@synthesize titleField = _titleField;
@synthesize latitudeCell = _latitudeCell;
@synthesize startTimeCell = _startTimeCell;
@synthesize endTimeCell = _endTimeCell;
@synthesize location = _location;
@synthesize switcher = _switcher;

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)timeSelected:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"ReturnTime"]) {
        TimePickerViewController *timePicker = [segue sourceViewController];
        NSDate *pickedTime = timePicker.timePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        if (timePicker.timepickerMode == PickStartTime) {
            startTime = pickedTime;
            self.startTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:startTime];
        } else if (timePicker.timepickerMode == PickEndtime) {
            endTime = pickedTime;
            self.endTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:endTime];
        }
    }
}

- (IBAction)locationSelected:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"ReturnLocation"]) {
			locationSelector = [segue sourceViewController];
			CLLocationCoordinate2D selectedLatLong = locationSelector.latLong;
			CLLocation *loc = [[CLLocation alloc] initWithLatitude:selectedLatLong.latitude longitude:selectedLatLong.longitude];
			
			CLGeocoder *geocoder = [[CLGeocoder alloc] init];
			
			//Geocoding Block
			[geocoder reverseGeocodeLocation: loc completionHandler:^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
				 
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         
         //Set the label text to current location
         [self.location.detailTextLabel setText:locatedAt];
			 }];
    }
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SelectStartTime"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        startTime = [dateFormatter dateFromString:self.startTimeCell.detailTextLabel.text];
        NSLog(@"%@", [startTime description]);
        TimePickerViewController *timePickerController = segue.destinationViewController;
        timePickerController.timeToDisplay = startTime;
        timePickerController.minimumDate = [[NSDate date] dateByAddingTimeInterval:-300];
        timePickerController.timepickerMode = PickStartTime;
    }
    if ([[segue identifier] isEqualToString:@"SelectEndTime"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        endTime = [dateFormatter dateFromString:self.endTimeCell.detailTextLabel.text];
        NSLog(@"%@", [endTime description]);
        TimePickerViewController *timePickerController = segue.destinationViewController;
        timePickerController.timeToDisplay = endTime;
        timePickerController.minimumDate = startTime;
        timePickerController.timepickerMode = PickEndtime;
    }
    if ([[segue identifier] isEqualToString:@"EventCreated"]) {
        NSURL *createUserURL = [NSURL URLWithString:@"http://localbuzz.vforvincent.info/"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:createUserURL];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSNumber *isPublic = [[NSNumber alloc] initWithBool:self.switcher.isOn];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.titleField.text, @"event[title]",
                                [dateFormatter stringFromDate:startTime], @"event[start_time]",
                                [dateFormatter stringFromDate:endTime], @"event[end_time]",
                                [[NSNumber numberWithDouble:locationSelector.latLong.longitude] stringValue], @"event[longitude]",
                                [[NSNumber numberWithDouble:locationSelector.latLong.latitude] stringValue], @"event[latitude]",
                                isPublic, @"event[public]",
                                @"Random description", @"event[description]",
                                nil];
        [httpClient postPath:@"/events.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"Response: %@", responseString);
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        }];
    }
}

- (void) viewDidLoad {
	// for converting lat lon to address
	[super viewDidLoad];
	
	self.titleField.delegate = self;
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	[self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void) viewDidUnload {
	[super viewDidUnload];
}

- (IBAction)SwitchChange:(id)sender {
}

- (void) hideKeyboard {
    [self.titleField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}


@end
