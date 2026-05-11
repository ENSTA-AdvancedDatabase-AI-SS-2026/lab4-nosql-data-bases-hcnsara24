// TP4 - Exercice 4 : Requêtes Avancées
// Fichier : starter/ex4_advanced.cypher


// ─────────────────────────────────────────────────────────────
// 4.1 Trouver un tuteur
// Étudiant qui :
// - maîtrise Python
// - a eu >14 en BDD
// - niveau Master (année >= 4)
// ─────────────────────────────────────────────────────────────
MATCH (e:Etudiant)-[:MAITRISE]->(comp:Competence {nom:"Python"})

MATCH (e)-[s:SUIT]->(c:Cours {code:"INFO401"})

WHERE s.note > 14
  AND e.annee >= 4

RETURN
e.prenom,
e.nom,
e.universite,
s.note AS note_BDD

ORDER BY note_BDD DESC;


// ─────────────────────────────────────────────────────────────
// 4.2 Réseau alumni dans une entreprise
// Qui dans le réseau d'Ahmed travaille chez Sonatrach ?
// Jusqu'à 3 sauts
// ─────────────────────────────────────────────────────────────
MATCH (ahmed:Etudiant {prenom:"Ahmed"})-[:CONNAIT*1..3]-(personne)

MATCH (personne)-[:A_STAGE_CHEZ]->(ent:Entreprise {nom:"Sonatrach"})

RETURN DISTINCT
personne.prenom,
personne.nom,
personne.universite,
ent.nom AS entreprise;


// ─────────────────────────────────────────────────────────────
// 4.3 Détection de ponts
// Étudiants connectant plusieurs communautés
// Approximation avec nombre élevé de connexions
// ─────────────────────────────────────────────────────────────
MATCH (e:Etudiant)-[:CONNAIT]-(ami)

WITH e,
COUNT(DISTINCT ami) AS nb_connexions,
COLLECT(DISTINCT ami.universite) AS universites

WHERE size(universites) > 1

RETURN
e.prenom,
e.nom,
nb_connexions,
universites

ORDER BY nb_connexions DESC

LIMIT 10;


// ─────────────────────────────────────────────────────────────
// 4.4 Analyse temporelle
// Nombre de nouvelles connexions par année
// ─────────────────────────────────────────────────────────────
MATCH ()-[r:CONNAIT]->()

RETURN
r.depuis AS annee,
COUNT(r) AS nouvelles_connexions

ORDER BY annee;


// ─────────────────────────────────────────────────────────────
// 4.5 Score de similarité
// Étudiants similaires à Ahmed
// Jaccard simplifié
// ─────────────────────────────────────────────────────────────

// Compétences communes
MATCH (ahmed:Etudiant {prenom:"Ahmed"})-[:MAITRISE]->(comp)<-[:MAITRISE]-(autre:Etudiant)

WHERE ahmed <> autre

WITH ahmed, autre,
COUNT(DISTINCT comp) AS competences_communes


// Cours communs
OPTIONAL MATCH (ahmed)-[:SUIT]->(cours)<-[:SUIT]-(autre)

WITH ahmed, autre,
competences_communes,
COUNT(DISTINCT cours) AS cours_communs


// Clubs communs
OPTIONAL MATCH (ahmed)-[:MEMBRE_DE]->(club)<-[:MEMBRE_DE]-(autre)

WITH autre,
competences_communes,
cours_communs,
COUNT(DISTINCT club) AS clubs_communs


// Score de similarité
WITH autre,

(competences_communes +
cours_communs +
clubs_communs) AS intersection,

10 AS union_total


RETURN
autre.prenom AS etudiant,
ROUND( (toFloat(intersection) / union_total) * 100 , 2) AS similarite_pourcent

ORDER BY similarite_pourcent DESC

LIMIT 10;
