
## Authorization

The Nakadi API can be secured using OAuth 2.0 scopes. The current model is 
limited to generic scopes. The project may look to support more granular 
scopes in the future such as limiting access to particular event types and streams.


<a name="securityscheme"></a>
## Security

<a name="oauth2"></a>
### oauth2
*Type* : oauth2  
*Flow* : implicit  
*Token URL* : https://auth.example.com/oauth2/tokeninfo


| Scope | Description |
|---|---|
|nakadi.config.write|Grants access for changing Nakadi configuration.|
|nakadi.event_type.write|Grants access for applications to define and update EventTypes.|
|nakadi.event_stream.write|Grants access for applications to submit Events.|
|nakadi.event_stream.read|Grants access for consuming Event streams.|

<a name="event type"></a>
### Event Type
#### Write and read scopes

Nakadi has possibility to check OAuth2 Scopes (scopes) of publisher and consumer to grant access
write and read events only for trusted users.
In order to use this feature an event type owner is able to specify read and write
scopes for the event type:

```sh
curl -v -XPOST http://localhost:8080/event-types -d '{
  "name": "order_received",
  "owning_application": "acme-order-service",
  "category": "business",
  "partition_strategy": "random",
  "enrichment_strategies": ["metadata_enrichment"],
  "schema": {
    "type": "json_schema",
    "schema": "{ \"properties\": { \"order_number\": { \"type\": \"string\" } } }"
  }

  "write_scopes" : ["oauth2.write.scope.one", "oauth2.write.scope.two"],
  "read_scopes" : ["oauth2.read.scope.one", "oauth2.read.scope.two"]
}'
```

Once publisher tries to write an event to `order_received`, its OAuth2 Token is examined for scopes
which are defined in `write_scopes`. For successful publishing he should have at least one of
the defined scopes.

The event type owner has to create scopes for the application which is owner of this event type.
Publishers, in their turn, has to request scopes for their applications, which are defined by
the event type owner, to be able to publish events.

Application scope validation does not occur if no write or read scopes are specified
for the event type.

The same is valid for event consumers.