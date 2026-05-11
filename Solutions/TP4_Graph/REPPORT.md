# RAPPORT.md

# TP4 — Neo4j : Réseau Social Universitaire
## UniConnect DZ

---

# 1. Schéma du graphe

Le graphe modélise un réseau social universitaire algérien.

## Types de nœuds

- `Etudiant`
- `Cours`
- `Club`
- `Entreprise`
- `Competence`

## Types de relations

- `CONNAIT`
- `SUIT`
- `MEMBRE_DE`
- `MAITRISE`
- `REQUIERT`
- `A_STAGE_CHEZ`

---

## Capture du graphe

Capture réalisée depuis Neo4j Browser avec :

```cypher
MATCH (n)
RETURN n
LIMIT 100;
```

> Ajouter ici la capture d’écran du graphe affiché dans Neo4j Browser.

---

# 2. Résultats de l’algorithme de communautés (Louvain)

L’algorithme Louvain a été exécuté avec Graph Data Science (GDS).

## Requête utilisée

```cypher
CALL gds.louvain.stream('reseau_social')

YIELD nodeId, communityId

RETURN
gds.util.asNode(nodeId).prenom AS etudiant,
communityId;
```

---

## Communautés détectées

L’algorithme a détecté plusieurs groupes d’étudiants fortement connectés.

### Exemple de communautés observées

| Communauté | Caractéristiques |
|---|---|
| Communauté 1 | Étudiants de l’USTHB en Informatique |
| Communauté 2 | Étudiants de l’UMBB et Télécom |
| Communauté 3 | Membres des clubs IA et Dev |
| Communauté 4 | Étudiants partageant les mêmes cours |
| Communauté 5 | Étudiants connectés par compétences communes |

---

## Analyse

Les communautés détectées correspondent principalement :

- aux universités
- aux filières
- aux clubs étudiants
- aux relations sociales existantes

Les étudiants ayant beaucoup de connexions servent souvent de pont entre plusieurs communautés.

L’algorithme Louvain permet donc d’identifier automatiquement les “cercles sociaux” du réseau universitaire.

---

# 3. Comparaison SQL vs Cypher

## Requête étudiée

Trouver les amis d’amis d’Ahmed.

---

# Version Cypher

```cypher
MATCH (a:Etudiant {prenom:"Ahmed"})-[:CONNAIT*2]-(suggestion)

WHERE NOT (a)-[:CONNAIT]-(suggestion)

RETURN suggestion;
```

---

# Version SQL

```sql
SELECT DISTINCT e2.*
FROM etudiant e1
JOIN connait k1 ON e1.id = k1.id1
JOIN etudiant ami ON ami.id = k1.id2
JOIN connait k2 ON ami.id = k2.id1
JOIN etudiant e2 ON e2.id = k2.id2
WHERE e1.prenom = 'Ahmed'
AND e2.id NOT IN (
  SELECT id2
  FROM connait
  WHERE id1 = e1.id
);
```

---

# Comparaison

| Critère | SQL | Cypher |
|---|---|---|
| Lisibilité | Complexe avec plusieurs JOINs | Très lisible |
| Complexité | Augmente rapidement avec les relations | Naturel pour les graphes |
| Parcours relationnel | Peu pratique | Optimisé |
| Maintenance | Plus difficile | Plus simple |
| Performance graphe | Faible avec beaucoup de JOINs | Très efficace |

---

## Analyse

Dans une base relationnelle, les relations nécessitent plusieurs `JOIN`.

Plus le nombre de connexions augmente :

- plus la requête devient complexe
- plus les performances diminuent

Avec Neo4j et Cypher :

- les relations sont stockées directement dans le graphe
- les parcours sont naturels et rapides
- le code reste court et lisible

Cypher est donc beaucoup mieux adapté aux :

- réseaux sociaux
- systèmes de recommandation
- graphes de connaissances
- chemins et communautés

---

# Conclusion

Neo4j facilite énormément la modélisation des données connectées.

Dans ce TP :

- le graphe représente efficacement le réseau étudiant
- Cypher simplifie les requêtes relationnelles
- les algorithmes GDS permettent d’analyser les communautés et connexions

Les bases graphes sont particulièrement adaptées aux applications où les relations entre données sont importantes.
