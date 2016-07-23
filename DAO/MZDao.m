//
//  MZDao.m
//  coredata
//
//  Created by mohamed ahmed on 7/23/16.
//  Copyright © 2016 mohamed.elzokla. All rights reserved.
//

#import "MZDao.h"

@interface MZDao ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@end

@implementation MZDao


#pragma mark - Queries
-(NSInteger)insertNewRecord:(NSDictionary*)newRecord{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newManagedRecord = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:context];
    for (NSString * key in newRecord) {
        [newManagedRecord setValue:[newRecord objectForKey:key] forKey:key];
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        return -1;
    }
    return 1;
}
-(NSArray*)fetchAllRecords{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:_entityName];
    NSArray * result = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    return result;
    
}
-(NSArray *)fetchRecordsWithPredicate:(NSPredicate *)predicate{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:_entityName];
    [fetchRequest setPredicate:predicate];
    NSArray * result = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    return result;
    
}
-(NSArray *)fetchRecordsWithKey:(NSString *)key value:(NSString *)value{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:_entityName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",key,value]];
    NSArray * result = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    return result;
    
}

-(NSInteger)deleteRecord:(NSManagedObject *)record{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    [managedObjectContext deleteObject:record];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return -1;
    }
    return 1;
}

-(NSInteger)deleteRecordsWithPredicate:(NSPredicate *)predicate{
    NSArray * fetchedRecords = [self fetchRecordsWithPredicate:predicate];
    NSInteger numberOfDeletedRecords = 0;
    for (NSManagedObject * obj in fetchedRecords) {
        NSInteger result =[self deleteRecord:obj];
        if (result>0) {
            numberOfDeletedRecords ++;
        }
    }
    return numberOfDeletedRecords;
}

-(NSInteger)deleteRecordsWithKey:(NSString *)key value:(NSString*)value{
    NSArray * fetchedRecords = [self fetchRecordsWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@",key,value]];
    NSInteger numberOfDeletedRecords = 0;
    for (NSManagedObject * obj in fetchedRecords) {
        NSInteger result =[self deleteRecord:obj];
        if (result>0) {
            numberOfDeletedRecords ++;
        }
    }
    return numberOfDeletedRecords;
}

-(NSInteger)updateRecord:(NSDictionary*)updatedRecord  WithPredicate:(NSPredicate*)predicate{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSManagedObject * oldRecord =[[self fetchRecordsWithPredicate:predicate]firstObject];
    if(!oldRecord ){
        NSLog(@"Record doesn't exist");
        return UPDATE_FAILED_RECORD_DOESNOT_EXIT;
    }
    
    for (NSString * key in updatedRecord) {
        [oldRecord setValue:[updatedRecord objectForKey:key] forKey:key];
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        return UPDATE_FAILED;
    }
    
    return UPDATE_SUCCESSEDED;
}
#pragma mark - Util 
+(NSDictionary *)managedObjectToDictionary:(NSManagedObject *)managedObj{
    NSArray *keys = [[[managedObj entity] attributesByName] allKeys];
    NSDictionary *dict = [managedObj dictionaryWithValuesForKeys:keys];
    return dict;
}
#pragma mark - Application Delegate
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}



#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.elzokla.coredata" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DATABASE_MODEL_NAME withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"coredata.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
        }
    }
}

@end
