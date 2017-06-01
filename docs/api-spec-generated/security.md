
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


|Name|Description|
|---|---|
|nakadi.config.write|Grants access for changing Nakadi configuration.|
|nakadi.event_type.write|Grants access for applications to define and update EventTypes.|
|nakadi.event_stream.write|Grants access for applications to submit Events.|
|nakadi.event_stream.read|Grants access for consuming Event streams.|



