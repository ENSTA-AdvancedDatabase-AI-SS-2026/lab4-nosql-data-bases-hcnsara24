-- TP3 - Exercice 3 : Requêtes CQL
USE smartgrid;

-- ─────────────────────────────────────────────────────────────
-- 3.1 Mesures d'un capteur spécifique sur les dernières 6 heures
-- ─────────────────────────────────────────────────────────────
SELECT *
FROM mesures_par_capteur
WHERE capteur_id = ?
  AND date_jour = ?
  AND timestamp >= ?;

-- ✔ Explication :
-- Cassandra oblige la partition complète (capteur_id + date_jour)


-- ─────────────────────────────────────────────────────────────
-- 3.2 Dernière mesure de chaque capteur d'une wilaya
-- ─────────────────────────────────────────────────────────────
-- (nécessite table adaptée → approximation ici)

SELECT *
FROM mesures_par_capteur
WHERE capteur_id = ?
LIMIT 1;

-- ✔ Astuce : CLUSTERING ORDER BY DESC permet de récupérer la dernière mesure


-- ─────────────────────────────────────────────────────────────
-- 3.3 Capteurs en alerte dans "Alger" aujourd'hui
-- ─────────────────────────────────────────────────────────────
SELECT COUNT(*), capteur_id
FROM alertes_par_wilaya
WHERE wilaya = 'Alger'
  AND date_jour = toDate(now());

-- ✔ Peut aussi être listé :
SELECT *
FROM alertes_par_wilaya
WHERE wilaya = 'Alger'
  AND date_jour = toDate(now());


-- ─────────────────────────────────────────────────────────────
-- 3.4 Consommation totale par heure (dashboard)
-- ─────────────────────────────────────────────────────────────
SELECT wilaya, date_heure, puissance_moy_kw, nb_capteurs
FROM agregats_horaires
WHERE wilaya = 'Alger'
  AND date_heure >= minTimeuuid(now() - 86400000);

-- ✔ Normalement déjà pré-agrégé → pas de SUM en Cassandra


-- ─────────────────────────────────────────────────────────────
-- 3.5 Détection d'anomalie (30 dernières minutes)
-- ─────────────────────────────────────────────────────────────
SELECT *
FROM mesures_par_capteur
WHERE date_jour = toDate(now());

-- ✔ Filtrage côté application recommandé
-- Cassandra ne supporte pas efficacement < 200 OR > 240


-- ─────────────────────────────────────────────────────────────
-- 3.6 Top 10 capteurs les plus actifs (semaine)
-- ─────────────────────────────────────────────────────────────
-- ❌ Cassandra ne fait PAS d'agrégation avancée comme SQL

-- Solution correcte :
-- → table dédiée ou traitement application

SELECT capteur_id
FROM mesures_par_capteur
WHERE date_jour >= toDate(now() - 7);


-- ─────────────────────────────────────────────────────────────
-- 3.7 ALLOW FILTERING (à éviter)
-- ─────────────────────────────────────────────────────────────

-- ❌ Mauvaise requête :
SELECT * FROM mesures_par_capteur
WHERE tension_v < 200 ALLOW FILTERING;

-- ❗ Pourquoi éviter :
-- - scan complet de toutes les partitions
-- - très lent (O(N))
-- - non scalable

-- ✔ Bonne approche :
-- Utiliser table alertes déjà filtrée :
SELECT *
FROM alertes_par_wilaya
WHERE code_alerte = 'LOW_VOLTAGE'
  AND date_jour = toDate(now());
