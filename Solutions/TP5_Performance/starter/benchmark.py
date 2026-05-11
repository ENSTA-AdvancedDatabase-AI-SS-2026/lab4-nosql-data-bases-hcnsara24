"""
TP5 - Benchmark Comparatif NoSQL
Redis vs MongoDB vs Cassandra vs Neo4j
"""

import time
import statistics
import threading
from typing import Callable

import redis
from pymongo import MongoClient
from cassandra.cluster import Cluster


# ─────────────────────────────────────────────
# UTILITAIRE LATENCE
# ─────────────────────────────────────────────
def measure_latency(fn: Callable, iterations: int = 1000):
    latencies = []

    for _ in range(iterations):
        start = time.perf_counter()
        fn()
        latencies.append((time.perf_counter() - start) * 1000)

    latencies.sort()

    return {
        "mean_ms": statistics.mean(latencies),
        "p50_ms": latencies[int(0.50 * len(latencies))],
        "p95_ms": latencies[int(0.95 * len(latencies))],
        "p99_ms": latencies[int(0.99 * len(latencies))],
        "max_ms": max(latencies),
    }


def print_results(name, results):
    print("\n" + "=" * 50)
    print(name)
    print("=" * 50)
    for k, v in results.items():
        print(f"{k:15} : {v:.2f} ms")


# ─────────────────────────────────────────────
# EX1 - WRITE BENCHMARK REDIS
# ─────────────────────────────────────────────
def benchmark_write_redis(n=10000):
    r = redis.Redis(host="localhost", port=6379, decode_responses=True)
    r.flushdb()

    pipe = r.pipeline()

    def insert():
        for i in range(n):
            pipe.set(f"key:{i}", f"value:{i}")
        pipe.execute()

    res = measure_latency(insert, 1)
    print_results("Redis WRITE", res)


# ─────────────────────────────────────────────
# EX1 - WRITE MONGODB
# ─────────────────────────────────────────────
def benchmark_write_mongodb(n=10000):
    client = MongoClient("mongodb://localhost:27017/")
    db = client["benchmark"]
    col = db["test"]

    col.drop()

    def insert():
        batch = [{"_id": i, "value": i} for i in range(n)]
        col.insert_many(batch)

    res = measure_latency(insert, 1)
    print_results("MongoDB WRITE", res)


# ─────────────────────────────────────────────
# EX1 - WRITE CASSANDRA
# ─────────────────────────────────────────────
def benchmark_write_cassandra(n=10000):
    cluster = Cluster(["localhost"])
    session = cluster.connect("benchmark")

    session.execute("""
        CREATE TABLE IF NOT EXISTS test (
            id INT PRIMARY KEY,
            value INT
        )
    """)

    def insert():
        for i in range(n):
            session.execute(
                "INSERT INTO test (id, value) VALUES (%s, %s)",
                (i, i)
            )

    res = measure_latency(insert, 1)
    print_results("Cassandra WRITE", res)


# ─────────────────────────────────────────────
# EX2 - READ REDIS
# ─────────────────────────────────────────────
def benchmark_read_redis():
    r = redis.Redis(host="localhost", port=6379, decode_responses=True)

    def point():
        r.get("key:1")

    def range_query():
        r.mget([f"key:{i}" for i in range(100)])

    res1 = measure_latency(point, 1000)
    res2 = measure_latency(range_query, 200)

    print_results("Redis POINT READ", res1)
    print_results("Redis RANGE READ", res2)


# ─────────────────────────────────────────────
# EX2 - READ MONGODB
# ─────────────────────────────────────────────
def benchmark_read_mongodb():
    client = MongoClient("mongodb://localhost:27017/")
    col = client["benchmark"]["test"]

    def point():
        col.find_one({"_id": 1})

    def range_query():
        list(col.find({"_id": {"$lt": 100}}))

    res1 = measure_latency(point, 1000)
    res2 = measure_latency(range_query, 200)

    print_results("MongoDB POINT READ", res1)
    print_results("MongoDB RANGE READ", res2)


# ─────────────────────────────────────────────
# EX3 - CONCURRENCY TEST
# ─────────────────────────────────────────────
def benchmark_concurrent(db_fn, n_clients=50, requests_per_client=200):
    results = []

    def worker():
        for _ in range(requests_per_client):
            start = time.perf_counter()
            db_fn()
            results.append((time.perf_counter() - start) * 1000)

    threads = []

    start_global = time.perf_counter()

    for _ in range(n_clients):
        t = threading.Thread(target=worker)
        threads.append(t)
        t.start()

    for t in threads:
        t.join()

    total_time = time.perf_counter() - start_global

    results.sort()

    print("\n===== CONCURRENCY TEST =====")
    print(f"Requests: {n_clients * requests_per_client}")
    print(f"Total time: {total_time:.2f}s")
    print(f"Throughput: {len(results)/total_time:.2f} req/s")
    print(f"P95 latency: {results[int(0.95*len(results))]:.2f} ms")


# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────
if __name__ == "__main__":

    N = 5000  # réduit pour test

    print("\n🚀 TP5 - NoSQL Benchmark\n")

    benchmark_write_redis(N)
    benchmark_write_mongodb(N)
    benchmark_write_cassandra(N)

    print("\n📖 READ BENCHMARKS\n")

    benchmark_read_redis()
    benchmark_read_mongodb()

    print("\n⚡ CONCURRENCY TEST\n")

    benchmark_concurrent(lambda: redis.Redis().get("key:1"))
