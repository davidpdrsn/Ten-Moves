//
//  TestCaseWithCoreData.m
//  
//
//  Created by David Pedersen on 12/09/14.
//
//

#import "TestCaseWithCoreData.h"
#import "Repository.h"

@implementation TestCaseWithCoreData

- (void)setUp {
    [super setUp];

    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    XCTAssert([psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL] ? YES : NO, @"Should be able to add in-memory store");
    self.moc = [[NSManagedObjectContext alloc] init];
    self.moc.persistentStoreCoordinator = psc;

    [Repository setManagedObjectContext:self.moc];
}

@end
