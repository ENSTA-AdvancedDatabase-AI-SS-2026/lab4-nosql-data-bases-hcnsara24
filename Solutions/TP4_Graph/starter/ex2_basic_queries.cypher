// TP4 - Exercice 2 : Requêtes de Base
// Fichier : starter/ex2_basic_queries.cypher


// ─────────────────────────────────────────────────────────────
// 2.1 Trouver tous les amis d'Ahmed (1 saut)
// ─────────────────────────────────────────────────────────────
MATCH (a:Etudiant {prenom:"Ahmed"})-[:CONNAIT]-(ami:Etudiant)

RETURN ami.prenom,
       ami.nom,
       ami.universite,
       ami.filiere;


// ─────────────────────────────────────────────────────────────
// 2.2 Trouver les amis d'amis d'Ahmed
// qui ne sont pas déjà ses amis
// ─────────────────────────────────────────────────────────────
MATCH (a:Etudiant {prenom:"Ahmed"})-[:CONNAIT*2]-(suggestion:Etudiant)

WHERE NOT (a)-[:CONNAIT]-(suggestion)
  AND a <> suggestion

RETURN DISTINCT
       suggestion.prenom,
       suggestion.nom,
       suggestion.universite,
       suggestion.filiere

LIMIT 10;


// ─────────────────────────────────────────────────────────────
// 2.3 Étudiants qui suivent le même cours que Fatima
// mais ne la connaissent pas
// ─────────────────────────────────────────────────────────────
MATCH (f:Etudiant {prenom:"Fatima"})-[:SUIT]->(c:Cours)<-[:SUIT]-(e:Etudiant)

WHERE NOT (f)-[:CONNAIT]-(e)
  AND f <> e

RETURN DISTINCT
       e.prenom,
       e.nom,
       c.intitule AS cours;


// ─────────────────────────────────────────────────────────────
// 2.4 Clubs les plus populaires
// (par nombre de membres)
// ─────────────────────────────────────────────────────────────
MATCH (e:Etudiant)-[:MEMBRE_DE]->(cl:Club)

RETURN cl.nom AS club,
       cl.universite AS universite,
       COUNT(e) AS nb_membres

ORDER BY nb_membres DESC;


// ─────────────────────────────────────────────────────────────
// 2.5 Profil complet d'un étudiant
// amis, cours, compétences, clubs
// ─────────────────────────────────────────────────────────────
MATCH (e:Etudiant {prenom:"Ahmed"})

OPTIONAL MATCH (e)-[:CONNAIT]-(ami:Etudiant)
OPTIONAL MATCH (e)-[:SUIT]->(cours:Cours)
OPTIONAL MATCH (e)-[:MAITRISE]->(comp:Competence)
OPTIONAL MATCH (e)-[:MEMBRE_DE]->(club:Club)

RETURN
e.prenom AS etudiant,

COLLECT(DISTINCT ami.prenom) AS amis,

COLLECT(DISTINCT cours.intitule) AS cours,

COLLECT(DISTINCT comp.nom) AS competences,

COLLECT(DISTINCT club.nom) AS clubs;
