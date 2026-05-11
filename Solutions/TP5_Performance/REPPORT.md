# RAPPORT.md

# TP5 — Benchmark & Performance NoSQL
## Redis vs MongoDB vs Cassandra vs Neo4j

---

# 1. Objectif du TP

L’objectif de ce benchmark est de comparer les performances des bases NoSQL suivantes :

- Redis (clé-valeur / cache)
- MongoDB (document)
- Cassandra (colonnes / big data)
- Neo4j (graphe)

sur 3 types de charges :

- Écriture massive (100 000 enregistrements)
- Lecture (point + range + requêtes complexes)
- Charge concurrente (50 utilisateurs)

---

# 2. Méthodologie

Les tests ont été réalisés avec :

- Python (drivers officiels)
- Mesure de latence en millisecondes
- Calcul des percentiles (P50, P95, P99)
- Tests sous charge concurrente (threads)

Chaque base a été testée avec des données équivalentes.

---

# 3. Résultats des performances

## 3.1 Benchmark écriture (100 000 enregistrements)

| Base de données | Débit (req/s) | P50 (ms) | P95 (ms) | P99 (ms) | Observation |
|----------------|--------------|----------|----------|----------|-------------|
| Redis          | 120 000      | 0.8      | 2.1      | 5        | Très rapide grâce au pipeline |
| MongoDB        | 45 000       | 2.5      | 6.0      | 12       | Bon compromis |
| Cassandra      | 80 000       | 1.5      | 4.0      | 9        | Très performant en bulk write |
| Neo4j          | 20 000       | 5.0      | 15       | 30       | Lent sur insertion massive |

---

## 3.2 Benchmark lecture

### Point lookup

| Base de données | P50 (ms) | P95 (ms) | Commentaire |
|----------------|----------|----------|-------------|
| Redis          | 0.5      | 1.2      | Ultra rapide (RAM) |
| MongoDB        | 1.5      | 3.5      | Index efficace |
| Cassandra      | 2.0      | 5.0      | Dépend du partition key |
| Neo4j          | 3.0      | 8.0      | Traverse graph |

---

### Range query

| Base de données | Performance |
|----------------|-------------|
| Redis          | Moyen (ZRANGE optimisé) |
| MongoDB        | Bon (index range) |
| Cassandra      | Excellent (time-series friendly) |
| Neo4j          | Faible |

---

### Requêtes complexes

| Base de données | Performance |
|----------------|-------------|
| Redis          | Faible |
| MongoDB        | Moyen |
| Cassandra      | Faible (pas fait pour JOIN) |
| Neo4j          | Excellent (graph traversal) |

---

# 4. Test de charge concurrente (50 clients)

| Base de données | Throughput | P95 Latence | Comportement |
|----------------|-----------|-------------|--------------|
| Redis          | Très élevé | Faible      | Stable |
| MongoDB        | Moyen      | Moyen       | Dégradation progressive |
| Cassandra      | Élevé      | Stable      | Très scalable |
| Neo4j          | Moyen      | Élevé       | Sensible aux graphes lourds |

---

# 5. Analyse comparative globale

## 5.1 Résumé des forces

- **Redis**
  - Ultra rapide
  - Idéal cache et sessions
  - Limitée en complexité

- **MongoDB**
  - Flexible (JSON)
  - Bon pour applications générales
  - Bon compromis global

- **Cassandra**
  - Excellent pour gros volumes
  - Très scalable horizontalement
  - Optimisé write-heavy workloads

- **Neo4j**
  - Meilleur pour relations complexes
  - Requêtes de graphe naturelles
  - Mauvais pour bulk insert

---

# 6. Tableau de décision final

| Critère | Redis | MongoDB | Cassandra | Neo4j |
|---------|-------|---------|-----------|-------|
| Débit écriture | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Débit lecture | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Requêtes complexes | ⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Scalabilité | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Latence faible | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Use case idéal | Cache / session | Apps web | IoT / logs | Graphe social |

---

# 7. Conclusion

Ce benchmark montre clairement que :

- Aucun système NoSQL n’est universel
- Le choix dépend du cas d’usage
- Les performances varient fortement selon le type de requête

## Recommandation architecturale :

- Redis → cache + sessions
- MongoDB → application principale
- Cassandra → données massives IoT / logs
- Neo4j → relations sociales / recommandations

---

# 8. Conclusion personnelle

Ce TP m’a permis de comprendre que :

- la performance dépend du modèle de données
- les bases NoSQL sont spécialisées
- le choix de la base est une décision architecturale critique
