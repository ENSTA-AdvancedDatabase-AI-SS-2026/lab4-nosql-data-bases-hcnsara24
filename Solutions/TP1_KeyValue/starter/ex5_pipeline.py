# TP1 - Exercice 5 : Pipeline & Transactions Redis

import redis
import time

# Connexion Redis
r = redis.Redis(host='localhost', port=6379, decode_responses=True)


# ─────────────────────────────────────────────
# Bulk insert avec pipeline
# ─────────────────────────────────────────────
def bulk_insert_products(nb=1000):

    start = time.time()

    pipe = r.pipeline()

    for i in range(nb):

        pipe.hset(
            f"product:{i}",
            mapping={
                "name": f"Produit {i}",
                "price": i * 10,
                "stock": 100
            }
        )

    pipe.execute()

    elapsed = time.time() - start

    print(f"{nb} produits insérés en {elapsed:.3f}s")


# ─────────────────────────────────────────────
# Transaction atomique MULTI/EXEC
# Simulation achat produit
# ─────────────────────────────────────────────
def buy_product(product_id, quantity):

    key = f"product:{product_id}"

    while True:

        try:
            pipe = r.pipeline()

            pipe.watch(key)

            stock = int(r.hget(key, "stock"))

            if stock < quantity:
                pipe.unwatch()
                print("Stock insuffisant")
                return False

            nouveau_stock = stock - quantity

            pipe.multi()

            pipe.hset(
                key,
                "stock",
                nouveau_stock
            )

            pipe.execute()

            print("Achat validé")
            print("Nouveau stock :", nouveau_stock)

            return True

        except redis.WatchError:
            print("Conflit détecté, nouvelle tentative...")


# ─────────────────────────────────────────────
# Test
# ─────────────────────────────────────────────
if __name__ == "__main__":

    # insertion massive
    bulk_insert_products()

    # produit test
    r.hset(
        "product:9999",
        mapping={
            "name": "Laptop",
            "price": 150000,
            "stock": 10
        }
    )

    # achat
    buy_product(9999, 3)
