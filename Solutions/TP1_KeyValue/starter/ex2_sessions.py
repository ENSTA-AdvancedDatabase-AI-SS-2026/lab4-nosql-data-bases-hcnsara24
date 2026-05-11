# TP1 - Exercice 2 : Sessions utilisateur Redis

import redis
import uuid
import json

# Connexion Redis
r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# TTL = 30 minutes
SESSION_TTL = 1800


# ─────────────────────────────────────────────
# Créer une session
# ─────────────────────────────────────────────
def create_session(user_id, username):
    session_id = str(uuid.uuid4())

    session_data = {
        "user_id": user_id,
        "username": username
    }

    key = f"session:{session_id}"

    r.setex(
        key,
        SESSION_TTL,
        json.dumps(session_data)
    )

    return session_id


# ─────────────────────────────────────────────
# Récupérer une session
# Sliding expiration :
# chaque accès renouvelle le TTL
# ─────────────────────────────────────────────
def get_session(session_id):
    key = f"session:{session_id}"

    data = r.get(key)

    if not data:
        return None

    # renouveler expiration
    r.expire(key, SESSION_TTL)

    return json.loads(data)


# ─────────────────────────────────────────────
# Supprimer une session
# ─────────────────────────────────────────────
def delete_session(session_id):
    key = f"session:{session_id}"

    r.delete(key)


# ─────────────────────────────────────────────
# Vérifier temps restant
# ─────────────────────────────────────────────
def get_ttl(session_id):
    key = f"session:{session_id}"

    return r.ttl(key)


# ─────────────────────────────────────────────
# Test
# ─────────────────────────────────────────────
if __name__ == "__main__":

    session_id = create_session(
        user_id=1,
        username="Ahmed"
    )

    print("Session créée :", session_id)

    session = get_session(session_id)

    print("Session :", session)

    print("TTL restant :", get_ttl(session_id), "secondes")

    delete_session(session_id)

    print("Session supprimée")
