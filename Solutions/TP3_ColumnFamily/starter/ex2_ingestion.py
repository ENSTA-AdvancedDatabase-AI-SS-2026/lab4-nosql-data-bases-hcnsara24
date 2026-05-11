"""
TP3 - Exercice 2 : Ingestion de données IoT
Use Case : SmartGrid DZ - 10 000 capteurs, 5 minutes de mesures
"""
from cassandra.cluster import Cluster
from cassandra.query import BatchStatement, BatchType
import uuid
import random
from datetime import datetime, timedelta
import time

# Configuration
CASSANDRA_HOST = 'localhost'
KEYSPACE = 'smartgrid'
NB_CAPTEURS = 10000
MINUTES_HISTORIQUE = 5

WILAYAS = ["Alger", "Oran", "Constantine", "Annaba", "Blida"]

COMMUNES = {
    "Alger": ["Bab Ezzouar", "Hydra", "El Harrach", "Dar El Beida"],
    "Oran": ["Bir El Djir", "Es Senia", "Arzew"],
    "Constantine": ["El Khroub", "Ain Smara", "Hamma Bouziane"],
    "Annaba": ["El Bouni", "El Hadjar", "Seraidi"],
    "Blida": ["Bougara", "Boufarik", "Larbaa"],
}


def connect():
    """Connexion au cluster Cassandra"""
    cluster = Cluster([CASSANDRA_HOST])
    session = cluster.connect(KEYSPACE)
    return session, cluster


def generate_mesure(capteur_id, wilaya, commune, timestamp):
    """Générer une mesure réaliste pour un capteur"""
    tension_base = 220  # Volts (réseau algérien)

    return {
        "capteur_id": capteur_id,
        "date_jour": timestamp.date(),
        "timestamp": timestamp,
        "wilaya": wilaya,
        "commune": commune,
        "tension_v": round(tension_base + random.gauss(0, 5), 2),
        "courant_a": round(random.uniform(0.5, 15.0), 2),
        "puissance_kw": round(random.uniform(0.1, 3.3), 3),
        "frequence_hz": round(50 + random.gauss(0, 0.1), 2),
        "temperature": round(random.uniform(20, 65), 1),
        "alerte": random.random() < 0.05,
    }


# ─────────────────────────────────────────────────────────────
# INSERT SINGLE
# ─────────────────────────────────────────────────────────────
def insert_single(session, mesure):
    """
    Insérer une seule mesure dans mesures_par_capteur
    Utiliser une prepared statement
    """
    query = session.prepare("""
        INSERT INTO mesures_par_capteur (
            capteur_id, date_jour, timestamp, wilaya, commune,
            tension_v, courant_a, puissance_kw, frequence_hz,
            temperature, alerte
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        USING TTL 7776000
    """)

    session.execute(query, (
        mesure["capteur_id"],
        mesure["date_jour"],
        mesure["timestamp"],
        mesure["wilaya"],
        mesure["commune"],
        mesure["tension_v"],
        mesure["courant_a"],
        mesure["puissance_kw"],
        mesure["frequence_hz"],
        mesure["temperature"],
        mesure["alerte"]
    ))


# ─────────────────────────────────────────────────────────────
# BATCH INSERT
# ─────────────────────────────────────────────────────────────
def insert_batch(session, mesures: list):
    """
    Insérer un batch de mesures efficacement
    Utiliser UNLOGGED BATCH + max 50 items
    """
    query = session.prepare("""
        INSERT INTO mesures_par_capteur (
            capteur_id, date_jour, timestamp, wilaya, commune,
            tension_v, courant_a, puissance_kw, frequence_hz,
            temperature, alerte
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        USING TTL 7776000
    """)

    batch = BatchStatement(batch_type=BatchType.UNLOGGED)

    for i, m in enumerate(mesures):
        batch.add(query, (
            m["capteur_id"],
            m["date_jour"],
            m["timestamp"],
            m["wilaya"],
            m["commune"],
            m["tension_v"],
            m["courant_a"],
            m["puissance_kw"],
            m["frequence_hz"],
            m["temperature"],
            m["alerte"]
        ))

        # exécuter tous les 50 éléments
        if (i + 1) % 50 == 0:
            session.execute(batch)
            batch = BatchStatement(batch_type=BatchType.UNLOGGED)

    # flush dernier batch
    if len(batch) > 0:
        session.execute(batch)


# ─────────────────────────────────────────────────────────────
# RUN INGESTION
# ─────────────────────────────────────────────────────────────
def run_ingestion(session):
    """
    Générer et insérer toutes les mesures IoT
    """
    print(f"Démarrage ingestion : {NB_CAPTEURS} capteurs × {MINUTES_HISTORIQUE} min")
    start = time.time()

    capteurs = [
        (uuid.uuid4(),
         random.choice(WILAYAS),
         None)
        for _ in range(NB_CAPTEURS)
    ]

    # assignation communes
    capteurs = [
        (cid, wilaya, random.choice(COMMUNES[wilaya]))
        for cid, wilaya, _ in capteurs
    ]

    total_inserted = 0

    for minute in range(MINUTES_HISTORIQUE):
        timestamp = datetime.now() - timedelta(minutes=minute)

        batch_data = []

        for capteur_id, wilaya, commune in capteurs:
            mesure = generate_mesure(capteur_id, wilaya, commune, timestamp)
            batch_data.append(mesure)

        insert_batch(session, batch_data)
        total_inserted += len(batch_data)

        print(f"Minute {minute+1}/{MINUTES_HISTORIQUE} → OK")

    elapsed = time.time() - start

    print(f"\n✅ {total_inserted:,} mesures insérées en {elapsed:.1f}s")
    print(f"   Débit : {total_inserted/elapsed:,.0f} mesures/seconde")


# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    session, cluster = connect()
    run_ingestion(session)
    cluster.shutdown()
