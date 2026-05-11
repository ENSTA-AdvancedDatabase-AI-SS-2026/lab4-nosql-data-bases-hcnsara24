# RAPPORT.md

# TP3 — Cassandra : Données IoT & Séries Temporelles
## SmartGrid DZ

---

# 1. Justification des Partition Keys

## Table `mesures_par_capteur`

```sql
PRIMARY KEY ((capteur_id, date_jour), timestamp)
```

### Pourquoi ce choix ?

La requête principale est :

```sql
"Toutes les mesures du capteur X entre T1 et T2"
```

Le `capteur_id` permet de retrouver rapidement les données d’un capteur spécifique.

Le `date_jour` est ajouté pour créer un bucket temporel et éviter qu’une seule partition devienne trop grande.

Le clustering par `timestamp DESC` permet d’obtenir les mesures les plus récentes en premier.

### Risque de Hot Partition ?

Oui, si on utilisait uniquement :

```sql
PRIMARY KEY ((capteur_id), timestamp)
```

Toutes les mesures d’un capteur seraient stockées dans une seule partition.

Cela provoquerait :

- partitions énormes
- surcharge d’un nœud Cassandra
- ralentissement des lectures et écritures

La solution :

```sql
(capteur_id, date_jour)
```

répartit les données par jour et réduit le risque de hot partition.

---

## Table `alertes_par_wilaya`

```sql
PRIMARY KEY ((wilaya, date_jour), timestamp, capteur_id)
```

### Pourquoi ce choix ?

Cette table répond à la requête :

```sql
"Alertes d'une wilaya aujourd'hui"
```

La partition :

```sql
(wilaya, date_jour)
```

permet d’accéder rapidement aux alertes d’une wilaya pour une journée donnée.

Le clustering par `timestamp DESC` permet d’afficher les alertes récentes en premier.

### Risque de Hot Partition ?

Le risque reste faible car :

- les alertes représentent peu de données
- les partitions sont séparées par jour

Cependant, une wilaya très active pourrait générer plus de charge qu’une autre.

---

## Table `agregats_horaires`

```sql
PRIMARY KEY (wilaya, date_heure)
```

### Pourquoi ce choix ?

Cette table est utilisée pour le dashboard :

```sql
"Consommation moyenne par heure"
```

La partition par `wilaya` permet une lecture rapide des statistiques d’une région.

Le clustering sur `date_heure DESC` facilite l’affichage des dernières données.

### Risque de Hot Partition ?

Le risque est faible car :

- les données sont déjà agrégées
- le volume est réduit

---

# 2. Pourquoi ALLOW FILTERING est dangereux en production

Exemple :

```sql
SELECT * FROM mesures_par_capteur
WHERE tension_v < 200 ALLOW FILTERING;
```

## Problème

La colonne `tension_v` ne fait pas partie de la clé primaire.

Cassandra doit donc :

- scanner toutes les partitions
- lire énormément de données
- filtrer les résultats après lecture

Cela provoque :

- requêtes lentes
- surcharge CPU
- forte consommation mémoire
- mauvaise scalabilité

---

## Pourquoi c’est dangereux à grande échelle ?

Dans ce TP :

- 10 000 capteurs
- plusieurs millions de lignes

Avec `ALLOW FILTERING`, Cassandra peut parcourir toute la base pour répondre à une seule requête.

Le temps de réponse devient très mauvais.

---

## Bonne pratique

Dans Cassandra :

> "Model your queries, not your entities"

Il faut créer une table adaptée à chaque requête importante.

Exemple correct :

```sql
SELECT *
FROM alertes_par_wilaya
WHERE code_alerte = 'LOW_VOLTAGE'
  AND date_jour = toDate(now());
```

Ou créer une table spécialisée comme :

```sql
alertes_par_type
```

Ainsi Cassandra lit uniquement les partitions nécessaires.

---

# 3. Comparaison TWCS vs STCS vs LCS

| Stratégie | Utilisation | Avantages | Inconvénients |
|------------|-------------|------------|----------------|
| TWCS | Séries temporelles / IoT | Optimisé pour TTL et données récentes | Peu adapté aux updates |
| STCS | Écritures massives générales | Très bonnes performances d’écriture | Lectures moins efficaces |
| LCS | Applications orientées lecture | Lectures rapides et stables | Compaction coûteuse |

---

## TWCS — TimeWindowCompactionStrategy

### Principe

Les SSTables sont regroupées par fenêtre temporelle :

- heure
- jour
- semaine

Dans le TP :

```sql
ALTER TABLE mesures_par_capteur
WITH compaction = {
  'class': 'TimeWindowCompactionStrategy',
  'compaction_window_unit': 'DAYS',
  'compaction_window_size': 1
};
```

Les données sont compactées par jour.

### Quand utiliser TWCS ?

TWCS est idéal pour :

- IoT
- logs
- monitoring
- séries temporelles
- données avec TTL

### Pourquoi TWCS dans ce TP ?

Les mesures :

- sont insérées chronologiquement
- expirent après 90 jours
- sont rarement modifiées

TWCS améliore :

- les performances d’écriture
- la suppression automatique des anciennes données
- la gestion des tombstones

---

## STCS — SizeTieredCompactionStrategy

### Principe

Cassandra fusionne les SSTables de taille similaire.

### Quand utiliser STCS ?

Pour :

- charges d’écriture importantes
- workloads généraux
- données non temporelles

### Avantages

- écritures rapides
- faible coût de compaction

### Inconvénients

- lectures moins performantes
- plus de fragmentation

---

## LCS — LeveledCompactionStrategy

### Principe

Les SSTables sont organisées par niveaux.

Chaque donnée existe dans un nombre limité de fichiers.

### Quand utiliser LCS ?

Pour :

- applications orientées lecture
- APIs temps réel
- recherches fréquentes

### Avantages

- lectures rapides
- latence stable

### Inconvénients

- compaction plus lourde
- plus d’I/O disque
- écritures plus lentes

---

# Conclusion

Pour SmartGrid DZ :

- `TWCS` est le meilleur choix pour les mesures IoT
- `STCS` convient aux workloads orientés écriture
- `LCS` est adapté aux systèmes orientés lecture

Le modèle Cassandra utilisé respecte la règle :

> "Model your queries, not your entities"

Chaque table est conçue selon les requêtes réelles afin d’obtenir de bonnes performances et une meilleure scalabilité.
