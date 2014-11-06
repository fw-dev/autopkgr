//
//  unittest.m
//  unittest
//
//  Created by Hoa V. DINH on 10/20/14.
//  Copyright (c) 2014 MailCore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <MailCore/MailCore.h>

@interface MCOMessageBuilder (UnitTest)

- (void) _setBoundaries:(NSArray *)boundaries;

@end

@interface MCOMessageHeader (UnitTest)

- (void) prepareForUnitTest;

@end

@implementation MCOMessageHeader (UnitTest)

- (void) prepareForUnitTest
{
    if (fabs([[self date] timeIntervalSinceNow]) <= 2) {
        // Date might be generated, set to known date.
        [self setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    }
    if (fabs([[self receivedDate] timeIntervalSinceNow]) <= 2) {
        // Date might be generated, set to known date.
        [self setReceivedDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    }
    if ([self isMessageIDAutoGenerated]) {
        [self setMessageID:@"MyMessageID123@mail.gmail.com"];
    }
}

@end

@interface MCOAbstractPart (UnitTest)

- (void) prepareForUnitTest;

@end

@implementation MCOAbstractPart (UnitTest)

- (void) prepareForUnitTest
{
}

@end

@implementation MCOAbstractMessagePart (UnitTest)

- (void) prepareForUnitTest
{
    [[self header] prepareForUnitTest];
    [[self mainPart] prepareForUnitTest];
}

@end

@implementation MCOAbstractMultipart (UnitTest)

- (void) prepareForUnitTest
{
    for(MCOAbstractPart * part in [self parts]) {
        [part prepareForUnitTest];
    }
}

@end

@interface unittest : XCTestCase

@end

@implementation unittest {
    NSString * _mainPath;
    NSString * _builderPath;
    NSString * _parserPath;
    NSString * _builderOutputPath;
    NSString * _parserOutputPath;
    NSString * _charsetDetectionPath;
    NSString * _summaryDetectionPath;
    NSString * _summaryDetectionOutputPath;
}

- (void)setUp {
    [super setUp];
    _mainPath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"data"];
    _builderPath = [_mainPath stringByAppendingPathComponent:@"builder/input"];
    _builderOutputPath = [_mainPath stringByAppendingPathComponent:@"builder/output"];
    _parserPath = [_mainPath stringByAppendingPathComponent:@"parser/input"];
    _parserOutputPath = [_mainPath stringByAppendingPathComponent:@"parser/output"];
    _charsetDetectionPath = [_mainPath stringByAppendingPathComponent:@"charset-detection"];
    _summaryDetectionPath = [_mainPath stringByAppendingPathComponent:@"summary/input"];
    _summaryDetectionOutputPath = [_mainPath stringByAppendingPathComponent:@"summary/output"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMessageBuilder1 {
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithRFC822String:@"Hoà <dinh.viet.hoa@gmail.com>"]];
    [[builder header] setTo:@[[MCOAddress addressWithRFC822String:@"Foo Bar <dinh.viet.hoa@gmail.com>"]]];
    [[builder header] setSubject:@"testMessageBuilder1"];
    [[builder header] setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    [[builder header] setMessageID:@"MyMessageID123@mail.gmail.com"];
    [builder setHTMLBody:@"<html><body>This is a HTML content</body></html>"];
    NSString * path = [_builderOutputPath stringByAppendingPathComponent:@"builder1.eml"];
    NSData * expectedData = [NSData dataWithContentsOfFile:path];
    [builder _setBoundaries:@[@"1", @"2", @"3", @"4", @"5"]];
    //[[builder data] writeToFile:@"/Users/hoa/builder1-now.eml" atomically:YES];
    XCTAssertEqualObjects([[NSString alloc] initWithData:[builder data] encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:expectedData encoding:NSUTF8StringEncoding], @"Pass");
    //XCTAssertEqualObjects([builder data], expectedData, @"Pass");
}

- (void)testMessageBuilder2 {
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithRFC822String:@"Hoà <dinh.viet.hoa@gmail.com>"]];
    [[builder header] setTo:@[[MCOAddress addressWithRFC822String:@"Foo Bar <dinh.viet.hoa@gmail.com>"], [MCOAddress addressWithRFC822String:@"Other Recipient <another-foobar@to-recipient.org>"]]];
    [[builder header] setCc:@[[MCOAddress addressWithRFC822String:@"Carbon Copy <dinh.viet.hoa@gmail.com>"], [MCOAddress addressWithRFC822String:@"Other Recipient <another-foobar@to-recipient.org>"]]];
    [[builder header] setSubject:@"testMessageBuilder2"];
    [[builder header] setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    [[builder header] setMessageID:@"MyMessageID123@mail.gmail.com"];
    [builder setHTMLBody:@"<html><body>This is a HTML content</body></html>"];
    NSString * path = [_builderPath stringByAppendingPathComponent:@"photo.jpg"];
    [builder addAttachment:[MCOAttachment attachmentWithContentsOfFile:path]];
    path = [_builderPath stringByAppendingPathComponent:@"photo2.jpg"];
    [builder addAttachment:[MCOAttachment attachmentWithContentsOfFile:path]];
    [builder _setBoundaries:@[@"1", @"2", @"3", @"4", @"5"]];
    path = [_builderOutputPath stringByAppendingPathComponent:@"builder2.eml"];
    NSData * expectedData = [NSData dataWithContentsOfFile:path];
    //[[builder data] writeToFile:@"/Users/hoa/builder2-now.eml" atomically:YES];
    XCTAssertEqualObjects([[NSString alloc] initWithData:[builder data] encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:expectedData encoding:NSUTF8StringEncoding], @"Pass");
}

- (void)testMessageBuilder3 {
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithRFC822String:@"Hoà <dinh.viet.hoa@gmail.com>"]];
    [[builder header] setTo:@[[MCOAddress addressWithRFC822String:@"Foo Bar <dinh.viet.hoa@gmail.com>"], [MCOAddress addressWithRFC822String:@"Other Recipient <another-foobar@to-recipient.org>"]]];
    [[builder header] setCc:@[[MCOAddress addressWithRFC822String:@"Carbon Copy <dinh.viet.hoa@gmail.com>"], [MCOAddress addressWithRFC822String:@"Other Recipient <another-foobar@to-recipient.org>"]]];
    [[builder header] setSubject:@"testMessageBuilder3"];
    [[builder header] setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    [[builder header] setMessageID:@"MyMessageID123@mail.gmail.com"];
    [builder setHTMLBody:@"<html><body><div>This is a HTML content</div><div><img src=\"cid:123\"></div></body></html>"];
    NSString * path = [_builderPath stringByAppendingPathComponent:@"photo.jpg"];
    [builder addAttachment:[MCOAttachment attachmentWithContentsOfFile:path]];
    path = [_builderPath stringByAppendingPathComponent:@"photo2.jpg"];
    MCOAttachment * attachment = [MCOAttachment attachmentWithContentsOfFile:path];
    [attachment setContentID:@"123"];
    [builder addRelatedAttachment:attachment];
    [builder _setBoundaries:@[@"1", @"2", @"3", @"4", @"5"]];
    path = [_builderOutputPath stringByAppendingPathComponent:@"builder3.eml"];
    NSData * expectedData = [NSData dataWithContentsOfFile:path];
    //[[builder data] writeToFile:@"/Users/hoa/builder3-now.eml" atomically:YES];
    XCTAssertEqualObjects([[NSString alloc] initWithData:[builder data] encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:expectedData encoding:NSUTF8StringEncoding], @"Pass");
}

