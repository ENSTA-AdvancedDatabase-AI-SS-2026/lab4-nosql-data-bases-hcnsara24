// TP4 - Exercice 3 : Algorithmes de Graphe avec GDS
// Fichier : starter/ex3_graph_algorithms.cypher


// ─────────────────────────────────────────────────────────────
// 3.1 Plus court chemin entre deux étudiants
// "Comment Ahmed peut-il rencontrer Yasmina ?"
// ─────────────────────────────────────────────────────────────
MATCH p = shortestPath(
  (a:Etudiant {prenom: "Ahmed"})-[:CONNAIT*..10]-
  (b:Etudiant {prenom: "Yasmine"})
)

RETURN
[n IN nodes(p) |
 n.prenom + " (" + n.universite + ")"] AS chemin,

length(p) AS distance;


// ─────────────────────────────────────────────────────────────
// 3.2 Centralité de degré
// Étudiants les plus connectés
// ─────────────────────────────────────────────────────────────

// Création projection mémoire
CALL gds.graph.project(
  'reseau_social',
  'Etudiant',
  'CONNAIT'
);


// Calcul centralité
CALL gds.degree.stream('reseau_social')

YIELD nodeId, score

RETURN
gds.util.asNode(nodeId).prenom AS etudiant,

gds.util.asNode(nodeId).universite AS universite,

score AS nb_connexions

ORDER BY nb_connexions DESC

LIMIT 10;


// ─────────────────────────────────────────────────────────────
// 3.3 Détection de communautés (Louvain)
// ─────────────────────────────────────────────────────────────
CALL gds.louvain.stream('reseau_social')

YIELD nodeId, communityId

WITH
communityId,
collect(gds.util.asNode(nodeId).prenom) AS membres

RETURN
communityId,

size(membres) AS taille,

membres[0..5] AS exemple_membres

ORDER BY taille DESC;


// ─────────────────────────────────────────────────────────────
// 3.4 Recommandation de contacts
// Critères :
// - amis communs
// - cours en commun
// - même filière
// ─────────────────────────────────────────────────────────────
MATCH (moi:Etudiant {prenom:"Ahmed"})
MATCH (suggestion:Etudiant)

WHERE moi <> suggestion
  AND NOT (moi)-[:CONNAIT]-(suggestion)


// Amis communs
OPTIONAL MATCH (moi)-[:CONNAIT]-(amiCommun)-[:CONNAIT]-(suggestion)

WITH moi, suggestion,
COUNT(DISTINCT amiCommun) AS nb_amis_communs


// Cours communs
OPTIONAL MATCH (moi)-[:SUIT]->(coursCommun:Cours)<-[:SUIT]-(suggestion)

WITH moi, suggestion,
nb_amis_communs,
COUNT(DISTINCT coursCommun) AS nb_cours_communs


// Calcul score
WITH suggestion,
nb_amis_communs,
nb_cours_communs,

CASE
WHEN suggestion.filiere = "Informatique"
THEN 1
ELSE 0
END AS meme_filiere


WITH suggestion,

(nb_amis_communs * 3) +
(nb_cours_communs * 2) +
meme_filiere AS score

RETURN
suggestion.prenom AS suggestion,
suggestion.universite AS universite,
score

ORDER BY score DESC

LIMIT 5;


// ─────────────────────────────────────────────────────────────
// 3.5 Chemin de compétences
// "Quels cours suivre pour Machine Learning ?"
// ─────────────────────────────────────────────────────────────
MATCH path =
(c:Cours)-[:REQUIERT]->(comp:Competence {nom:"Machine Learning"})

RETURN
c.intitule AS cours,
comp.nom AS competence;


// ─────────────────────────────────────────────────────────────
// Nettoyage projection mémoire
// ─────────────────────────────────────────────────────────────
CALL gds.graph.drop('reseau_social');
