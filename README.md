# VDSKit
Virtual Data Source System

VDSKit is an evolution of a previous implemtation of a configurable incremental store system that has been in production for the last 5 years. VDSKit is built around the following central goals:

1. Processing of incoming and outgoing data should be performed in a transaction-wrapper, enabling progress tracking, concelation, and granular error handling.
2. Components should be swappable, subclassble, and/or extendable
3. The architecture should provide a high-level abstraction layer on top of a configurable and/or customizable implementation layer.
4. The system should be fully Swift compatible.
5. The system should be fully documented.
6. The system should be fully tested.

## Components: Extended Operations

VDSKit includes a set of extended operations modeled on the WWDC 2015 Example Swift code for extending NSOperation. These subclasses provide a number of useful features within VDSKit including:

1. Support for conditional execution of oprations beyond NSOperation's dependency system.
2. Support for filtering the Operation Queue via preventing opertions from being added or providing replacement operations for an operation.
3. Delegate support for an operation queue.
4. Extended observing behavior for operations to supplement Key-Value Observing (KVO).
5. Support for multiple completion blocks via chaining per operation.
6. Support for a group operation (an operation that manages operations).
7. Mutual exclusion support for opertions across VDSOperationQueues.

#### Status: Available, 0.1a

Extended Operations are available for use and include tests demonstrating how to use them as well as extensive header documentation.

## Components: Database Cache

VDSKit includes a set of caching classes built on a core class, VDSDatabaseCache, a subclassable, enumerable, and archivable object caching system. The class provides object tracking using expiration, usage, and/or max object counts and supports mixing of tracked and untracked objects for maximum caching flexibility. Adding and evicting methods are thread safe, as are all cache configuration properties. The class may be used as is, may be safely subclassed, or may be used as a backing class for a facade that limits direct cache storage manipulation to facade internals.

#### Status: In Progress, 0.1a

VDSDatabaseCache is available for exploration along with an associated class, VDSExpirableObject. This class is likely to undergo significant change until availability, so please use with caution.

## Components: Database Context

VDSKit includes a high level database context that coordinates trasactions.

#### Status: In Progress, 0.1a

VDSDatabaseCache is available for exploration. This class is likely to undergo significant change until availability, so please use with caution.

## Components: Database Operation Manager

VDSKit includes a high level database operation manager that coordinates trasaction components.

#### Status: In Progress, 0.1a

VDSDatabaseOperationManager is stubbed and may be removed or altered significantly and is therefore not suitable for use at this time.
