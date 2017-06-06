
## Resources

  - [POST /event-types](#event-types-post)
  - [GET /event-types](#event-types-get)
  - [GET /event-types/{name}](#event-types-name-get)
  - [PUT /event-types/{name}](#event-types-name-put)
  - [DELETE /event-types/{name}](#event-types-name-delete)
  - [POST /event-types/{name}/events](#event-types-name-events-post)
  - [GET /event-types/{name}/events](#event-types-name-events-post)
  - [GET /event-types/{name}/partitions](#event-types-name-partitions-get)
  - [GET /event-types/{name}/partitions/{partition}](#event-types-name-partitions-partition-get)
  - [GET /metrics](#metrics-get)
  - [GET /registry/enrichment-strategies](#registry-enrichment-strategies-get)
  - [GET /registry/partition-strategies](#registry-partition-strategies-get)
  - [GET /registry/validation-strategies](#registry-validation-strategies-get)




<a name="paths"></a>
## Paths

<a name="event-types-post"></a>
### POST /event-types

#### Description
Creates a new `EventType`.

The fields validation-strategies, enrichment-strategies and partition-resolution-strategy
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

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Body**|**event-type**  <br>*required*|EventType to be created|[EventType](definitions.md#eventtype)||


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

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||


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

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Path**|**name**  <br>*required*|Name of the EventType to load.|string||


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

At this moment changes in the schema are not supported and will produce a 422
failure. (todo: define conditions for backwards compatible extensions in the schema)


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Path**|**name**  <br>*required*|Name of the EventType to update.|string||
|**Body**|**event-type**  <br>*required*|EventType to be updated.|[EventType](definitions.md#eventtype)||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|No Content|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
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


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Path**|**name**  <br>*required*|Name of the EventType to delete.|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|EventType is successfuly removed|No Content|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.config.write|


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
`EventType` defines schema validation it will be performed at this moment.

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

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Path**|**name**  <br>*required*|Name of the EventType|string||
|**Body**|**event**  <br>*required*|The Event being published|< [Event](definitions.md#event) > array||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|All events in the batch have been successfully published.|No Content|
|**207**|At least one event has failed to be submitted. The batch might be partially submitted.|< [BatchItemResponse](definitions.md#batchitemresponse) > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
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
|**Header**|**X-nakadi-cursors**  <br>*optional*|Cursors indicating the partitions to read from and respective starting offsets.<br><br>Assumes the offset on each cursor is not inclusive (i.e., first delivered Event is the<br>**first one after** the one pointed to in the cursor).<br><br>If the header is not present, the stream for all partitions defined for the EventType<br>will start from the newest event available in the system at the moment of making this<br>call.<br><br>**Note:** we are not using query parameters for passing the cursors only because of the<br>length limitations on the HTTP query. Another way to initiate this call would be the<br>POST method with cursors passed in the method body. This approach can implemented in the<br>future versions of this API.|< string > array||
|**Path**|**name**  <br>*required*|EventType name to get events about|string||
|**Query**|**batch_flush_timeout**  <br>*optional*|Maximum time in seconds to wait for the flushing of each chunk (per partition).<br><br>* If the amount of buffered Events reaches `batch_limit` before this `batch_flush_timeout`<br>is reached, the messages are immediately flushed to the client and batch flush timer is reset.<br><br>* If 0 or undefined, will assume 30 seconds.|number(int32)|`"30"`|
|**Query**|**batch_limit**  <br>*optional*|Maximum number of `Event`s in each chunk (and therefore per partition) of the stream.<br><br>* If 0 or unspecified will buffer Events indefinitely and flush on reaching of<br>`batch_flush_timeout`.|integer(int32)|`"1"`|
|**Query**|**stream_keep_alive_limit**  <br>*optional*|Maximum number of empty keep alive batches to get in a row before closing the connection.<br><br>If 0 or undefined will send keep alive messages indefinitely.|integer(int32)|`"0"`|
|**Query**|**stream_limit**  <br>*optional*|Maximum number of `Event`s in this stream (over all partitions being streamed in this<br>connection).<br><br>* If 0 or undefined, will stream batches indefinitely.<br><br>* Stream initialization will fail if `stream_limit` is lower than `batch_limit`.|integer(int32)|`"0"`|
|**Query**|**stream_timeout**  <br>*optional*|Maximum time in seconds a stream will live before connection is closed by the server.<br>If 0 or unspecified will stream indefinitely.<br><br>If this timeout is reached, any pending messages (in the sense of `stream_limit`) will be flushed<br>to the client.<br><br>Stream initialization will fail if `stream_timeout` is lower than `batch_flush_timeout`.|number(int32)|`"0"`|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Starts streaming to the client.<br>Stream format is a continuous series of `EventStreamBatch`s separated by `\n`|[EventStreamBatch](definitions.md#eventstreambatch)|
|**401**|Not authenticated|[Problem](definitions.md#problem)|
|**422**|Unprocessable entity|[Problem](definitions.md#problem)|


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


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Path**|**name**  <br>*required*|EventType name|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|< [Partition](definitions.md#partition) > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


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
Returns the given `Partition` of this EventType


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called services. Helpful<br>for operational troubleshooting and log analysis.|string||
|**Path**|**name**  <br>*required*|EventType name|string||
|**Path**|**partition**  <br>*required*|Partition id|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Partition](definitions.md#partition)|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|


#### Tags

* management-api
* unmanaged-api


#### Security

|Type|Name|Scopes|
|---|---|---|
|**oauth2**|**[oauth2](security.md#oauth2)**|nakadi.event_stream.read|


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


<a name="registry-validation-strategies-get"></a>
### GET /registry/validation-strategies

#### Description
Lists all of the validation strategies supported by this installation of Nakadi.

If the EventType creation is to have special validations (besides the default), one can consult over
this method the available possibilities.


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Returns a list of all validation strategies known to Nakadi|< string > array|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


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


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Body**|**subscription**  <br>*required*|Subscription to create|[Subscription](definitions.md#subscription)||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Subscription for such parameters already exists. Returns subscription object that already<br>existed.  <br>**Headers** :   <br>`Location` (string) : The absolute URI for this subscription resource.|[Subscription](definitions.md#subscription)|
|**201**|Subscription was successfuly created. Returns subscription object that was created.  <br>**Headers** :   <br>`Location` (string) : The absolute URI for the created resource.  <br>`Content-Location` (string) : If the Content-Location header is present and the same as the Location header the<br>client can assume it has an up to date representation of the Subscription and a<br>corresponding GET request is not needed.|[Subscription](definitions.md#subscription)|
|**400**|Bad Request|[Problem](definitions.md#problem)|
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
|**Query**|**limit**  <br>*optional*|maximum number of subscriptions retuned in one page|integer(int64)|`"20"`|
|**Query**|**offset**  <br>*optional*|page offset|integer(int64)|`"0"`|
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

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string(uuid)||


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


<a name="subscriptions-subscription_id-cursors-post"></a>
### POST /subscriptions/{subscription_id}/cursors

#### Description
Endpoint for committing offsets of the subscription. The client must commit at least once
every 60 seconds, otherwise Nakadi will consider the client to be gone and will close the
connection.

When a batch is committed that also automatically commits all previous batches that were
sent in a stream for this partition.


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Nakadi-StreamId**  <br>*optional*|Id of stream which client uses to read events. It is not possible to make a commit for a terminated or<br>none-existing stream. Also the client can't commit something which was not sent to his stream.|string||
|**Path**|**subscription_id**  <br>*required*|Id of subscription|string||
|**Body**|**cursors**  <br>*optional*||[cursors](#subscriptions-subscription_id-cursors-post-cursors)||

<a name="subscriptions-subscription_id-cursors-post-cursors"></a>
**cursors**

|Name|Description|Schema|
|---|---|---|
|**cursors**  <br>*optional*|List of cursors that the consumer acknowledges to have successfully processed.|< [SubscriptionCursor](definitions.md#subscriptioncursor) > array|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|At least one cursor which was tried to be committed is older or equal to already committed one. Array<br>of commit results is returned for this status code.|[Response 200](#subscriptions-subscription_id-cursors-post-response-200)|
|**204**|Offsets were committed|No Content|
|**404**|Subscription not found|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|
|**429**|Too many requests|[TooManyRequests](definitions.md#toomanyrequests)|

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

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string(uuid)||


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
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string(uuid)||
|**Query**|**batch_flush_timeout**  <br>*optional*|Maximum time in seconds to wait for the flushing of each chunk (per partition).<br><br>* If the amount of buffered Events reaches `batch_limit` before this `batch_flush_timeout`<br>is reached, the messages are immediately flushed to the client and batch flush timer is reset.<br><br>* If 0 or undefined, will assume 30 seconds.|number(int32)|`"30"`|
|**Query**|**batch_limit**  <br>*optional*|Maximum number of `Event`s in each chunk (and therefore per partition) of the stream.<br><br>* If 0 or unspecified will buffer Events indefinitely and flush on reaching of<br>`batch_flush_timeout`.|integer(int32)|`"1"`|
|**Query**|**max_uncommitted_events**  <br>*optional*|The amount of uncommitted events Nakadi will stream before pausing the stream. When in paused<br>state and commit comes - the stream will resume. Minimal value is 1.|integer(int32)|`"10"`|
|**Query**|**stream_keep_alive_limit**  <br>*optional*|Maximum number of empty keep alive batches to get in a row before closing the connection.<br><br>If 0 or undefined will send keep alive messages indefinitely.|integer(int32)|`"0"`|
|**Query**|**stream_limit**  <br>*optional*|Maximum number of `Event`s in this stream (over all partitions being streamed in this<br>connection).<br><br>* If 0 or undefined, will stream batches indefinitely.<br><br>* Stream initialization will fail if `stream_limit` is lower than `batch_limit`.|integer(int32)|`"0"`|
|**Query**|**stream_timeout**  <br>*optional*|Maximum time in seconds a stream will live before connection is closed by the server.<br>If 0 or unspecified will stream indefinitely.<br><br>If this timeout is reached, any pending messages (in the sense of `stream_limit`) will be flushed<br>to the client.<br><br>Stream initialization will fail if `stream_timeout` is lower than `batch_flush_timeout`.|number(int32)|`"0"`|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok. Stream started.<br>Stream format is a continuous series of `EventStreamBatch`s separated by `\n`  <br>**Headers** :   <br>`X-Nakadi-StreamId` (string) : the id of this stream generated by Nakadi. Must be used for committing events that were read by client<br>from this stream.|[EventStreamBatch](definitions.md#eventstreambatch)|
|**400**|Bad Request|[Problem](definitions.md#problem)|
|**404**|Subscription not found.|[Problem](definitions.md#problem)|
|**409**|Conflict. There are no empty slots for this subscriptions. The amount of consumers for this subscription<br>already equals the maximal value - the total amount of this subscription partitions.|[Problem](definitions.md#problem)|
|**429**|Too many requests|[TooManyRequests](definitions.md#toomanyrequests)|


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

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Path**|**subscription_id**  <br>*required*|Id of subscription.|string(uuid)||


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



