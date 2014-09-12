//
//  TestCaseWithCoreData.h
//  
//
//  Created by David Pedersen on 12/09/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface TestCaseWithCoreData : XCTestCase

@property (strong, nonatomic) NSManagedObjectContext *moc;

@end
