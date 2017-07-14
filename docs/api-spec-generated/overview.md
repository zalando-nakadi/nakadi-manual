# Nakadi Event Bus API Definition


## API Reference

The Nakadi API is specified using an [Open API definition](https://github.com/zalando/nakadi/blob/nakadi-jvm/api/nakadi-event-bus-api.yaml).  This section provides an API reference and adds context, but the Open API definition should be considered authoritative. You can learn more about Open API from its website, [https://openapis.org](openapis.org).

For a high level view on using the API see the section ["Using Nakadi"](./using.html).


<a name="overview"></a>
## Overview
Nakadi at its core aims at being a generic and content-agnostic event broker with a convenient
API.  In doing this, Nakadi abstracts away, as much as possible, details of the backing
messaging infrastructure. The single currently supported messaging infrastructure is Kafka
(Kinesis is planned for the future).

In Nakadi every Event has an EventType, and a **stream** of Events is exposed for each
registered EventType.

An EventType defines properties relevant for the operation of its associated stream, namely:

* The **schema** of the Event of this EventType. The schema defines the accepted format of
Events of an EventType and will be, if so desired, enforced by Nakadi. Usually Nakadi will
respect the schema for the EventTypes in accordance to how an owning Application defines them.

* The expected **validation** and **enrichment** procedures upon reception of an Event.
Validation define conditions for the acceptance of the incoming Event and are strictly enforced
by Nakadi. Usually the validation will enforce compliance of the payload (or part of it) with
the defined schema of its EventType. Enrichment specify properties that are added to the payload
(body) of the Event before persisting it. Usually enrichment affects the metadata of an Event
but is not limited to.

* The **ordering** expectations of Events in this stream. Each EventType will have its Events
stored in an underlying logical stream (the Topic) that is physically organized in disjoint
collections of strictly ordered Events (the Partition). The EventType defines the field that
acts as evaluator of the ordering (that is, its partition key); this ordering is guaranteed by
making Events whose partition key resolves to the same Partition (usually a hash function on its
value) be persisted strictly ordered in a Partition.  In practice this means that all Events
within a Partition have their relative order guaranteed: Events (of a same EventType) that are
*about* a same data entity (that is, have the same value on its Partition key) reach always the
same Partition, the relative ordering of them is secured. This mechanism implies that no
statements can be made about the relative ordering of Events that are in different partitions.

* The **authorization** rules for the event type. The rules define who can produce events for
the event type (write), who can consume events from the event type (read), and who can update
the event type properties (admin). If the authorization rules are absent, then the event type
is open to all authenticated users.

Except for defined enrichment rules, Nakadi will never manipulate the content of any Event.

Clients of Nakadi can be grouped in 2 categories: **EventType owners** and **Clients** (clients
in turn are both **Producers** and **Consumers** of Events). Event Type owners interact with
Nakadi via the **Schema Registry API** for the definition of EventTypes, while Clients via the
streaming API for submission and reception of Events.

A low level **Unmanaged API** is available, providing full control and responsibility of
position tracking and partition resolution (and therefore ordering) to the Clients.

In the **High Level API** the consumption of Events proceeds via the establishment
of a named **Subscription** to an EventType. Subscriptions are persistent relationships from an
Application (which might have several instances) and the stream of one or more EventType's,
whose consumption tracking is managed by Nakadi, freeing Consumers from any responsibility in
tracking of the current position on a Stream.


Scope and status of the API
---------------------------------

In this document, you'll find:

* The Schema Registry API, including configuration possibilities for the Schema, Validation,
Enrichment and Partitioning of Events, and their effects on reception of Events.

* The existing event format (see definition of Event, BusinessEvent and DataChangeEvent)
(Note: in the future this is planned to be configurable and not an inherent part of this API).

* High Level API.

Other aspects of the Event Bus are at this moment to be defined and otherwise specified, not included
in this version of this specification.


### Version information
*Version* : 0.8.0


### Contact information
*Contact* : Team Aruha @ Zalando  
*Contact Email* : team-aruha+nakadi-maintainers@zalando.de


### URI scheme
*Schemes* : HTTPS


### Consumes

* `application/json`


### Produces

* `application/json`



