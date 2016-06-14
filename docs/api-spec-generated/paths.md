
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

* Referring any of Validation, Enrichment or Partition strategies that does not exist or
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
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|< [EventType](definitions.md#eventtype) > array|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


<a name="event-types-name-get"></a>
### GET /event-types/{name}

#### Description
Returns the `EventType` identified by its name.


#### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||
|**Path**|**name**  <br>*required*|Name of the EventType to load.|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|[EventType](definitions.md#eventtype)|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**404**|EventType not found|[Problem](definitions.md#problem)|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||
|**Path**|**name**  <br>*required*|Name of the EventType to update.|string||
|**Body**|**event-type**  <br>*required*|EventType to be updated.|[EventType](definitions.md#eventtype)||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Ok|No Content|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**404**|EventType not found.|[Problem](definitions.md#problem)|
|**422**|Unprocessable Entity|[Problem](definitions.md#problem)|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||
|**Path**|**name**  <br>*required*|Name of the EventType to delete.|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|EventType is successfuly removed|No Content|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**403**|Client is not authorized to perform this operation|[Problem](definitions.md#problem)|
|**404**|EventType not found.|[Problem](definitions.md#problem)|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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

1. Every validation rule specified in the `EventType` will be checked in order against the
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
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||
|**Path**|**name**  <br>*required*|Name of the EventType|string||
|**Body**|**event**  <br>*required*|The Event being published|< [Event](definitions.md#event) > array||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|All events in the batch have been successfully published.|No Content|
|**207**|At least one event has failed to be submitted. The batch might be partially submitted.|< [BatchItemResponse](definitions.md#batchitemresponse) > array|
|**400**|Bad request|[Problem](definitions.md#problem)|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**404**|EventType not found.|[Problem](definitions.md#problem)|
|**405**|Not allowed.|[Problem](definitions.md#problem)|
|**422**|At least one event failed to be validated, enriched or partitioned. None were submitted.|< [BatchItemResponse](definitions.md#batchitemresponse) > array|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||
|**Header**|**X-nakadi-cursors**  <br>*optional*|Cursors indicating the partitions to read from and respective starting offsets.<br><br>Assumes the offset on each cursor is not inclusive (i.e., first delivered Event is the<br>**first one after** the one pointed to in the cursor).<br><br>If the header is not present, the stream for all partitions defined for the EventType<br>will start from the newest event available in the system at the moment of making this<br>call.<br><br>**Note:** we are not using query parameters for passing the cursors only because of the<br>length limitations on the HTTP query. Another way to initiate this call would be the<br>POST method with cursors passed in the method body. This approach can implemented in the<br>future versions of this API.|string(serialized json array of '#/definitions/Cursor')||
|**Path**|**name**  <br>*required*|EventType name to get events about|string||
|**Query**|**batch_flush_timeout**  <br>*optional*|Maximum time in seconds to wait for the flushing of each chunk (per partition).<br><br>* If the amount of buffered Events reaches `batch_limit` before this<br>`batch_flush_timeout` is reached, the messages are immediately flushed to the client and<br>batch flush timer is reset.<br><br>* If 0 or undefined, will assume 30 seconds.|number(int32)|`"30"`|
|**Query**|**batch_limit**  <br>*optional*|Maximum number of `Event`s in each chunk (and therefore per partition) of the stream.<br><br>* If 0 or unspecified will buffer Events indefinitely and flush on reaching of<br>`batch_flush_timeout`.|integer(int32)|`"1"`|
|**Query**|**stream_keep_alive_limit**  <br>*optional*|Maximum number of keep-alive messages to get in a row before closing the connection.<br><br>If 0 or undefined will send keep alive messages indefinitely.|integer(int32)|`"0"`|
|**Query**|**stream_limit**  <br>*optional*|Maximum number of `Event`s in this stream (over all partitions being streamed in this<br>connection).<br><br>* If 0 or undefined, will stream batches indefinitely.<br><br>* Stream initialization will fail if `stream_limit` is lower than `batch_limit`.|integer(int32)|`"0"`|
|**Query**|**stream_timeout**  <br>*optional*|Maximum time in seconds a stream will live before being interrupted.<br>If 0 or unspecified will stream indefinitely.<br><br>If this timeout is reached, any pending messages (in the sense of `stream_limit`) will<br>be flushed to the client.<br><br>Stream initialization will fail if `stream_timeout` is lower than `batch_flush_timeout`.|number(int32)|`"0"`|


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Starts streaming to the client.<br>Stream format is a continuous series of `EventStreamBatch`s separated by `\n`|[EventStreamBatch](definitions.md#eventstreambatch)|
|**400**|Bad syntax|[Problem](definitions.md#problem)|
|**401**|Not authenticated|[Problem](definitions.md#problem)|
|**404**|EventType not found|[Problem](definitions.md#problem)|
|**422**|Unprocessable entity|[Problem](definitions.md#problem)|
|**500**|Internal Server Error. Details are provided on the returned `Problem`.|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||
|**Path**|**name**  <br>*required*|EventType name|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|< [Partition](definitions.md#partition) > array|
|**404**|EventType not found|[Problem](definitions.md#problem)|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**Header**|**X-Flow-Id**  <br>*optional*|The flow id of the request, which is written into the logs and passed to called<br>services. Helpful for operational troubleshooting and log analysis.|string(flow-id)||
|**Path**|**name**  <br>*required*|EventType name|string||
|**Path**|**partition**  <br>*required*|Partition id|string||


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Partition](definitions.md#partition)|
|**401**|Client is not authenticated|[Problem](definitions.md#problem)|
|**404**|Not found|[Problem](definitions.md#problem)|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


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
  with same values on those fields end in the same partition.


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Returns a list of all partitioning strategies known to Nakadi|< string > array|
|**500**|Server error|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api


<a name="registry-validation-strategies-get"></a>
### GET /registry/validation-strategies

#### Description
Lists all of the validation strategies supported by this installation of Nakadi. Special or
custom strategies besides the defaults will be listed here.


#### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|Returns a list of all validation strategies known to Nakadi|< string > array|
|**500**|Server error|[Problem](definitions.md#problem)|
|**503**|Service (temporarily) unavailable|[Problem](definitions.md#problem)|


#### Tags

* schema-registry-api



