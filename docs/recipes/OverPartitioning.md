
## OverPartitioning

### Problem

Nakadi throughput scales with the number of partitions in an event type. The number of partitions in an event type is fixed &mdash; it can only be configured on create. Scaling throughput by creating a new event type can be tricky though, because the switch-over has to be coordinated between producers and consumers.

You expect a significant increase in throughput over time. How many partitions should you create?

### Solution

Create more partitions then you currently need. Each consumer initially reads from multiple partitions. Increase the number of consumers as throughput increases, until the number of consumers is equal to the number of partitions.

To distribute the workload evenly, make sure that each consumer reads from the same number of partitions. This strategy works best if the number of partitions is a product of small primes:

 - with 6 (= 2 * 3) partitions, you can use 1, 2, 3 or 6 consumers
 - with 8 (= 2 * 2 * 2) partitions, you can use 1, 2, 4 or 8 consumers
 - with 12 (= 2 * 2 * 3) partitions, you can use 1, 2, 3, 4, 6 or 12 consumers

### Discussion

The total number of partitions in a Nakadi cluster is limited. **Start with a single partition**, and employ this pattern only once you are forced to use multiple partitions. Don't over-overpartition, use the lowest sensible number that works. You can always fall back on creating a new event type with more partitions later, if necessary.



