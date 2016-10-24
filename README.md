## Overview

**RamblerSpotlight** is easy way to setup CoreSpotlight in your app.



<img src="https://habrastorage.org/files/441/411/e31/441411e31416405d89f44555553f1716.jpg" height="300" />



### Key features

- Provides all the infrastructure for using dynamic objects in Spotlight
- Keeps Spotlight data up to date
- Saves data that need index later
- Battle-tested into several *Rambler&Co* projects.

## Installation

`pod RamblerSpotlight`

Development target: ios 9.0 or later

## Usage

For full information clone the example project

Before using read our article:

https://habrahabr.ru/company/rambler-co/blog/268257/

 1. Create SpotlightEntityObject for your entity.

You need to create next classes:

`
@interface NameEntityChangeProviderFetchRequestFactory : NSObject <ChangeProviderFetchRequestFactory> 
...

@interface NameEntityObjectIndexer : ObjectIndexerBase
...

@interface NameEntityObjectTransformer : NSObject <ObjectTransformer>
...
`

Aftet that create SpotlightEntityObject:

`
SpotlightEntityObject *spotlightEntity = [SpotlightEntityObject entityObjectWithObjectTransformer:objectTransformer
                                                                                       requestFactory:requestFactory
                                                                                        objectIndexer:objectIndexer];
`

 2. Create RamblerSpotlight's object

`
RamblerSpotlight *ramblerSpotlight = [[RamblerSpotlight alloc] init];
`

 3. Setup RamblerSpotlight with entities, your app's context and CSSearchableIndex

`
NSArray<SpotlightEntitieObject> *entitiesObjects = @[...];
NSManagedObjectContext *context = [MagicalRecord MR_defaultContext];
CSSearchableIndex *searchableIndex =  [CSSearchableIndex defaultContext];

[ramblerSpotlight setupSpotlightWithSpotlightEntitiesObjects:entitiesObjects
                                                  appContext:context
                                             searchableIndex:searchableIndex];
`
    
 4. Start monitoring for changes to your objects in CoreData

`
[ramblerSpotlight startMonitoring];
`

## Author

k.zinovyev, k.zinovyev@rambler-co.ru

e.tolstoy, e.tolstoy@rambler-co.ru

v.smal, v.smal@rambler-co.ru

## Links

https://habrahabr.ru/company/rambler-co/blog/268257/

## License

RamblerSpotlight is available under the MIT license. 
Copyright (c) 2016 Rambler Digital Solutions

See the LICENSE file for more info.
