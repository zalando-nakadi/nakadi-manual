## API Reference

_For a higher level view on using the API see the section ["Using Nakadi"](./using.html)._

The Nakadi API is specified using an [Open API definition](https://github.com/zalando/nakadi/blob/nakadi-jvm/api/nakadi-event-bus-api.yaml).  This section provides an API reference and adds context, but the Open API definition should be considered authoritative. You can learn more about Open API from its website, [https://openapis.org](openapis.org).

  - [Definitions](./api-spec-generated/definitions.html)
  - [Paths](./api-spec-generated/paths.html)
  - [Security](./api-spec-generated/security.html)

#### Roadmap Note: The Subscription API

The API documentation focuses on the core API. The project is also planning a
higher level _subscription API_. This will allow the consumption of Events by
creating a named subscription to an Event Type. Subscriptions will support
tracking of stream offsets, freeing consumers from having to manage checkpoints
locally.
