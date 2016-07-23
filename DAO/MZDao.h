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


-(NSInteger)insertNewRecord:(NSDictionary*)newRecord ;

-(NSArray*)fetchAllRecords; // fetched all the records
-(NSArray *)fetchRecordsWithPredicate:(NSPredicate*)predicate;
-(NSArray *)fetchRecordsWithKey:(NSString *)key value:(NSString*)value;

-(NSInteger)deleteRecord:(NSManagedObject *)record;
-(NSInteger)deleteRecordsWithPredicate:(NSPredicate *)predicate;
-(NSInteger)deleteRecordsWithKey:(NSString *)key value:(NSString*)value;


-(NSInteger)updateRecord:(NSDictionary*)updatedRecord  WithPredicate:(NSPredicate*)predicate;

+(NSDictionary *)managedObjectToDictionary:(NSManagedObject*)managedObj;
@end