- (void)testMessageParser {
    NSArray * list = [[NSFileManager defaultManager] subpathsAtPath:_parserPath];
    for(NSString * name in list) {
        NSString * path = [_parserPath stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (isDirectory) {
            continue;
        }
        NSData * data = [NSData dataWithContentsOfFile:path];
        MCOMessageParser * parser = [[MCOMessageParser alloc] initWithData:data];
        [[parser header] prepareForUnitTest];
        [[parser mainPart] prepareForUnitTest];
        mailcore::MessageParser * mcParser = MCO_FROM_OBJC(mailcore::MessageParser, parser);
        NSDictionary * result = MCO_TO_OBJC(mcParser->serializable());
        
//        mailcore::String * jsonString = mailcore::JSON::objectToJSONString(mcParser->serializable());
//        NSString * str = MCO_TO_OBJC(jsonString);
//        NSString * resultPath = [@"/Users/hoa/mc2-results" stringByAppendingPathComponent:name];
//        NSString * directory = [resultPath stringByDeletingLastPathComponent];
//        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
//        [str writeToFile:resultPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        
        path = [_parserOutputPath stringByAppendingPathComponent:name];
        NSData * expectedData = [NSData dataWithContentsOfFile:path];
        NSDictionary * expectedResult = [NSJSONSerialization JSONObjectWithData:expectedData options:0 error:NULL];
        
        XCTAssertEqualObjects(result, expectedResult, @"file %@", name);
    }
}

- (void)testCharsetDetection {
    NSArray * list = [[NSFileManager defaultManager] subpathsAtPath:_charsetDetectionPath];
    for(NSString * name in list) {
        NSString * path = [_charsetDetectionPath stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (isDirectory) {
            continue;
        }
        NSData * data = [NSData dataWithContentsOfFile:path];
        NSString * charset = MCO_TO_OBJC([data mco_mcData]->charsetWithFilteredHTML(false));
        charset = [charset lowercaseString];
        XCTAssertEqualObjects([[name lastPathComponent] stringByDeletingPathExtension], charset);
    }
}

- (void)testSummary {
    NSArray * list = [[NSFileManager defaultManager] subpathsAtPath:_summaryDetectionPath];
    for(NSString * name in list) {
        NSString * path = [_summaryDetectionPath stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (isDirectory) {
            continue;
        }
        NSData * data = [NSData dataWithContentsOfFile:path];
        MCOMessageParser * parser = [MCOMessageParser messageParserWithData:data];
        [[parser header] prepareForUnitTest];
        NSString * str = [parser plainTextRendering];

//        NSString * outputPath = [@"/Users/hoa/mc2-results/summary" stringByAppendingPathComponent:name];
//        outputPath = [[outputPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
//        NSString * directory = [outputPath stringByDeletingLastPathComponent];
//        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
//        [str writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];

        NSString * resultPath = [_summaryDetectionOutputPath stringByAppendingPathComponent:name];
        resultPath = [[resultPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
        NSData * resultData = [NSData dataWithContentsOfFile:resultPath];
        if (resultData == nil) {
            NSLog(@"test %@ is a well-known failing test", name);
            continue;
        }

        XCTAssertEqualObjects(str, [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
    }
}

@end
