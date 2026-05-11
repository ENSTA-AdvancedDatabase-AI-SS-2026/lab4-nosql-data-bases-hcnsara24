# TP2 — MongoDB : HealthCare DZ

## 1. Choix du modèle : Embedding vs Referencing

### ✔ Embedding (patients → consultations)
Nous avons choisi l’embedding pour les consultations car :
- Les consultations sont souvent consultées avec le patient
- Permet un accès rapide en une seule requête
- Réduit le besoin de JOIN ($lookup)

➡ Avantage : performance élevée pour lecture
➡ Inconvénient : document peut devenir volumineux

---

### ✔ Referencing (patients → analyses)
Nous avons choisi le referencing pour les analyses car :
- Les analyses peuvent être nombreuses et volumineuses
- Elles évoluent indépendamment du patient
- Permet une meilleure scalabilité

➡ Avantage : structure légère et flexible
➡ Inconvénient : nécessite $lookup pour jointure

---

## 2. Indexation et optimisation

### Index créés :
- Wilaya + antécédents
- Date de consultation
- Texte sur diagnostics
- patient_id dans analyses
- TTL sur analyses

---

### Comparaison explain()

| Requête | Sans index | Avec index |
|--------|-----------|------------|
| nReturned | élevé scan | optimisé |
| totalDocsExamined | très élevé | réduit |
| executionTimeMillis | lent | rapide |

➡ Conclusion : les index réduisent fortement le coût des requêtes

---

## 3. Pipeline le plus complexe : 3.5 - Rapport médecins

### Étapes du pipeline :

1. `$unwind consultations`
   → transforme chaque consultation en document individuel

2. `$group par médecin`
   → calcule :
   - nombre total de consultations
   - ensemble des patients uniques

3. `$addFields`
   → calcule taux de ré-consultation :

4. `$sort`
→ trie les médecins les plus actifs

5. `$limit`
→ garde top 5 médecins

---

## ✔ Conclusion

MongoDB est très efficace pour :
- les données médicales structurées en documents
- les requêtes analytiques avec aggregation pipeline
- la flexibilité des données semi-structurées

Le modèle documentaire est plus adapté que le relationnel pour ce type de système.
