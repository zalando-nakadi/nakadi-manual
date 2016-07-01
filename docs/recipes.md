# Recipes and Patterns

This section features patterns on how to use Nakadi and event stream processing in general.

## Patterns

  - [OverPartitioning](./recipes/OverPartitioning.html)
  - [OrderedProducer](./recipes/OrderedProducer.html)

## Ideas for future sections

 - OrderedProducer: strong and weak ordering techniques
 - StatefulConsumer: managing offsets locally
 - HighThroughputEventing: approaches to high volume events
 - ConsumerLeaseStealing: redistributing partition workloads in a cluster
 - CausalEventing: events that have causal relationships (happens-before)
 - EventTypeVersioning: approaches to versioning event types
 - SendAnything: approaches to send arbitrary content through Nakadi (incl Avro and Protobufs)
 - ProcessMonitor: a microservice that coordinates/watches other event streams (cf @gregyoung)
