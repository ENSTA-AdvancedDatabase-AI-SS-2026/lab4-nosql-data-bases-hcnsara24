# RAPPORT — TP1 Redis

## 1. Comparaison de performance

Le cache Redis améliore fortement les performances.

- Cache MISS : environ 2000 ms
- Cache HIT : quelques millisecondes

Le cache réduit donc considérablement le temps de réponse.

---

## 2. Justification des choix de modélisation

- Hash : utilisé pour stocker les produits et paniers
- List : utilisée pour l’historique de navigation
- Set : utilisé pour les catégories
- Sorted Set : utilisé pour le classement des ventes

Chaque structure Redis a été choisie selon le type de données et les opérations nécessaires.

---

## 3. Questions de réflexion

### Q1. Que se passe-t-il si Redis redémarre ?

Redis stocke les données en mémoire RAM.  
Sans persistance, les données peuvent être perdues après un redémarrage.

---

### Q2. Comment gérer la cohérence cache/DB ?

On peut invalider le cache après chaque mise à jour de la base de données ou utiliser des transactions.

---

### Q3. Quand un TTL trop court est-il problématique ?

Un TTL trop court provoque des expirations fréquentes du cache et augmente les accès à la base de données.
