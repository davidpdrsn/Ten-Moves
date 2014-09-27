//
//  KIFTestCaseWithCoreData.h
//  TenMoves
//
//  Created by David Pedersen on 27/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KIF/KIF.h>
#import "Repository.h"
#import <CoreData/CoreData.h>

@interface KIFTestCaseWithCoreData : KIFTestCase

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSURL *storeURL;

@end
