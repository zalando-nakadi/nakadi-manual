
## Resources

  - [GET /event-types](#get-event-types)
  - [POST /event-types](#post-event-types)
  - [GET /event-types/{name}](#get-event-typesname)
  - [PUT /event-types/{name}](#put-event-typesname)
  - [DELETE /event-types/{name}](#delete-event-typesname)
  - [POST /event-types/{name}/cursor-distances](#post-event-typesnamecursor-distances)
  - [POST /event-types/{name}/cursors-lag](#post-event-typesnamecursors-lag)
  - [POST /event-types/{name}/events](#post-event-typesnameevents)
  - [GET /event-types/{name}/events](#get-event-typesnameevents)
  - [GET /event-types/{name}/partitions](#get-event-typesnamepartitions)
  - [GET /event-types/{name}/partitions/{partition}](#get-event-typesnamepartitionspartition)
  - [GET /event-types/{name}/schemas](#get-event-typesnameschemas)
  - [GET /event-types/{name}/schemas/{version}](#get-event-typesnameschemasversion)
  - [POST /event-types/{name}/shifted-cursors](#post-event-typesnameshifted-cursors)
  - [POST /event-types/{name}/timelines](#post-event-typesnametimelines)
  - [GET /event-types/{name}/timelines](#get-event-typesnametimelines)
  - [DELETE /event-types/{name}/timelines/{id}](#delete-event-typesnametimelinesid)
  - [GET /metrics](#get-metrics)
  - [GET /registry/enrichment-strategies](#get-registryenrichment-strategies)
  - [GET /registry/partition-strategies](#get-registrypartition-strategies)
  - [GET /settings/blacklist](#get-settingsblacklist)
  - [PUT /settings/blacklist/{blacklist_type}/{name}](#put-settingsblacklistblacklisttypename)
  - [DELETE /settings/blacklist/{blacklist_type}/{name}](#delete-settingsblacklistblacklisttypename)
  - [GET /settings/features](#get-settingsfeatures)
  - [POST /settings/features](#post-settingsfeatures)
  - [GET /storages](#get-storages)
  - [POST /storages](#post-storages)
  - [GET /storages/{id}](#get-storagesid)
  - [DELETE /storages/{id}](#delete-storagesid)
  - [POST /subscriptions](#post-subscriptions)
  - [GET /subscriptions](#get-subscriptions)
  - [GET /subscriptions/{subscription_id}](#get-subscriptionssubscriptionid)
  - [DELETE /subscriptions/{subscription_id}](#delete-subscriptionssubscriptionid)
  - [GET /subscriptions/{subscription_id}/cursors](#get-subscriptionssubscriptionidcursors)
  - [POST /subscriptions/{subscription_id}/cursors](#post-subscriptionssubscriptionidcursors)
  - [PATCH /subscriptions/{subscription_id}/cursors](#patch-subscriptionssubscriptionidcursors)
  - [GET /subscriptions/{subscription_id}/events](#get-subscriptionssubscriptionidevents)
  - [GET /subscriptions/{subscription_id}/stats](#get-subscriptionssubscriptionidstats)


<a name="paths"></a>
## Paths

<a name="event-types-post"></a>
### POST /event-types

#### Description
Creates a new `EventType`.

The fields enrichment-strategies and partition-resolution-strategy
have all an effect on the incoming Event of this EventType. For its impacts on the reception
of events please consult the Event submission API methods.

* Validation strategies define an array of validation stategies to be evaluated on reception
of an `Event` of this `EventType`. Details of usage can be found in this external document

  - http://zalando.github.io/nakadi-manual/

* Enrichment strategy. (todo: define this part of the API).

* The schema of an `EventType` is defined as an `EventTypeSchema`. Currently only
the value `json-schema` is supported, representing JSON Schema draft 04.

Following conditions are enforced. Not meeting them will fail the request with the indicated
status (details are provided in the Problem object):

* EventType name on creation must be unique (or attempting to update an `EventType` with
  this method), otherwise the request is rejected with status 409 Conflict.

* Using `EventTypeSchema.type` other than json-schema or passing a `EventTypeSchema.schema`
that is invalid with respect to the schema's type. Rejects with 422 Unprocessable entity.

* Referring any Enrichment or Partition strategies that do not exist or
whose parametrization is deemed invalid. Rejects with 422 Unprocessable entity.

Nakadi MIGHT impose necessary schema, validation and enrichment minimal configurations that
MUST be followed by all EventTypes (examples include: validation rules to match the schema;
enriching every Event with the reception date-type; adhering to a set of schema fields that
are mandatory for all EventTypes). **The mechanism to set and inspect such rules is not
defined at this time and might not be exposed in the API.**


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**event-type**  <br>*required*|EventType to be created|[EventType](definitions.md#eventtype)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**201**|Created|No Content|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**409**|Conflict, for example on creation of EventType with already existing name.|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_type.write|


<a name="event-types-get"></a>
### GET /event-types

#### Description
Returns a list of all registered `EventType`s


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|< [EventType](definitions.md#eventtype) > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


<a name="event-types-name-get"></a>
### GET /event-types/{name}

#### Description
Returns the `EventType` identified by its name.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|Name of the EventType to load.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|[EventType](definitions.md#eventtype)|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


<a name="event-types-name-put"></a>
### PUT /event-types/{name}

#### Description
Updates the `EventType` identified by its name. Behaviour is the same as creation of
`EventType` (See POST /event-type) except where noted below.

The name field cannot be changed. Attempting to do so will result in a 422 failure.

Modifications to the schema are constrained by the specified `compatibility_mode`.

Updating the `EventType` is only allowed for clients that satisfy the authorization `admin` requirements,
if it exists.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|Name of the EventType to update.|string|
|**Body**|**event-type**  <br>*required*|EventType to be updated.|[EventType](definitions.md#eventtype)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|No Content|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**403**|Access forbidden|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_type.write|


<a name="event-types-name-delete"></a>
### DELETE /event-types/{name}

#### Description
Deletes an `EventType` identified by its name. All events in the `EventType`'s stream' will
also be removed. **Note**: deletion happens asynchronously, which has the following
consequences:

 * Creation of an equally named `EventType` before the underlying topic deletion is complete
 might not succeed (failure is a 409 Conflict).

 * Events in the stream may be visible for a short period of time before being removed.

 Depending on the Nakadi configuration, the oauth resource owner username may have to be equal to
 'nakadi.oauth2.adminClientId' property to be able to access this endpoint.

 Updating the `EventType` is only allowed for clients that satisfy the authorization `admin` requirements,
 if it exists.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|Name of the EventType to delete.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|EventType is successfuly removed|No Content|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**403**|Access forbidden|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.config.write|


<a name="event-types-name-cursor-distances-post"></a>
### POST /event-types/{name}/cursor-distances

#### Description
GET with payload.

Calculate the distance between two offsets. This is useful for performing checks for data completeness, when
a client has read some batches and wants to be sure that all delivered events have been correctly processed.

If per-EventType authorization is enabled, the caller must be authorized to read from the EventType.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**name**  <br>*required*|Name of the EventType|string|
|**Body**|**cursors-distances-query**  <br>*required*|List of pairs of cursors: `initial_cursor` and `final_cursor`. Used as input by Nakadi to<br>calculate how many events there are between two cursors. The distance doesn't include the `initial_cursor`<br>but includes the `final_cursor`. So if they are equal the result is zero.|< [CursorDistanceQuery](definitions.md#cursordistancequery) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|< [CursorDistanceResult](definitions.md#cursordistanceresult) > array|
|**403**|Access forbidden because of missing scope or EventType authorization failure.|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|


#### Tags

* management-api
* monitoring
* unmanaged-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="event-types-name-cursors-lag-post"></a>
### POST /event-types/{name}/cursors-lag

#### Description
GET with payload.

This endpoint is mostly interesting for monitoring purposes. Used when a consumer wants to know how far behind
in the stream its application is lagging.

It provides the number of unconsumed events for each cursor's partition.

If per-EventType authorization is enabled, the caller must be authorized to read from the EventType.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|EventType name|string|
|**Body**|**cursors**  <br>*required*|Each cursor indicates the partition and offset consumed by the client. When a cursor is provided,<br>Nakadi calculates the consumer lag, e.g. the number of events between the provided offset and the most<br>recent published event. This lag will be present in the response as `unconsumed_events` property.<br><br>It's not mandatory to specify cursors for every partition.<br><br>The lag calculation is non inclusive, e.g. if the provided offset is the offset of the latest published<br>event, the number of `unconsumed_events` will be zero.<br><br>All provided cursors must be valid, i.e. a non expired cursor of an event in the stream.|< [Cursor](definitions.md#cursor) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|< [Partition](definitions.md#partition) > array|
|**403**|Access forbidden because of missing scope or EventType authorization failure.|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|


#### Tags

* management-api
* monitoring
* unmanaged-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="event-types-name-events-post"></a>
### POST /event-types/{name}/events

#### Description
Publishes a batch of `Event`s of this `EventType`. All items must be of the EventType
identified by `name`.

Reception of Events will always respect the configuration of its `EventType` with respect to
validation, enrichment and partition. The steps performed on reception of incoming message
are:

1. Every validation rule specified for the `EventType` will be checked in order against the
incoming Events. Validation rules are evaluated in the order they are defined and the Event
is **rejected** in the first case of failure. If the offending validation rule provides
information about the violation it will be included in the `BatchItemResponse`.  If the
`EventType` defines schema validation it will be performed at this moment. The size of each
Event will also be validated. The maximum size per Event is 999,000 bytes. We use the batch
input to measure the size of events, so unnecessary spaces, tabs, and carriage returns will
count towards the event size.

1. Once the validation succeeded, the content of the Event is updated according to the
enrichment rules in the order the rules are defined in the `EventType`.  No preexisting
value might be changed (even if added by an enrichment rule). Violations on this will force
the immediate **rejection** of the Event. The invalid overwrite attempt will be included in
the item's `BatchItemResponse` object.

1. The incoming Event's relative ordering is evaluated according to the rule on the
`EventType`. Failure to evaluate the rule will **reject** the Event.

Given the batched nature of this operation, any violation on validation or failures on
enrichment or partitioning will cause the whole batch to be rejected, i.e. none of its
elements are pushed to the underlying broker.

Failures on writing of specific partitions to the broker might influence other
partitions. Failures at this stage will fail only the affected partitions.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|Name of the EventType|string|
|**Body**|**event**  <br>*required*|The Event being published|< [Event](definitions.md#event) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|All events in the batch have been successfully published.|No Content|
|**207**|At least one event has failed to be submitted. The batch might be partially submitted.|< [BatchItemResponse](definitions.md#batchitemresponse) > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**403**|Access is forbidden for the client or event type|[Problem](definitions.md#problem)|
|**422**|At least one event failed to be validated, enriched or partitioned. None were submitted.|< [BatchItemResponse](definitions.md#batchitemresponse) > array|


#### Tags

* stream-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.write|


<a name="event-types-name-events-get"></a>
### GET /event-types/{name}/events

#### Description
Starts a stream delivery for the specified partitions of the given EventType.

The event stream is formatted as a sequence of `EventStreamBatch`es separated by `\n`. Each
`EventStreamBatch` contains a chunk of Events and a `Cursor` pointing to the **end** of the
chunk (i.e. last delivered Event). The cursor might specify the offset with the symbolic
value `BEGIN`, which will open the stream starting from the oldest available offset in the
partition.

Currently the `application/x-json-stream` format is the only one supported by the system,
but in the future other media types may be supported.

If streaming for several distinct partitions, each one is an independent `EventStreamBatch`.

The initialization of a stream can be parameterized in terms of size of each chunk, timeout
for flushing each chunk, total amount of delivered Events and total time for the duration of
the stream.

Nakadi will keep a streaming connection open even if there are no events to be delivered. In
this case the timeout for the flushing of each chunk will still apply and the
`EventStreamBatch` will contain only the Cursor pointing to the same offset. This can be
treated as a keep-alive control for some load balancers.

The tracking of the current offset in the partitions and of which partitions is being read
is in the responsibility of the client. No commits are needed.


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Header**|**X-nakadi-cursors**  <br>*optional*|Cursors indicating the partitions to read from and respective starting offsets.<br><br>Assumes the offset on each cursor is not inclusive (i.e., first delivered Event is the<br>**first one after** the one pointed to in the cursor).<br><br>If the header is not present, the stream for all partitions defined for the EventType<br>will start from the newest event available in the system at the moment of making this<br>call.<br><br>**Note:** we are not using query parameters for passing the cursors only because of the<br>length limitations on the HTTP query. Another way to initiate this call would be the<br>POST method with cursors passed in the method body. This approach can implemented in the<br>future versions of this API.|< string (#/definitions/Cursor) > array||
|**Path**|**name**  <br>*required*|EventType name to get events about|string||
|**Query**|**batch_flush_timeout**  <br>*optional*|Maximum time in seconds to wait for the flushing of each chunk (per partition).<br><br>* If the amount of buffered Events reaches `batch_limit` before this `batch_flush_timeout`<br>is reached, the messages are immediately flushed to the client and batch flush timer is reset.<br><br>* If 0 or undefined, will assume 30 seconds.|number (int32)|`30`|
|**Query**|**batch_limit**  <br>*optional*|Maximum number of `Event`s in each chunk (and therefore per partition) of the stream.|integer (int32)|`1`|
|**Query**|**stream_keep_alive_limit**  <br>*optional*|Maximum number of empty keep alive batches to get in a row before closing the connection.<br><br>If 0 or undefined will send keep alive messages indefinitely.|integer (int32)|`0`|
|**Query**|**stream_limit**  <br>*optional*|Maximum number of `Event`s in this stream (over all partitions being streamed in this<br>connection).<br><br>* If 0 or undefined, will stream batches indefinitely.<br><br>* Stream initialization will fail if `stream_limit` is lower than `batch_limit`.|integer (int32)|`0`|
|**Query**|**stream_timeout**  <br>*optional*|Maximum time in seconds a stream will live before connection is closed by the server.<br>If 0 or unspecified will stream indefinitely.<br><br>If this timeout is reached, any pending messages (in the sense of `stream_limit`) will be flushed<br>to the client.<br><br>Stream initialization will fail if `stream_timeout` is lower than `batch_flush_timeout`.|number (int32)|`0`|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Starts streaming to the client.<br>Stream format is a continuous series of `EventStreamBatch`s separated by `\n`|[EventStreamBatch](definitions.md#eventstreambatch)|
|**401**|Not authenticated|[Problem](definitions.md#problem)|
|**403**|Access is forbidden for the client or event type|[Problem](definitions.md#problem)|
|**422**|Unprocessable entity|[Problem](definitions.md#problem)|
|**429**|Too Many Requests. The client reached the maximum amount of simultaneous connections to a single partition|[Problem](definitions.md#problem)|


#### Produces

* `application/x-json-stream`


#### Tags

* stream-api
* unmanaged-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="event-types-name-partitions-get"></a>
### GET /event-types/{name}/partitions

#### Description
Lists the `Partition`s for the given event-type.

This endpoint is mostly interesting for monitoring purposes or in cases when consumer wants
to start consuming older messages.
If per-EventType authorization is enabled, the caller must be authorized to read from the EventType.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|EventType name|string|
|**Query**|**cursors**  <br>*optional*|Each cursor indicates the partition and offset consumed by the client. When this parameter is provided,<br>Nakadi calculates the consumer lag, e.g. the number of events between the provided offset and the most<br>recent published event. This lag will be present in the response as `unconsumed_events` property.<br><br>It's not mandatory to specify cursors for every partition.<br><br>The lag calculation is non inclusive, e.g. if the provided offset is the offset of the latest published<br>event, the number of `unconsumed_events` will be zero.<br><br>The value of this parameter must be a json array URL encoded.|< string (#/definitions/Cursor) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|< [Partition](definitions.md#partition) > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**403**|Access forbidden because of missing scope or EventType authorization failure.|[Problem](definitions.md#problem)|


#### Tags

* management-api
* monitoring
* unmanaged-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="event-types-name-partitions-partition-get"></a>
### GET /event-types/{name}/partitions/{partition}

#### Description
Returns the given `Partition` of this EventType. If per-EventType authorization is enabled, the caller must
be authorized to read from the EventType.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|EventType name|string|
|**Path**|**partition**  <br>*required*|Partition id|string|
|**Query**|**consumed_offset**  <br>*optional*|Offset to query for unconsumed events. Depends on `partition` parameter. When present adds the property<br>`unconsumed_events` to the response partition object.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Partition](definitions.md#partition)|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**403**|Access forbidden because of missing scope or EventType authorization failure.|[Problem](definitions.md#problem)|


#### Tags

* management-api
* unmanaged-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="event-types-name-schemas-get"></a>
### GET /event-types/{name}/schemas

#### Description
List of schemas ordered from most recent to oldest.


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Path**|**name**  <br>*required*|EventType name|string||
|**Query**|**limit**  <br>*optional*|maximum number of schemas retuned in one page|integer (int64)|`20`|
|**Query**|**offset**  <br>*optional*|page offset|integer (int64)|`0`|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Response 200](#event-types-name-schemas-get-response-200)|

<a name="event-types-name-schemas-get-response-200"></a>
**Response 200**

|Name|Description|Schema|
|---|---|---|
|**_links**  <br>*required*||[PaginationLinks](definitions.md#paginationlinks)|
|**items**  <br>*required*|list of schemas.|< [EventTypeSchema](definitions.md#eventtypeschema) > array|


#### Tags

* schema-registry-api


<a name="event-types-name-schemas-version-get"></a>
### GET /event-types/{name}/schemas/{version}

#### Description
Retrieves a given schema version. A special `{version}` key named 'latest' is provided for
convenience.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**name**  <br>*required*|EventType name|string|
|**Path**|**version**  <br>*required*|EventType schema version|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Schema object.|[EventTypeSchema](definitions.md#eventtypeschema)|


#### Tags

* schema-registry-api


<a name="event-types-name-shifted-cursors-post"></a>
### POST /event-types/{name}/shifted-cursors

#### Description
Transforms a list of Cursors with `shift` into a list without `shift`s. This is useful when there is the need
for randomly access events in the stream.
If per-EventType authorization is enabled, the caller must be authorized to read from the EventType.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string|
|**Path**|**name**  <br>*required*|EventType name|string|
|**Body**|**cursors**  <br>*required*|GET with payload.<br><br>Cursors indicating the positions to be calculated. Given a initial cursor, with partition and offset, it's<br>possible to obtain another cursor that is relatively forward or backward to it. When `shift` is positive,<br>Nakadi will respond with a cursor that in forward `shif` positions based on the initial `partition` and<br>`offset`. In case `shift` is negative, Nakadi will move the cursor backward.<br><br>Note: It's not currently possible to shift cursors based on time. It's only possible to shift cursors<br>based on the number of events to forward of backward given by `shift`.|< [ShiftedCursor](definitions.md#shiftedcursor) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|< [Cursor](definitions.md#cursor) > array|
|**403**|Access forbidden because of missing scope or EventType authorization failure.|[Problem](definitions.md#problem)|
|**422**|It's only possible to navigate from a valid cursor to another valid cursor, i.e. `partition`s and<br>`offset`s must exist and not be expired. Any combination of parameters that might break this rule will<br>result in 422. For example:<br><br>- if the initial `partition` and `offset` are expired.<br>- if the `shift` provided leads to a already expired cursor.<br>- if the `shift` provided leads to a cursor that is not yet existent, i.e. it's pointing to<br>some cursor yet to be generated in the future.|[Problem](definitions.md#problem)|


#### Tags

* management-api
* monitoring
* unmanaged-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="event-types-name-timelines-post"></a>
### POST /event-types/{name}/timelines

#### Description
Creates a new timeline for an event type and makes it active.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**name**  <br>*required*|Name of the EventType|string|
|**Body**|**timeline_request**  <br>*required*||[timeline_request](#event-types-name-timelines-post-timeline_request)|

<a name="event-types-name-timelines-post-timeline_request"></a>
**timeline_request**

|Name|Schema|
|---|---|
|**storage_id**  <br>*required*|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**201**|New timeline is created and in use|No Content|
|**403**|Access forbidden|[Problem](definitions.md#problem)|
|**404**|No such event type|[Problem](definitions.md#problem)|
|**422**|Unprocessable entity due to non existing storage|[Problem](definitions.md#problem)|


#### Tags

* timelines-api


<a name="event-types-name-timelines-get"></a>
### GET /event-types/{name}/timelines

#### Description
List timelines for a given event type.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**name**  <br>*required*|Name of the EventType to list timelines for.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|< [Response 200](#event-types-name-timelines-get-response-200) > array|
|**403**|Access forbidden|[Problem](definitions.md#problem)|
|**404**|No such event type|[Problem](definitions.md#problem)|

<a name="event-types-name-timelines-get-response-200"></a>
**Response 200**

|Name|Schema|
|---|---|
|**cleaned_up_at**  <br>*optional*|string (date-time)|
|**created_at**  <br>*optional*|string (date-time)|
|**event_type**  <br>*optional*|string|
|**id**  <br>*optional*|string (uuid)|
|**latest_position**  <br>*optional*|object|
|**order**  <br>*optional*|integer|
|**storage_id**  <br>*optional*|string|
|**switched_at**  <br>*optional*|string (date-time)|
|**topic**  <br>*optional*|string|


#### Tags

* timelines-api


<a name="event-types-name-timelines-id-delete"></a>
### DELETE /event-types/{name}/timelines/{id}

#### Description
Deletes a timeline if there is only one timeline.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**id**  <br>*required*|timeline id|string (uuid)|
|**Path**|**name**  <br>*required*|Name of the EventType.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Timeline was deleted|No Content|
|**403**|Access forbidden|[Problem](definitions.md#problem)|
|**404**|No such event type or timeline id|[Problem](definitions.md#problem)|
|**422**|could not delete timeline, because there is more than one timeline|[Problem](definitions.md#problem)|


#### Tags

* timelines-api


<a name="metrics-get"></a>
### Get monitoring metrics
```
GET /metrics
```


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|[Metrics](definitions.md#metrics)|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


#### Tags

* monitoring


<a name="registry-enrichment-strategies-get"></a>
### GET /registry/enrichment-strategies

#### Description
Lists all of the enrichment strategies supported by this Nakadi installation. Special or
custom strategies besides the defaults will be listed here.


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Returns a list of all enrichment strategies known to Nakadi|< string > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="registry-partition-strategies-get"></a>
### GET /registry/partition-strategies

#### Description
Lists all of the partition resolution strategies supported by this installation of Nakadi.
Special or custom strategies besides the defaults will be listed here.

Nakadi currently offers these inbuilt strategies:

- `random`: Resolution of the target partition happens randomly (events are evenly
  distributed on the topic's partitions).

- `user_defined`: Target partition is defined by the client. As long as the indicated
  partition exists, Event assignment will respect this value. Correctness of the relative
  ordering of events is under the responsibility of the Producer.  Requires that the client
  provides the target partition on `metadata.partition` (See `EventMetadata`). Failure to do
  so will reject the publishing of the Event.

- `hash`: Resolution of the partition follows the computation of a hash from the value of
  the fields indicated in the EventType's `partition_key_fields`, guaranteeing that Events
  with same values on those fields end in the same partition. Given the event type's category
  is DataChangeEvent, field path is considered relative to "data".


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Returns a list of all partitioning strategies known to Nakadi|< string > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="settings-blacklist-get"></a>
### GET /settings/blacklist

#### Description
Lists all blocked producers/consumers divided by app and event type.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Lists all blocked producers/consumers.|[Response 200](#settings-blacklist-get-response-200)|

<a name="settings-blacklist-get-response-200"></a>
**Response 200**

|Name|Description|Schema|
|---|---|---|
|**consumers**  <br>*optional*|a list of all blocked consumers.|[consumers](#settings-blacklist-get-consumers)|
|**producers**  <br>*optional*|a list of all blocked producers.|[producers](#settings-blacklist-get-producers)|

<a name="settings-blacklist-get-consumers"></a>
**consumers**

|Name|Description|Schema|
|---|---|---|
|**apps**  <br>*optional*|a list of all blocked apps for consuming events.|< string > array|
|**event_types**  <br>*optional*|a list of all blocked event types for consuming events.|< string > array|

<a name="settings-blacklist-get-producers"></a>
**producers**

|Name|Description|Schema|
|---|---|---|
|**apps**  <br>*optional*|a list of all blocked apps for publishing events.|< string > array|
|**event_types**  <br>*optional*|a list of all blocked event types for publishing events.|< string > array|


#### Tags

* settings-api


<a name="settings-blacklist-blacklist_type-name-put"></a>
### PUT /settings/blacklist/{blacklist_type}/{name}

#### Description
Blocks publication/consumption for particular app or event type.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**blacklist_type**  <br>*required*|Type of the blacklist to put client into.<br><br>List of available types:<br>- 'CONSUMER_APP': consumer application.<br>- 'CONSUMER_ET': consumer event type.<br>- 'PRODUCER_APP': producer application.<br>- 'PRODUCER_ET': producer event type.|string|
|**Path**|**name**  <br>*required*|Name of the client to block.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**204**|Client or event type was successfully blocked.|No Content|


#### Tags

* settings-api


<a name="settings-blacklist-blacklist_type-name-delete"></a>
### DELETE /settings/blacklist/{blacklist_type}/{name}

#### Description
Unblocks publication/consumption for particular app or event type.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**blacklist_type**  <br>*required*|Type of the blacklist to put client into.<br><br>List of available types:<br>- 'CONSUMER_APP': consumer application.<br>- 'CONSUMER_ET': consumer event type.<br>- 'PRODUCER_APP': producer application.<br>- 'PRODUCER_ET': producer event type.|string|
|**Path**|**name**  <br>*required*|Name of the client to unblock.|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**204**|Client was successfully unblocked.|No Content|


#### Tags

* settings-api


<a name="settings-features-post"></a>
### POST /settings/features

#### Description
Enables or disables feature depends on the payload
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Schema|
|---|---|---|
|**Body**|**feature**  <br>*required*|[Feature](definitions.md#feature)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**204**|Feature was successfully accepted.|No Content|


#### Tags

* settings-api


<a name="settings-features-get"></a>
### GET /settings/features

#### Description
Lists all available features.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|A list of all available features.|[Response 200](#settings-features-get-response-200)|

<a name="settings-features-get-response-200"></a>
**Response 200**

|Name|Description|Schema|
|---|---|---|
|**items**  <br>*required*|list of features.|< [Feature](definitions.md#feature) > array|


#### Tags

* settings-api


<a name="storages-post"></a>
### POST /storages

#### Description
Creates a new storage backend.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**storage**  <br>*optional*|Storage description|[Storage](definitions.md#storage)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**201**|Storage backend was successfully registered. Returns storage object that was created.|[Storage](definitions.md#storage)|
|**403**|Access forbidden|[Problem](definitions.md#problem)|
|**409**|A storage with the same ID already exists|[Problem](definitions.md#problem)|


#### Tags

* timelines-api


<a name="storages-get"></a>
### GET /storages

#### Description
Lists all available storage backends.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|A list of all available storage backends.|< [Storage](definitions.md#storage) > array|
|**403**|Access forbidden|[Problem](definitions.md#problem)|


#### Tags

* timelines-api


<a name="storages-id-get"></a>
### GET /storages/{id}

#### Description
Retrieves a storage backend by its ID.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**id**  <br>*required*|storage backend ID|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Storage](definitions.md#storage)|
|**403**|Access forbidden|[Problem](definitions.md#problem)|
|**404**|Storage backend not found|[Problem](definitions.md#problem)|


#### Tags

* timelines-api


<a name="storages-id-delete"></a>
### DELETE /storages/{id}

#### Description
Deletes a storage backend from its ID, if it is not in use.
The oauth resource owner username has to be equal to 'nakadi.oauth2.adminClientId' property
to be able to access this endpoint.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**id**  <br>*required*|storage backend ID|string|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**204**|Storage backend was deleted|No Content|
|**400**|Storage backend could not be deleted|[Problem](definitions.md#problem)|
|**403**|Access forbidden|[Problem](definitions.md#problem)|
|**404**|Storage backend not found|[Problem](definitions.md#problem)|


#### Tags

* timelines-api


<a name="subscriptions-post"></a>
### POST /subscriptions

#### Description
This endpoint creates a subscription for EventTypes. The subscription is needed to be able to
consume events from EventTypes in a high level way when Nakadi stores the offsets and manages the
rebalancing of consuming clients.
The subscription is identified by its key parameters (owning_application, event_types, consumer_group). If
this endpoint is invoked several times with the same key subscription properties in body (order of even_types is
not important) - the subscription will be created only once and for all other calls it will just return
the subscription that was already created.
If per-EventType authorization is enabled, the caller must be authorized to read from all the EventTypes in the
subscription.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**subscription**  <br>*required*|Subscription to create|[Subscription](definitions.md#subscription)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Subscription for such parameters already exists. Returns subscription object that already<br>existed.  <br>**Headers** :   <br>`Location` (string) : The relative URI for this subscription resource.|[Subscription](definitions.md#subscription)|
|**201**|Subscription was successfuly created. Returns subscription object that was created.  <br>**Headers** :   <br>`Location` (string) : The relative URI for the created resource.  <br>`Content-Location` (string) : If the Content-Location header is present and the same as the Location header the<br>client can assume it has an up to date representation of the Subscription and a<br>corresponding GET request is not needed.|[Subscription](definitions.md#subscription)|
|**400**|Bad Request|[Problem](definitions.md#problem)|
|**403**|Access forbidden because of missing scope or EventType authorization failure.|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-get"></a>
### GET /subscriptions

#### Description
Lists all subscriptions that exist in a system. List is ordered by creation date/time descending (newest
subscriptions come first).


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Query**|**event_type**  <br>*optional*|Parameter to filter subscriptions list by event types. If not specified - the result list will contain<br>subscriptions for all event types. It's possible to provide multiple values like<br>`event_type=et1&event_type=et2`, in this case it will show subscriptions having both `et1` and `et2`|< string > array(multi)||
|**Query**|**limit**  <br>*optional*|maximum number of subscriptions retuned in one page|integer (int64)|`20`|
|**Query**|**offset**  <br>*optional*|page offset|integer (int64)|`0`|
|**Query**|**owning_application**  <br>*optional*|Parameter to filter subscriptions list by owning application. If not specified - the result list will<br>contain subscriptions of all owning applications.|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Response 200](#subscriptions-get-response-200)|
|**400**|Bad Request|[Problem](definitions.md#problem)|

<a name="subscriptions-get-response-200"></a>
**Response 200**

|Name|Description|Schema|
|---|---|---|
|**_links**  <br>*required*||[PaginationLinks](definitions.md#paginationlinks)|
|**items**  <br>*required*|list of subscriptions|< [Subscription](definitions.md#subscription) > array|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-subscription_id-get"></a>
### GET /subscriptions/{subscription_id}

#### Description
Returns a subscription identified by id.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string (uuid)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Subscription](definitions.md#subscription)|
|**404**|Subscription not found|[Problem](definitions.md#problem)|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-subscription_id-delete"></a>
### DELETE /subscriptions/{subscription_id}

#### Description
Deletes a subscription.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string (uuid)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**204**|Subscription was deleted|No Content|
|**404**|Subscription not found|[Problem](definitions.md#problem)|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-subscription_id-cursors-post"></a>
### POST /subscriptions/{subscription_id}/cursors

#### Description
Endpoint for committing offsets of the subscription. If there is uncommited data, and no commits happen
for 60 seconds, then Nakadi will consider the client to be gone, and will close the connection. As long
as no events are sent, the client does not need to commit.

If the connection is closed, the client has 60 seconds to commit the events it received, from the moment
they were sent. After that, the connection will be considered closed, and it will not be possible to do
commit with that `X-Nakadi-StreamId` anymore.

When a batch is committed that also automatically commits all previous batches that were
sent in a stream for this partition.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Header**|**X-Nakadi-StreamId**  <br>*required*|Id of stream which client uses to read events. It is not possible to make a commit for a terminated or<br>none-existing stream. Also the client can't commit something which was not sent to his stream.|string|
|**Path**|**subscription_id**  <br>*required*|Id of subscription|string|
|**Body**|**cursors**  <br>*optional*||[cursors](#subscriptions-subscription_id-cursors-post-cursors)|

<a name="subscriptions-subscription_id-cursors-post-cursors"></a>
**cursors**

|Name|Description|Schema|
|---|---|---|
|**items**  <br>*required*|List of cursors that the consumer acknowledges to have successfully processed.|< [SubscriptionCursor](definitions.md#subscriptioncursor) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|At least one cursor which was tried to be committed is older or equal to already committed one. Array<br>of commit results is returned for this status code.|[Response 200](#subscriptions-subscription_id-cursors-post-response-200)|
|**204**|Offsets were committed|No Content|
|**404**|Subscription not found|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|

<a name="subscriptions-subscription_id-cursors-post-response-200"></a>
**Response 200**

|Name|Description|Schema|
|---|---|---|
|**items**  <br>*required*|list of items which describe commit result for each cursor|< [CursorCommitResult](definitions.md#cursorcommitresult) > array|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-subscription_id-cursors-get"></a>
### GET /subscriptions/{subscription_id}/cursors

#### Description
Exposes the currently committed offsets of a subscription.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string (uuid)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|[Response 200](#subscriptions-subscription_id-cursors-get-response-200)|
|**404**|Subscription not found|[Problem](definitions.md#problem)|

<a name="subscriptions-subscription_id-cursors-get-response-200"></a>
**Response 200**

|Name|Description|Schema|
|---|---|---|
|**items**  <br>*required*|list of cursors for subscription|< [SubscriptionCursor](definitions.md#subscriptioncursor) > array|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-subscription_id-cursors-patch"></a>
### PATCH /subscriptions/{subscription_id}/cursors

#### Description
Endpoint for resetting subscription offsets.
The subscription consumers will be disconnected during offset reset. The request can hang up until
subscription commit timeout. During that time requests to subscription streaming endpoint
will be rejected with 409. The clients should reconnect once the request is finished with 204.


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription|string|
|**Body**|**cursors**  <br>*optional*||[cursors](#subscriptions-subscription_id-cursors-patch-cursors)|

<a name="subscriptions-subscription_id-cursors-patch-cursors"></a>
**cursors**

|Name|Description|Schema|
|---|---|---|
|**items**  <br>*required*|List of cursors to reset subscription to.|< [SubscriptionCursorWithoutToken](definitions.md#subscriptioncursorwithouttoken) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**204**|Offsets were reset|No Content|
|**404**|Subscription not found|[Problem](definitions.md#problem)|
|**409**|Cursors reset is already in progress for provided subscription|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-subscription_id-events-get"></a>
### GET /subscriptions/{subscription_id}/events

#### Description
Starts a new stream for reading events from this subscription. The data will be automatically rebalanced
between streams of one subscription. The minimal consumption unit is a partition, so it is possible to start as
many streams as the total number of partitions in event-types of this subscription. The rebalance currently
only operates with the number of partitions so the amount of data in event-types/partitions is not considered
during autorebalance.
The position of the consumption is managed by Nakadi. The client is required to commit the cursors he gets in
a stream.


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string (uuid)||
|**Query**|**batch_flush_timeout**  <br>*optional*|Maximum time in seconds to wait for the flushing of each chunk (per partition).<br><br>* If the amount of buffered Events reaches `batch_limit` before this `batch_flush_timeout`<br>is reached, the messages are immediately flushed to the client and batch flush timer is reset.<br><br>* If 0 or undefined, will assume 30 seconds.|number (int32)|`30`|
|**Query**|**batch_limit**  <br>*optional*|Maximum number of `Event`s in each chunk (and therefore per partition) of the stream.|integer (int32)|`1`|
|**Query**|**max_uncommitted_events**  <br>*optional*|The amount of uncommitted events Nakadi will stream before pausing the stream. When in paused<br>state and commit comes - the stream will resume. Minimal value is 1.|integer (int32)|`10`|
|**Query**|**stream_keep_alive_limit**  <br>*optional*|Maximum number of empty keep alive batches to get in a row before closing the connection.<br><br>If 0 or undefined will send keep alive messages indefinitely.|integer (int32)|`0`|
|**Query**|**stream_limit**  <br>*optional*|Maximum number of `Event`s in this stream (over all partitions being streamed in this<br>connection).<br><br>* If 0 or undefined, will stream batches indefinitely.<br><br>* Stream initialization will fail if `stream_limit` is lower than `batch_limit`.|integer (int32)|`0`|
|**Query**|**stream_timeout**  <br>*optional*|Maximum time in seconds a stream will live before connection is closed by the server.<br>If 0 or unspecified will stream indefinitely.<br><br>If this timeout is reached, any pending messages (in the sense of `stream_limit`) will be flushed<br>to the client.<br><br>Stream initialization will fail if `stream_timeout` is lower than `batch_flush_timeout`.|number (int32)|`0`|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok. Stream started.<br>Stream format is a continuous series of `SubscriptionEventStreamBatch`s separated by `\n`  <br>**Headers** :   <br>`X-Nakadi-StreamId` (string) : the id of this stream generated by Nakadi. Must be used for committing events that were read by client<br>from this stream.|[SubscriptionEventStreamBatch](definitions.md#subscriptioneventstreambatch)|
|**400**|Bad Request|[Problem](definitions.md#problem)|
|**403**|Access is forbidden for the client or event type|[Problem](definitions.md#problem)|
|**404**|Subscription not found.|[Problem](definitions.md#problem)|
|**409**|Conflict. There are no empty slots for this subscriptions. The amount of consumers for this subscription<br>already equals the maximal value - the total amount of this subscription partitions.<br><br>This status code is also returned in the case of resetting subscription cursors request still in the<br>progress.|[Problem](definitions.md#problem)|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


<a name="subscriptions-subscription_id-stats-get"></a>
### GET /subscriptions/{subscription_id}/stats

#### Description
exposes statistics of specified subscription


#### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string (uuid)|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|[Response 200](#subscriptions-subscription_id-stats-get-response-200)|
|**404**|Subscription not found|[Problem](definitions.md#problem)|

<a name="subscriptions-subscription_id-stats-get-response-200"></a>
**Response 200**

|Name|Description|Schema|
|---|---|---|
|**items**  <br>*required*|statistics list for specified subscription|< [SubscriptionEventTypeStats](definitions.md#subscriptioneventtypestats) > array|


#### Tags

* subscription-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|



