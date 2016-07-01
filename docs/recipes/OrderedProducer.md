## OrderedProducer

_How can a producer send events in a given order?_

### Problem

Once an event arrives at Nakadi and is placed on a partition, that event will retain its order relative to other events in the partition and been seen by all consumers in that same order. However Nakadi does not control the HTTP path from the producer to the server, nor does it control how events are emitted from a producer system, which may in fact be a cluster of producers. How can a producer send events in a given order?


### Solution

First we'll looks at how events are allocated onto partitions by Nakadi and then techniques for managing the order. 

We mentioned that events are ordered within a partition - consumers always see events in the same order they were placed on the partition. Also, events with the same _partition key_ are always sent to the same partition. This allows changes to an entity to be represented as an ordered stream.  There is no assured ordering _across_ partitions - in other words Nakadi provides a _local ordering_. If you are sending events across partitions, there's no assurance on the order consumers will see them. This isn't something Nakadi (or a system like Nakadi such as AWS Kinesis or Azure Event Hub can control), if only because the server has no control over on how consumers decide to access the stream partitions.

Applications that need to control the delivery order events for a particular entity or based on a identifiable key in the data should configure their event type with the _hash_ partitioning strategy and name the fields that can be used to construct the partition key. This ensures each event that has the same key will be sent to the same partition controlling how consumers see events. Then to control the delivery order events are sent to the server, the producer can wait for a http response from the Nakadi before posting the next event (a response means Nakadi has written the event to a partition). This trades off overall producer throughput for better ordering guarantees.

The appraoch above helps manages the physical order events are transmitted to the server and seen by the consumer by using a combination of sequenced posts to the server and control on how events are written to partitions. However, you might want a stronger guarantee than simply managing the delivery order. If so, you will need to state ordering details in the event data itself. For example you may wish to document a particular field represents an incrementing or monotonically increasing value that indicates the data version (incidentally  also allows clients to carry a smaller amount of state). 

Note that the overall throughput and consumer logic will change depending on the events you are sending. If the stream is sending full snapshots of an entity, it's possible for a client to discard an out of order event as it already has a more recent replica of the data. But if the event stream is a series of deltas then how to apply those deltas to produce a materialized view of the entity must be very well defined. The client might need to wait until it sees the 'next' delta, or buffer interim deltas to avoid applying deltas out of order. If the deltas are a time series the client can store them as they arrive and avoiding buffering/rescanning the stream, but it will only be able to materialize up to a given point. 

### Discussion

The default partitioning strategy for Nakadi is random and not hash. Random is a good choice for optimizing for throughput and ensuring balanced load, but you will want to use the hash option to achieve any kind of control on delivery ordering.

Global ordering for a stream seems attractive but is rarely needed - what we want most of the time is ordering of changes for a particular item or domain entity. In the case where total ordering of events is needed, this can be modeled by provisioning a partition count of one - the tradeoff being throughput is reduced to a single client.

Note that ordering is a different concept to causality. If you need to say that one event caused another event, you can use the patterns in [CausalEvent](./recipes/CausalEvent.html).

There are a variety of techniques for defining incrementing or monotonically increasing values and ensuring state can be transmitted correctly. Sometimes the producer's own database will provide a basis for them, in other cases the part of the producer that is sending events can apply an increment or timestamp from a shared clock. A general formal approach to this are the family of methods called [replicated state machines](https://en.wikipedia.org/wiki/State_machine_replication). One well known approach there is called viewstamped replication, and you read more about that [here](https://blog.acolyer.org/2015/03/06/viewstamped-replication-revisited/) and the paper ["Viewstamped Replication Revisited"](http://pmg.csail.mit.edu/papers/vr-revisited.pdf). Ordering and replication in distributed systems is a rich and complex topic and not without difficulty - it's worth thinking through requirements for an event stream before deciding you need very strong ordering. 


