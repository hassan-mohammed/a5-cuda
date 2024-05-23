#define ReverseQueueSize 23

#include <iostream>
#include <crt/host_defines.h>
#pragma once

struct ReverseQueue {
    int array[ReverseQueueSize];
    size_t head;      // The index from which to dequeue if the queue isn't empty.
    size_t size;      // Number of elements currently in the queue.
    size_t capacity = ReverseQueueSize;  // Capacity of the array.
};

// Initialize ReverseQueue
static __device__ __host__ void initializeReverseQueue(ReverseQueue * queue) {
    queue->head = 0;
    queue->size = 0;

}

static __device__ __host__ size_t QueueSize(const ReverseQueue& queue) {
    return queue.size;
}

static __device__ __host__ size_t QueueCapacity(const ReverseQueue& queue) {
    return queue.capacity;
}

static __device__ __host__ void Enqueue(ReverseQueue& queue, int element) {
    //TODO:Conv throw exception isn't allowed    if (queue.size == queue.capacity) throw "Queue is full";

    queue.array[queue.head] = element;
    queue.head++;
    queue.size++;
}

static __device__ __host__ int Dequeue(ReverseQueue& queue) {
    //TODO:Conv throw exception isn't allowed    if (queue.size == 0) throw "Empty queue";

    int removed = queue.array[queue.head - 1];
    queue.head--;
    queue.size--;
    queue.array[queue.head] = 0;  // Assuming 0 is the default value for an empty slot
    return removed;
}
