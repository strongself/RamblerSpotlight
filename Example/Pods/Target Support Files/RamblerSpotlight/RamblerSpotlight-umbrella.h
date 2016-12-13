#import <UIKit/UIKit.h>

#import "ChangeProviderFetchRequestFactory.h"
#import "FetchedResultsControllerChangeProvider.h"
#import "ChangeProvider.h"
#import "ChangeProviderDelegate.h"
#import "SpotlightIndexerConstants.h"
#import "ContextFiller.h"
#import "ContextProvider.h"
#import "ContextStorageImplementation.h"
#import "SpotlightCoreDataHandler.h"
#import "SpotlightCoreDataHandlerImplementation.h"
#import "SpotlightCoreDataStackCoordinator.h"
#import "SpotlightCoreDataStackCoordinatorImplementation.h"
#import "IndexState+CoreDataProperties.h"
#import "IndexState.h"
#import "IndexerMonitor.h"
#import "IndexerMonitorOperationQueueFactory.h"
#import "IndexerStateStorage.h"
#import "ObjectIndexerBase.h"
#import "ObjectIndexer.h"
#import "ObjectTransformerConstants.h"
#import "ObjectTransformer.h"
#import "RamblerSpotlight.h"
#import "SpotlightAssembly.h"
#import "SpotlightEntityObject.h"
#import "ChangeProviderChangeType.h"
#import "IndexTransaction.h"
#import "IndexTransactionBatch.h"

FOUNDATION_EXPORT double RamblerSpotlightVersionNumber;
FOUNDATION_EXPORT const unsigned char RamblerSpotlightVersionString[];

