
## Objects 

  - [BatchItemResponse](#batchitemresponse)
  - [BusinessEvent](#businessevent)
  - [Cursor](#cursor)
  - [DataChangeEvent](#datachangeevent)
  - [DataChangeEventQualifier](#datachangeeventqualifier)
  - [Event](#event)
  - [EventMetadata](#eventmetadata)
  - [EventStreamBatch](#eventstreambatch)
  - [EventType](#eventtype)
  - [EventTypeSchema](#eventtypeschema)
  - [EventTypeStatistics](#eventtypestatistics)
  - [Metrics](#metrics)
  - [Partition](#partition)
  - [Problem](#problem)


<a name="definitions"></a>
## Definitions

<a name="batchitemresponse"></a>
### BatchItemResponse
A status corresponding to one individual Event's publishing attempt.


|Name|Description|Schema|
|---|---|---|
|**detail**  <br>*optional*|Human readable information about the failure on this item. Items that are not "submitted"<br>should have a description.|string|
|**eid**  <br>*optional*|eid of the corresponding item. Will be absent if missing on the incoming Event.|string(uuid)|
|**publishing_status**  <br>*required*|Indicator of the submission of the Event within a Batch.<br><br>- "submitted" indicates successful submission, including commit on he underlying broker.<br><br>- "failed" indicates the message submission was not possible and can be resubmitted if so<br>  desired.<br><br>- "aborted" indicates that the submission of this item was not attempted any further due<br>  to a failure on another item in the batch.|enum (submitted, failed, aborted)|
|**step**  <br>*optional*|Indicator of the step in the publishing process this Event reached.<br><br>In Items that "failed" means the step of the failure.<br><br>- "none" indicates that nothing was yet attempted for the publishing of this Event. Should<br>  be present only in the case of aborting the publishing during the validation of another<br>  (previous) Event.<br><br>- "validating", "partitioning", "enriching" and "publishing" indicate all the<br>  corresponding steps of the publishing process.|enum (none, validating, partitioning, enriching, publishing)|


<a name="businessevent"></a>
### BusinessEvent
A Business Event.

Usually represents a status transition in a Business process.

*Polymorphism* : Composition


|Name|Description|Schema|
|---|---|---|
|**metadata**  <br>*required*||[EventMetadata](definitions.md#eventmetadata)|


<a name="cursor"></a>
### Cursor

|Name|Description|Schema|
|---|---|---|
|**offset**  <br>*required*|Offset of the event being pointed to.|string|
|**partition**  <br>*required*|Id of the partition pointed to by this cursor.|string|


<a name="cursorcommitresult"></a>
### CursorCommitResult
The result of single cursor commit. Holds a cursor itself and a result value.


|Name|Description|Schema|
|---|---|---|
|**cursor**  <br>*required*||[SubscriptionCursor](definitions.md#subscriptioncursor)|
|**result**  <br>*required*|The result of cursor commit.<br>- `committed`: cursor was successfully committed<br>- `outdated`: there already was more recent (or the same) cursor committed, so the current one was not<br>  committed as it is outdated|string|


<a name="datachangeevent"></a>
### DataChangeEvent
A Data change Event.

Represents a change on a resource. Also contains indicators for the data 
type and the type of operation performed.

*Polymorphism* : Composition


|Name|Description|Schema|
|---|---|---|
|**data**  <br>*required*|The payload of the type|object|
|**data_op**  <br>*required*|The type of operation executed on the entity.<br>* C: Creation<br>* U: Update<br>* D: Deletion<br>* S: Snapshot|enum (C, U, D, S)|
|**data_type**  <br>*required*|**Example** : `"pennybags:order"`|string|
|**metadata**  <br>*required*||[EventMetadata](definitions.md#eventmetadata)|


<a name="event"></a>
### Event
**Note** The Event definition will be externalized in future versions of this document.

A basic payload of an Event. The actual schema is dependent on the information configured for
the EventType, as is its enforcement (see POST /event-types). Setting of metadata properties
are dependent on the configured enrichment as well.

For explanation on default configurations of validation and enrichment, see documentation of
`EventType.category`.

For concrete examples of what will be enforced by Nakadi see the objects BusinessEvent and
DataChangeEvent below.

*Type* : object


<a name="eventmetadata"></a>
### EventMetadata
Metadata for this Event.

Contains commons fields for both Business and DataChange Events. Most are enriched by Nakadi
upon reception, but they in general MIGHT be set by the client.


|Name|Description|Schema|
|---|---|---|
|**eid**  <br>*required*|Identifier of this Event.<br><br>Clients MUST generate this value and it SHOULD be guaranteed to be unique from the<br>perspective of the producer. Consumers MIGHT use this value to assert uniqueness of<br>reception of the Event.  <br>**Example** : `"105a76d8-db49-4144-ace7-e683e8f4ba46"`|string(uuid)|
|**event_type**  <br>*optional*|The EventType of this Event. This is enriched by Nakadi on reception of the Event<br>based on the endpoint where the Producer sent the Event to.<br><br>If provided MUST match the endpoint. Failure to do so will cause rejection of the<br>Event.  <br>**Example** : `"pennybags.payment-business-event"`|string|
|**flow_id**  <br>*optional*|The flow-id of the producer of this Event. As this is usually a HTTP header, this is<br>enriched from the header into the metadata by Nakadi to avoid clients having to<br>explicitly copy this.  <br>**Example** : `"JAh6xH4OQhCJ9PutIV_RYw"`|string|
|**occurred_at**  <br>*required*|Timestamp of creation of the Event generated by the producer.  <br>**Example** : `"1996-12-19T16:39:57-08:00"`|string(date-time)|
|**parent_eids**  <br>*optional*||< string(uuid) > array|
|**partition**  <br>*optional*|Indicates the partition assigned to this Event.<br><br>Required to be set by the client if partition strategy of the EventType is<br>'user_defined'.  <br>**Example** : `"0"`|string|
|**received_at**  <br>*optional*|Timestamp of the reception of the Event by Nakadi. This is enriched upon reception of<br>the Event.<br>If set by the producer Event will be rejected.  <br>**Example** : `"1996-12-19T16:39:57-08:00"`|string(date-time)|


<a name="eventstreambatch"></a>
### EventStreamBatch
One chunk of events in a stream. A batch consists of an array of `Event`s plus a `Cursor`
pointing to the offset of the last Event in the stream.

The size of the array of Event is limited by the parameters used to initialize a Stream.

If acting as a keep alive message (see `GET /event-type/{name}/events`) the events array will
be omitted.

Sequential batches might present repeated cursors if no new events have arrived.


|Name|Description|Schema|
|---|---|---|
|**cursor**  <br>*required*||[Cursor](definitions.md#cursor)|
|**events**  <br>*optional*||< [Event](definitions.md#event) > array|
|**info**  <br>*optional*||[StreamInfo](definitions.md#streaminfo)|


<a name="eventtype"></a>
### EventType
An event type defines the schema and its runtime properties.


|Name|Description|Schema|
|---|---|---|
|**category**  <br>*required*|Defines the category of this EventType.<br><br>The value set will influence, if not set otherwise, the default set of<br>validations, enrichment-strategies, and the effective schema for validation in<br>the following way:<br><br>- `undefined`: No predefined changes apply. The effective schema for the validation is<br>  exactly the same as the `EventTypeSchema`.<br><br>- `data`: Events of this category will be DataChangeEvents. The effective schema during<br>  the validation contains `metadata`, and adds fields `data_op` and `data_type`. The<br>  passed EventTypeSchema defines the schema of `data`.<br><br>- `business`: Events of this category will be BusinessEvents. The effective schema for<br>  validation contains `metadata` and any additionally defined properties passed in the<br>  `EventTypeSchema` directly on top level of the Event. If name conflicts arise, creation<br>  of this EventType will be rejected.|enum (undefined, data, business)|
|**default_statistics**  <br>*optional*|Defines expected load for this EventType. Nakadi uses this object in order to<br>provide an optimal number of partitions from a throughput perspective.|[EventTypeStatistics](definitions.md#eventtypestatistics)|
|**enrichment_strategies**  <br>*optional*|Determines the enrichment to be performed on an Event upon reception. Enrichment is<br>performed once upon reception (and after validation) of an Event and is only possible on<br>fields that are not defined on the incoming Event.<br><br>For event types in categories 'business' or 'data' it's mandatory to use<br>metadata_enrichment strategy. For 'undefined' event types it's not possible to use this<br>strategy, since metadata field is not required.<br><br>See documentation for the write operation for details on behaviour in case of unsuccessful<br>enrichment.|< enum (metadata_enrichment) > array|
|**name**  <br>*required*|Name of this EventType. The name is constrained by a regular expression.<br><br>Note: the name can encode the owner/responsible for this EventType and ideally should<br>follow a common pattern that makes it easy to read an understand, but this level of<br>structure is not enforced. For example a team name and data type can be used such as<br>'acme-team.price-change'.  <br>**Example** : `"order.order_cancelled, acme-platform.users"`|string|
|**options**  <br>*optional*|Provides ability to set internal Nakadi parameters.|[EventTypeOptions](definitions.md#eventtypeoptions)|
|**owning_application**  <br>*required*|Indicator of the (Stups) Application owning this `EventType`.  <br>**Example** : `"price-service"`|string|
|**partition_key_fields**  <br>*optional*|Required when 'partition_resolution_strategy' is set to 'hash'. Must be absent otherwise.<br>Indicates the fields used for evaluation the partition of Events of this type.<br><br>If set it MUST be a valid required field as defined in the schema.|< string > array|
|**partition_strategy**  <br>*optional*|Determines how the assignment of the event to a partition should be handled.<br><br>For details of possible values, see GET /registry/partition-strategies.  <br>**Default** : `"random"`|string|
|**schema**  <br>*required*|The schema for this EventType. Submitted events will be validated against it.|[EventTypeSchema](definitions.md#eventtypeschema)|


<a name="eventtypeoptions"></a>
### EventTypeOptions
Additional parameters for tuning internal behavior of Nakadi.


|Name|Description|Schema|
|---|---|---|
|**retention_time**  <br>*optional*|Number of milliseconds that Nakadi stores events published to this event type.  <br>**Default** : `345600000`|integer(int64)|


<a name="eventtypeschema"></a>
### EventTypeSchema

|Name|Description|Schema|
|---|---|---|
|**schema**  <br>*required*|The schema as string in the syntax defined in the field type. Failure to respect the<br>syntax will fail any operation on an EventType.<br><br>To have a generic, undefined schema it is possible to define the schema as `"schema":<br>"{\"additionalProperties\": true}"`.|[EventTypeSchema](definitions.md#eventtypeschema)|
|**type**  <br>*required*|The type of schema definition. Currently only json_schema (JSON Schema v04) is supported, but in the<br>future there could be others.|enum (json_schema)|


<a name="eventtypestatistics"></a>
### EventTypeStatistics
Operational statistics for an EventType. This data MUST be provided by users on Event Type
creation.


|Name|Description|Schema|
|---|---|---|
|**message_size**  <br>*required*|Average message size for each Event of this EventType. Includes in the count the whole serialized<br>form of the event, including metadata.<br>Measured in bytes.|integer|
|**messages_per_minute**  <br>*required*|Write rate for events of this EventType. This rate encompasses all producers of this<br>EventType for a Nakadi cluster.<br><br>Measured in event count per minute.|integer|
|**read_parallelism**  <br>*required*|Amount of parallel readers (consumers) to this EventType.|integer|
|**write_parallelism**  <br>*required*|Amount of parallel writers (producers) to this EventType.|integer|


<a name="metrics"></a>
### Metrics
Object containing application metrics.

*Type* : object


<a name="paginationlink"></a>
### PaginationLink
URI identifying another page of items


|Name|Description|Schema|
|---|---|---|
|**href**  <br>*optional*|**Example** : `"/subscriptions?offset=20&limit=10"`|string|


<a name="paginationlinks"></a>
### PaginationLinks
contains links to previous and next pages of items


|Name|Description|Schema|
|---|---|---|
|**next**  <br>*optional*||[PaginationLink](definitions.md#paginationlink)|
|**prev**  <br>*optional*||[PaginationLink](definitions.md#paginationlink)|


<a name="partition"></a>
### Partition
Partition information. Can be helpful when trying to start a stream using an unmanaged API.

This information is not related to the state of the consumer clients.


|Name|Description|Schema|
|---|---|---|
|**newest_available_offset**  <br>*required*|An offset of the newest available Event in that partition. This value will be changing<br>upon reception of new events for this partition by Nakadi.<br><br>This value can be used to construct a cursor when opening streams (see<br>`GET /event-type/{name}/events` for details).<br><br>Might assume the special name BEGIN, meaning a pointer to the offset of the oldest<br>available event in the partition.|string|
|**oldest_available_offset**  <br>*required*|An offset of the oldest available Event in that partition. This value will be changing<br>upon removal of Events from the partition by the background archiving/cleanup mechanism.|string|
|**partition**  <br>*required*||string|


<a name="problem"></a>
### Problem

|Name|Description|Schema|
|---|---|---|
|**detail**  <br>*optional*|A human readable explanation specific to this occurrence of the problem.  <br>**Example** : `"Connection to database timed out"`|string|
|**instance**  <br>*optional*|An absolute URI that identifies the specific occurrence of the problem.<br>It may or may not yield further information if dereferenced.|string|
|**status**  <br>*required*|The HTTP status code generated by the origin server for this occurrence of the problem.  <br>**Example** : `503`|integer(int32)|
|**title**  <br>*required*|A short, summary of the problem type. Written in English and readable for engineers<br>(usually not suited for non technical stakeholders and not localized)  <br>**Example** : `"Service Unavailable"`|string|
|**type**  <br>*required*|An absolute URI that identifies the problem type.  When dereferenced, it SHOULD provide<br>human-readable API documentation for the problem type (e.g., using HTML).  This Problem<br>object is the same as provided by https://github.com/zalando/problem  <br>**Example** : `"http://httpstatus.es/503"`|string|


<a name="streaminfo"></a>
### StreamInfo
This object contains general information about the stream. Used only for debugging
purposes. We recommend logging this object in order to solve connection issues. Clients
should not parse this structure.

*Type* : object


<a name="subscription"></a>
### Subscription
Subscription is a high level consumption unit. Subscriptions allow applications to easily scale the
number of clients by managing consumed event offsets and distributing load between instances.
The key properties that identify subscription are 'owning_application', 'event_types' and 'consumer_group'.
It's not possible to have two different subscriptions with these properties being the same.


|Name|Description|Schema|
|---|---|---|
|**consumer_group**  <br>*optional*|The value describing the use case of this subscription.<br>In general that is an additional identifier used to differ subscriptions having the same<br>owning_application and event_types.  <br>**Default** : `"default"`  <br>**Example** : `"read-product-updates"`|string|
|**created_at**  <br>*optional*  <br>*read-only*|Timestamp of creation of the subscription. This is generated by Nakadi. It should not be<br>specified when creating subscription and sending it may result in a client error.  <br>**Example** : `"1996-12-19T16:39:57-08:00"`|string(date-time)|
|**event_types**  <br>*required*|EventTypes to subscribe to.<br>The order is not important. Subscriptions that differ only be the order of EventTypes will be<br>considered the same and will have the same id.<br><br>* Currently only subscription to a single EventType is supported. Subscriptions with more than one<br>  EventType in event_types property will be rejected.|< string > array|
|**id**  <br>*optional*  <br>*read-only*|Id of subscription that was created. Is generated by Nakadi, should not be specified when creating<br>subscription.|string|
|**owning_application**  <br>*required*|The id of application owning the subscription.  <br>**Example** : `"gizig"`|string|
|**read_from**  <br>*optional*|Position to start reading events from. Currently supported values:<br>- `begin` - read from the oldest available event.<br>- `end` - read from the most recent offset.<br>Applied in the moment when client starts reading from a subscription.  <br>**Default** : `"end"`|string|


<a name="subscriptioncursor"></a>
### SubscriptionCursor
*Polymorphism* : Composition


|Name|Description|Schema|
|---|---|---|
|**cursor_token**  <br>*required*|An opaque value defined by the server.|string|
|**event_type**  <br>*optional*|The name of the event type this partition's events belong to.|string|
|**offset**  <br>*required*|Offset of the event being pointed to.|string|
|**partition**  <br>*required*|Id of the partition pointed to by this cursor.|string|


<a name="subscriptioneventstreambatch"></a>
### SubscriptionEventStreamBatch
Analogue to EventStreamBatch but used for high level streamming. It includes specific cursors
for committing in the high level API.


|Name|Description|Schema|
|---|---|---|
|**cursor**  <br>*required*||[SubscriptionCursor](definitions.md#subscriptioncursor)|
|**events**  <br>*optional*||< [Event](definitions.md#event) > array|
|**info**  <br>*optional*||[StreamInfo](definitions.md#streaminfo)|


<a name="subscriptioneventtypestats"></a>
### SubscriptionEventTypeStats
statistics of one event-type within a context of subscription


|Name|Description|Schema|
|---|---|---|
|**event_type**  <br>*required*|event-type name|string|
|**partitions**  <br>*required*|statistics of partitions of this event-type|< [partitions](#subscriptioneventtypestats-partitions) > array|

<a name="subscriptioneventtypestats-partitions"></a>
**partitions**

|Name|Description|Schema|
|---|---|---|
|**client_id**  <br>*optional*|the id of client that consumes data from this partition|string|
|**partition**  <br>*required*||string|
|**state**  <br>*required*|The state of this partition in current subscription. Currently following values are possible:<br>- `unassigned`: the partition is currently not assigned to any client;<br>- `reassigning`: the partition is currently reasssigning from one client to another;<br>- `assigned`: the partition is assigned to a client.|string|
|**unconsumed_events**  <br>*optional*|The amount of events in this partition that are not yet consumed within this subscription. May be not<br>determined at the moment when no events were yet consumed from the partition in this subscription (in<br>that case the property will be absent).|number|



