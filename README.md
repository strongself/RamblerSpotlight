## Overview

**RamblerSpotlight** is easy way to setup CoreSpotlight in your app.
<p align="center">
  <img src="https://habrastorage.org/files/441/411/e31/441411e31416405d89f44555553f1716.jpg" height="300" />
</p>
![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Test Coverage](https://img.shields.io/badge/Test%20Coverage-100%25-orange.svg)
![Status](https://img.shields.io/badge/status-beta-red.svg)

         | Key Features
---------|---------------
&#128640; | Provides all the infrastructure for using objects in Spotlight.
&#9851;   | Keeps Spotlight data up to date.
&#128190; | Saves data that needs index later.
&#128242; | Battle-tested into several *Rambler&Co* projects.

## Installation

```objective-c
pod RamblerSpotlight
```

Development target: ios 9.0 or later

## Usage

For full information clone the example project

Before using read [our article on Habrahabr.ru](https://habrahabr.ru/company/rambler-co/blog/268257/)

 1. Create SpotlightEntityObject for your entity.

You need to create next classes:

```objective-c
@interface NameEntityChangeProviderFetchRequestFactory : NSObject <ChangeProviderFetchRequestFactory> 
...

@interface NameEntityObjectIndexer : ObjectIndexerBase
...

@interface NameEntityObjectTransformer : NSObject <ObjectTransformer>
...
```

After that create SpotlightEntityObject:

```objective-c
SpotlightEntityObject *spotlightEntity = [SpotlightEntityObject entityObjectWithObjectTransformer:objectTransformer
                                                                                       requestFactory:requestFactory
                                                                                        objectIndexer:objectIndexer];
```

 2. Create RamblerSpotlight's object

```objective-c
RamblerSpotlight *ramblerSpotlight = [[RamblerSpotlight alloc] init];
```

 3. Setup RamblerSpotlight with entities, your app's context and CSSearchableIndex

```objective-c
NSArray<SpotlightEntityObject *> *entitiesObjects = @[...];
NSManagedObjectContext *context ... ;
CSSearchableIndex *searchableIndex =  [CSSearchableIndex defaultContext];

[ramblerSpotlight setupSpotlightWithSpotlightEntitiesObjects:entitiesObjects
                                                  appContext:context
                                             searchableIndex:searchableIndex];
```
    
 4. Start monitoring for changes to your objects in CoreData

```objective-c
[ramblerSpotlight startMonitoring];
```

## Author

- Konstantin Zinovyev, k.zinovyev@rambler-co.ru

- Egor Tolstoy, e.tolstoy@rambler-co.ru

- Vadim Smal, v.smal@rambler-co.ru

## Links

https://habrahabr.ru/company/rambler-co/blog/268257/

## License

RamblerSpotlight is available under the MIT license. 
Copyright (c) 2016 Rambler Digital Solutions

See the LICENSE file for more info.
