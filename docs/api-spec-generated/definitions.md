
## Objects

  - [AuthorizationAttribute](#authorizationattribute)
  - [BatchItemResponse](#batchitemresponse)
  - [BusinessEvent](#businessevent)
  - [Cursor](#cursor)
  - [CursorCommitResult](#cursorcommitresult)
  - [CursorDistanceQuery](#cursordistancequery)
  - [CursorDistanceResult](#cursordistanceresult)
  - [DataChangeEvent](#datachangeevent)
  - [Event](#event)
  - [EventMetadata](#eventmetadata)
  - [EventStreamBatch](#eventstreambatch)
  - [EventType](#eventtype)
  - [EventTypeAuthorization](#eventtypeauthorization)
  - [EventTypeOptions](#eventtypeoptions)
  - [EventTypeSchema](#eventtypeschema)
  - [EventTypeStatistics](#eventtypestatistics)
  - [Feature](#feature)
  - [Metrics](#metrics)
  - [PaginationLink](#paginationlink)
  - [PaginationLinks](#paginationlinks)
  - [Partition](#partition)
  - [Problem](#problem)
  - [ShiftedCursor](#shiftedcursor)
  - [Storage](#storage)
  - [StreamInfo](#streaminfo)
  - [Subscription](#subscription)
  - [SubscriptionCursor](#subscriptioncursor)
  - [SubscriptionCursorWithoutToken](#subscriptioncursorwithouttoken)
  - [SubscriptionEventStreamBatch](#subscriptioneventstreambatch)
  - [SubscriptionEventTypeStats](#subscriptioneventtypestats)


<a name="definitions"></a>
## Definitions

<a name="authorizationattribute"></a>
### AuthorizationAttribute
An attribute for authorization. This object includes a data type, which represents the type of the attribute
attribute (which data types are allowed depends on which authorization plugin is deployed, and how it is
configured), and a value. A wildcard can be represented with data type '*', and value '*'. It means that all
authenticated users are allowed to perform an operation.


|Name|Description|Schema|
|---|---|---|
|**data_type**  <br>*required*|the type of attribute (e.g., 'team', or 'permission', depending on the Nakadi configuration)|string|
|**value**  <br>*required*|the value of the attribute|string|


<a name="batchitemresponse"></a>
### BatchItemResponse
A status corresponding to one individual Event's publishing attempt.


|Name|Description|Schema|
|---|---|---|
|**detail**  <br>*optional*|Human readable information about the failure on this item. Items that are not "submitted"<br>should have a description.|string|
|**eid**  <br>*optional*|eid of the corresponding item. Will be absent if missing on the incoming Event.|string (uuid)|
|**publishing_status**  <br>*required*|Indicator of the submission of the Event within a Batch.<br><br>- "submitted" indicates successful submission, including commit on he underlying broker.<br><br>- "failed" indicates the message submission was not possible and can be resubmitted if so<br>  desired.<br><br>- "aborted" indicates that the submission of this item was not attempted any further due<br>  to a failure on another item in the batch.|enum (submitted, failed, aborted)|
|**step**  <br>*optional*|Indicator of the step in the publishing process this Event reached.<br><br>In Items that "failed" means the step of the failure.<br><br>- "none" indicates that nothing was yet attempted for the publishing of this Event. Should<br>  be present only in the case of aborting the publishing during the validation of another<br>  (previous) Event.<br><br>- "validating", "partitioning", "enriching" and "publishing" indicate all the<br>  corresponding steps of the publishing process.|enum (none, validating, partitioning, enriching, publishing)|


<a name="businessevent"></a>
### BusinessEvent
A Business Event.

Usually represents a status transition in a Business process.

*Polymorphism* : Composition


|Name|Schema|
|---|---|
|**metadata**  <br>*required*|[EventMetadata](definitions.md#eventmetadata)|


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


<a name="cursordistancequery"></a>
### CursorDistanceQuery

|Name|Schema|
|---|---|
|**final_cursor**  <br>*required*|[Cursor](definitions.md#cursor)|
|**initial_cursor**  <br>*required*|[Cursor](definitions.md#cursor)|


<a name="cursordistanceresult"></a>
### CursorDistanceResult
*Polymorphism* : Composition


|Name|Schema|
|---|---|
|**final_cursor**  <br>*required*|[Cursor](definitions.md#cursor)|
|**initial_cursor**  <br>*required*|[Cursor](definitions.md#cursor)|


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
|**eid**  <br>*required*|Identifier of this Event.<br><br>Clients MUST generate this value and it SHOULD be guaranteed to be unique from the<br>perspective of the producer. Consumers MIGHT use this value to assert uniqueness of<br>reception of the Event.  <br>**Example** : `"105a76d8-db49-4144-ace7-e683e8f4ba46"`|string (uuid)|
|**event_type**  <br>*optional*|The EventType of this Event. This is enriched by Nakadi on reception of the Event<br>based on the endpoint where the Producer sent the Event to.<br><br>If provided MUST match the endpoint. Failure to do so will cause rejection of the<br>Event.  <br>**Example** : `"pennybags.payment-business-event"`|string|
|**flow_id**  <br>*optional*|The flow-id of the producer of this Event. As this is usually a HTTP header, this is<br>enriched from the header into the metadata by Nakadi to avoid clients having to<br>explicitly copy this.  <br>**Example** : `"JAh6xH4OQhCJ9PutIV_RYw"`|string|
|**occurred_at**  <br>*required*|Timestamp of creation of the Event generated by the producer.  <br>**Example** : `"1996-12-19T16:39:57-08:00"`|string (date-time)|
|**parent_eids**  <br>*optional*||< string (uuid) > array|
|**partition**  <br>*optional*|Indicates the partition assigned to this Event.<br><br>Required to be set by the client if partition strategy of the EventType is<br>'user_defined'.  <br>**Example** : `"0"`|string|
|**received_at**  <br>*optional*  <br>*read-only*|Timestamp of the reception of the Event by Nakadi. This is enriched upon reception of<br>the Event.<br>If set by the producer Event will be rejected.  <br>**Example** : `"1996-12-19T16:39:57-08:00"`|string (date-time)|
|**version**  <br>*optional*  <br>*read-only*|Version of the schema used for validating this event. This is enriched upon reception.<br>This string uses semantic versioning, which is better defined in the `EventTypeSchema` object.|string|


<a name="eventstreambatch"></a>
### EventStreamBatch
One chunk of events in a stream. A batch consists of an array of `Event`s plus a `Cursor`
pointing to the offset of the last Event in the stream.

The size of the array of Event is limited by the parameters used to initialize a Stream.

If acting as a keep alive message (see `GET /event-type/{name}/events`) the events array will
be omitted.

Sequential batches might present repeated cursors if no new events have arrived.


|Name|Schema|
|---|---|
|**cursor**  <br>*required*|[Cursor](definitions.md#cursor)|
|**events**  <br>*optional*|< [Event](definitions.md#event) > array|
|**info**  <br>*optional*|[StreamInfo](definitions.md#streaminfo)|


<a name="eventtype"></a>
### EventType
An event type defines the schema and its runtime properties.


|Name|Description|Schema|
|---|---|---|
|**authorization**  <br>*optional*||[EventTypeAuthorization](definitions.md#eventtypeauthorization)|
|**category**  <br>*required*|Defines the category of this EventType.<br><br>The value set will influence, if not set otherwise, the default set of<br>validations, enrichment-strategies, and the effective schema for validation in<br>the following way:<br><br>- `undefined`: No predefined changes apply. The effective schema for the validation is<br>  exactly the same as the `EventTypeSchema`.<br><br>- `data`: Events of this category will be DataChangeEvents. The effective schema during<br>  the validation contains `metadata`, and adds fields `data_op` and `data_type`. The<br>  passed EventTypeSchema defines the schema of `data`.<br><br>- `business`: Events of this category will be BusinessEvents. The effective schema for<br>  validation contains `metadata` and any additionally defined properties passed in the<br>  `EventTypeSchema` directly on top level of the Event. If name conflicts arise, creation<br>  of this EventType will be rejected.|enum (undefined, data, business)|
|**compatibility_mode**  <br>*optional*|Compatibility mode provides a mean for event owners to evolve their schema, given changes respect the<br>semantics defined by this field.<br><br>It's designed to be flexible enough so that producers can evolve their schemas while not<br>inadvertently breaking existent consumers.<br><br>Once defined, the compatibility mode is fixed, since otherwise it would break a predefined contract,<br>declared by the producer.<br><br>List of compatibility modes:<br><br>- 'compatible': Consumers can reliably parse events produced under different versions. Every event published<br>  since the first version is still valid based on the newest schema. When in compatible mode, it's allowed to<br>  add new optional properties and definitions to an existing schema, but no other changes are allowed.<br>  Under this mode, the following json-schema attributes are not supported: `not`, `patternProperties`,<br>  `additionalProperties` and `additionalItems`. When validating events, additional properties is `false`.<br><br>- 'forward': Compatible schema changes are allowed. It's possible to use the full json schema specification<br>  for defining schemas. Consumers of forward compatible event types can safely read events tagged with the<br>  latest schema version as long as they follow the robustness principle.<br><br>- 'none': Any schema modification is accepted, even if it might break existing producers or consumers. When<br>  validating events, no additional properties are accepted unless explicitly stated in the schema.  <br>**Default** : `"forward"`|string|
|**created_at**  <br>*optional*|Date and time when this event type was created.  <br>**Pattern** : `"date-time"`|string|
|**default_statistic**  <br>*optional*||[EventTypeStatistics](definitions.md#eventtypestatistics)|
|**enrichment_strategies**  <br>*optional*|Determines the enrichment to be performed on an Event upon reception. Enrichment is<br>performed once upon reception (and after validation) of an Event and is only possible on<br>fields that are not defined on the incoming Event.<br><br>For event types in categories 'business' or 'data' it's mandatory to use<br>metadata_enrichment strategy. For 'undefined' event types it's not possible to use this<br>strategy, since metadata field is not required.<br><br>See documentation for the write operation for details on behaviour in case of unsuccessful<br>enrichment.|< enum (metadata_enrichment) > array|
|**name**  <br>*required*|Name of this EventType. The name is constrained by a regular expression.<br><br>Note: the name can encode the owner/responsible for this EventType and ideally should<br>follow a common pattern that makes it easy to read and understand, but this level of<br>structure is not enforced. For example a team name and data type can be used such as<br>'acme-team.price-change'.  <br>**Pattern** : `"[a-zA-Z][-0-9a-zA-Z_]*(\\.[a-zA-Z][-0-9a-zA-Z_]*)*"`  <br>**Example** : `"order.order_cancelled, acme-platform.users"`|string|
|**options**  <br>*optional*||[EventTypeOptions](definitions.md#eventtypeoptions)|
|**owning_application**  <br>*required*|Indicator of the (Stups) Application owning this `EventType`.  <br>**Example** : `"price-service"`|string|
|**partition_key_fields**  <br>*optional*|Required when 'partition_resolution_strategy' is set to 'hash'. Must be absent otherwise.<br>Indicates the fields used for evaluation the partition of Events of this type.<br><br>If this is set it MUST be a valid required field as defined in the schema.|< string > array|
|**partition_strategy**  <br>*optional*|Determines how the assignment of the event to a partition should be handled.<br><br>For details of possible values, see GET /registry/partition-strategies.  <br>**Default** : `"random"`|string|
|**read_scopes**  <br>*optional*|This field is used for event consuming access control. Nakadi only authorises consumers whose session<br>contains at least one of the scopes in this list.<br>If no scopes provided then anyone can consume from this event type.<br><br>Usage of read_scopes is deprecated.|< string > array|
|**schema**  <br>*required*||[EventTypeSchema](definitions.md#eventtypeschema)|
|**updated_at**  <br>*optional*|Date and time when this event type was last updated.  <br>**Pattern** : `"date-time"`|string|
|**write_scopes**  <br>*optional*|This field is used for event publishing access control. Nakadi only authorises publishers whose session<br>contains at least one of the scopes in this list.<br>If no scopes provided then anyone can publish to this event type.<br><br>Usage of write_scopes is deprecated.|< string > array|


<a name="eventtypeauthorization"></a>
### EventTypeAuthorization
Authorization section for an event type. This section defines three access control lists: one for producing
events ('writers'), one for consuming events ('readers'), and one for administering an event type ('admins').
Regardless of the values of the authorization properties, administrator accounts will always be authorized.


|Name|Description|Schema|
|---|---|---|
|**admins**  <br>*required*|An array of subject attributes that are required for updating the event type. Any one of the attributes<br>defined in this array is sufficient to be authorized. The wildcard item takes precedence over all others,<br>i.e. if it is present, all users are authorized.|< [AuthorizationAttribute](definitions.md#authorizationattribute) > array|
|**readers**  <br>*required*|An array of subject attributes that are required for reading events from the event type. Any one of the<br>attributes defined in this array is sufficient to be authorized. The wildcard item takes precedence over<br>all others, i.e., if it is present, all users are authorized.|< [AuthorizationAttribute](definitions.md#authorizationattribute) > array|
|**writers**  <br>*required*|An array of subject attributes that are required for writing events to the event type. Any one of the<br>attributes defined in this array is sufficient to be authorized.|< [AuthorizationAttribute](definitions.md#authorizationattribute) > array|


<a name="eventtypeoptions"></a>
### EventTypeOptions
Additional parameters for tuning internal behavior of Nakadi.


|Name|Description|Schema|
|---|---|---|
|**retention_time**  <br>*optional*|Number of milliseconds that Nakadi stores events published to this event type.  <br>**Default** : `345600000`|integer (int64)|


<a name="eventtypeschema"></a>
### EventTypeSchema
The most recent schema for this EventType. Submitted events will be validated against it.


|Name|Description|Schema|
|---|---|---|
|**created_at**  <br>*optional*  <br>*read-only*|Creation timestamp of the schema. This is generated by Nakadi. It should not be<br>specified when updating a schema and sending it may result in a client error.  <br>**Example** : `"1996-12-19T16:39:57-08:00"`|string (date-time)|
|**schema**  <br>*required*|The schema as string in the syntax defined in the field type. Failure to respect the<br>syntax will fail any operation on an EventType.|string|
|**type**  <br>*required*|The type of schema definition. Currently only json_schema (JSON Schema v04) is supported, but in the<br>future there could be others.|enum (json_schema)|
|**version**  <br>*optional*  <br>*read-only*|This field is automatically generated by Nakadi. Values are based on semantic versioning. Changes to `title`<br>or `description` are considered PATCH level changes. Adding new optional fields is considered a MINOR level<br>change. All other changes are considered MAJOR level.  <br>**Default** : `"1.0.0"`|string|


<a name="eventtypestatistics"></a>
### EventTypeStatistics
Operational statistics for an EventType. This data may be provided by users on Event Type
creation. Nakadi uses this object in order to provide an optimal number of partitions from a throughput perspective.


|Name|Description|Schema|
|---|---|---|
|**message_size**  <br>*required*|Average message size for each Event of this EventType. Includes in the count the whole serialized<br>form of the event, including metadata.<br>Measured in bytes.|integer|
|**messages_per_minute**  <br>*required*|Write rate for events of this EventType. This rate encompasses all producers of this<br>EventType for a Nakadi cluster.<br><br>Measured in event count per minute.|integer|
|**read_parallelism**  <br>*required*|Amount of parallel readers (consumers) to this EventType.|integer|
|**write_parallelism**  <br>*required*|Amount of parallel writers (producers) to this EventType.|integer|


<a name="feature"></a>
### Feature
Feature of Nakadi to be enabled or disabled


|Name|Schema|
|---|---|
|**enabled**  <br>*required*|boolean|
|**feature**  <br>*required*|string|


<a name="metrics"></a>
### Metrics
Object containing application metrics.

*Type* : object


<a name="paginationlink"></a>
### PaginationLink
URI identifying another page of items


|Name|Description|Schema|
|---|---|---|
|**href**  <br>*optional*|**Example** : `"/subscriptions?offset=20&limit=10"`|string (uri)|


<a name="paginationlinks"></a>
### PaginationLinks
contains links to previous and next pages of items


|Name|Schema|
|---|---|
|**next**  <br>*optional*|[PaginationLink](definitions.md#paginationlink)|
|**prev**  <br>*optional*|[PaginationLink](definitions.md#paginationlink)|


<a name="partition"></a>
### Partition
Partition information. Can be helpful when trying to start a stream using an unmanaged API.

This information is not related to the state of the consumer clients.


|Name|Description|Schema|
|---|---|---|
|**newest_available_offset**  <br>*required*|An offset of the newest available Event in that partition. This value will be changing<br>upon reception of new events for this partition by Nakadi.<br><br>This value can be used to construct a cursor when opening streams (see<br>`GET /event-type/{name}/events` for details).<br><br>Might assume the special name BEGIN, meaning a pointer to the offset of the oldest<br>available event in the partition.|string|
|**oldest_available_offset**  <br>*required*|An offset of the oldest available Event in that partition. This value will be changing<br>upon removal of Events from the partition by the background archiving/cleanup mechanism.|string|
|**partition**  <br>*required*||string|
|**unconsumed_events**  <br>*optional*|Approximate number of events unconsumed by the client. This is also known as consumer lag and is used for<br>monitoring purposes by consumers interested in keeping an eye on the number of unconsumed events.|number (int64)|


<a name="problem"></a>
### Problem

|Name|Description|Schema|
|---|---|---|
|**detail**  <br>*optional*|A human readable explanation specific to this occurrence of the problem.  <br>**Example** : `"Connection to database timed out"`|string|
|**instance**  <br>*optional*|An absolute URI that identifies the specific occurrence of the problem.<br>It may or may not yield further information if dereferenced.|string (uri)|
|**status**  <br>*required*|The HTTP status code generated by the origin server for this occurrence of the problem.  <br>**Example** : `503`|integer (int32)|
|**title**  <br>*required*|A short, summary of the problem type. Written in English and readable for engineers<br>(usually not suited for non technical stakeholders and not localized)  <br>**Example** : `"Service Unavailable"`|string|
|**type**  <br>*required*|An absolute URI that identifies the problem type.  When dereferenced, it SHOULD provide<br>human-readable API documentation for the problem type (e.g., using HTML).  This Problem<br>object is the same as provided by https://github.com/zalando/problem  <br>**Example** : `"http://httpstatus.es/503"`|string (uri)|


<a name="shiftedcursor"></a>
### ShiftedCursor
*Polymorphism* : Composition


|Name|Description|Schema|
|---|---|---|
|**offset**  <br>*required*|Offset of the event being pointed to.|string|
|**partition**  <br>*required*|Id of the partition pointed to by this cursor.|string|
|**shift**  <br>*required*|This number is a modifier for the offset. It moves the cursor forward or backwards by the number of events<br>provided.<br>For example, suppose a user wants to read events starting 100 positions before offset<br>"001-000D-0000000000000009A8", it's possible to specify `shift` with -100 and Nakadi will make the<br>necessary calculations to move the cursor backwards relatively to the given `offset`.<br><br>Users should use this feature only for debugging purposes. Users should favor using cursors provided in<br>batches when streaming from Nakadi. Navigating in the stream using shifts is provided only for<br>debugging purposes.|number (int64)|


<a name="storage"></a>
### Storage
A storage backend.


|Name|Description|Schema|
|---|---|---|
|**id**  <br>*required*|The ID of the storage backend.  <br>**Maximal length** : `36`|string|
|**kafka_configuration**  <br>*required*|configuration settings for kafka storage. Only necessary if the storage type is 'kafka'|[kafka_configuration](#storage-kafka_configuration)|
|**storage_type**  <br>*required*|the type of storage. Possible values: ['kafka']|string|

<a name="storage-kafka_configuration"></a>
**kafka_configuration**

|Name|Description|Schema|
|---|---|---|
|**exhibitor_address**  <br>*optional*|the Zookeeper address|string|
|**exhibitor_port**  <br>*optional*|the Zookeeper path|string|
|**zk_address**  <br>*optional*|the Zookeeper address|string|
|**zk_path**  <br>*optional*|the Zookeeper path|string|


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
|**consumer_group**  <br>*optional*|The value describing the use case of this subscription.<br>In general that is an additional identifier used to differ subscriptions having the same<br>owning_application and event_types.  <br>**Default** : `"default"`  <br>**Minimum length** : `1`  <br>**Example** : `"read-product-updates"`|string|
|**created_at**  <br>*optional*  <br>*read-only*|Timestamp of creation of the subscription. This is generated by Nakadi. It should not be<br>specified when creating subscription and sending it may result in a client error.  <br>**Example** : `"1996-12-19T16:39:57-08:00"`|string (date-time)|
|**event_types**  <br>*required*|EventTypes to subscribe to.<br>The order is not important. Subscriptions that differ only by the order of EventTypes will be<br>considered the same and will have the same id. The size of event_types list is limited by total number<br>of partitions within these event types. Default limit for partition count is 100.|< string > array|
|**id**  <br>*optional*  <br>*read-only*|Id of subscription that was created. Is generated by Nakadi, should not be specified when creating<br>subscription.|string|
|**initial_cursors**  <br>*optional*|List of cursors to start reading from. This property is required when `read_from` = `cursors`.<br>The initial cursors should cover all partitions of subscription.|< [SubscriptionCursorWithoutToken](definitions.md#subscriptioncursorwithouttoken) > array|
|**owning_application**  <br>*required*|The id of application owning the subscription.  <br>**Minimum length** : `1`  <br>**Example** : `"gizig"`|string|
|**read_from**  <br>*optional*|Position to start reading events from. Currently supported values:<br>- `begin` - read from the oldest available event.<br>- `end` - read from the most recent offset.<br>- `cursors` - read from cursors provided in `initial_cursors` property.<br>Applied when the client starts reading from a subscription.  <br>**Default** : `"end"`|string|


<a name="subscriptioncursor"></a>
### SubscriptionCursor
*Polymorphism* : Composition


|Name|Description|Schema|
|---|---|---|
|**cursor_token**  <br>*required*|An opaque value defined by the server.|string|
|**event_type**  <br>*required*|The name of the event type this partition's events belong to.|string|
|**offset**  <br>*required*|Offset of the event being pointed to.|string|
|**partition**  <br>*required*|Id of the partition pointed to by this cursor.|string|


<a name="subscriptioncursorwithouttoken"></a>
### SubscriptionCursorWithoutToken
*Polymorphism* : Composition


|Name|Description|Schema|
|---|---|---|
|**event_type**  <br>*required*|The name of the event type this partition's events belong to.|string|
|**offset**  <br>*required*|Offset of the event being pointed to.|string|
|**partition**  <br>*required*|Id of the partition pointed to by this cursor.|string|


<a name="subscriptioneventstreambatch"></a>
### SubscriptionEventStreamBatch
Analogue to EventStreamBatch but used for high level streamming. It includes specific cursors
for committing in the high level API.


|Name|Schema|
|---|---|
|**cursor**  <br>*required*|[SubscriptionCursor](definitions.md#subscriptioncursor)|
|**events**  <br>*optional*|< [Event](definitions.md#event) > array|
|**info**  <br>*optional*|[StreamInfo](definitions.md#streaminfo)|


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
|**partition**  <br>*required*||string|
|**state**  <br>*required*|The state of this partition in current subscription. Currently following values are possible:<br>- `unassigned`: the partition is currently not assigned to any client;<br>- `reassigning`: the partition is currently reasssigning from one client to another;<br>- `assigned`: the partition is assigned to a client.|string|
|**stream_id**  <br>*optional*|the id of the stream that consumes data from this partition|string|
|**unconsumed_events**  <br>*optional*|The amount of events in this partition that are not yet consumed within this subscription.<br>The property may be absent at the moment when no events were yet consumed from the partition in this<br>subscription (In case of `read_from` is `BEGIN` or `END`)|number|



