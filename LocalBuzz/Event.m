//
//  Event.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "Event.h"

@implementation Event

- (id) initWithDictionary:(NSDictionary *)eventDict {
    self = [super init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    if (self) {
        _eventId = [eventDict objectForKey:@"id"];
        _title = [eventDict objectForKey:@"title"];
        _longitude = [eventDict objectForKey:@"longitude"];
        _latitude = [eventDict objectForKey:@"latitude"];
        _detailDescription = [eventDict objectForKey:@"description"];
        _startTime = [dateFormatter dateFromString:[eventDict objectForKey:@"start_time"]];
        _endTime = [dateFormatter dateFromString:[eventDict objectForKey:@"end_time"]];
        _isPublic = [(NSNumber *)[eventDict objectForKey:@"public"] boolValue];
        _category = [eventDict objectForKey:@"category"];
        _ownerFbId = [eventDict objectForKey:@"owner"];
        if ([_detailDescription isKindOfClass:[NSNull class]]) {
            _detailDescription = @"";
        }
        return self;
    }
    return nil;
}

- (BOOL) isEventValid {
    return !([self.title isKindOfClass:[NSNull class]] || [self.longitude isKindOfClass:[NSNull class]] || [self.latitude isKindOfClass:[NSNull class]] || [self.startTime isKindOfClass:[NSNull class]] || [self.endTime isKindOfClass:[NSNull class]]);
}
@end
