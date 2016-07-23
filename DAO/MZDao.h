//
//  MZDao.h
//  coredata
//
//  Created by mohamed ahmed on 7/23/16.
//  Copyright © 2016 mohamed.elzokla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#define DATABASE_MODEL_NAME @"coredata"


#define UPDATE_FAILED_RECORD_DOESNOT_EXIT -1
#define UPDATE_FAILED -2
#define UPDATE_SUCCESSEDED 1

@interface MZDao : NSObject <UIApplicationDelegate>
@property NSString * entityName;



//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;

-(NSInteger)insertNewRecord:(NSDictionary*)newRecord ;

-(NSArray*)fetchFromEntity:(NSString *)entityName; // fetched all the records
-(NSArray *)fetchFromEntity:(NSString *)entityName WithPredicate:(NSPredicate*)predicate;

-(NSInteger)deleteRecord:(NSManagedObject *)record;
-(NSInteger)deleteRecordsWithPredicate:(NSPredicate *)predicate;


-(NSInteger)updateRecord:(NSDictionary*)updatedRecord  WithPredicate:(NSPredicate*)predicate;

+(NSDictionary *)managedObjectToDictionary:(NSManagedObject*)managedObj;
@end
