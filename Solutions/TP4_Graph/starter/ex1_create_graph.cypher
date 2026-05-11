// TP4 - Exercice 1 : Création du graphe UniConnect DZ

// ─────────────────────────────────────────────────────────────
// Nettoyage
// ─────────────────────────────────────────────────────────────
MATCH (n) DETACH DELETE n;

// ─────────────────────────────────────────────────────────────
// 1.1 Contraintes
// ─────────────────────────────────────────────────────────────
CREATE CONSTRAINT etudiant_id IF NOT EXISTS
FOR (e:Etudiant)
REQUIRE e.id IS UNIQUE;

CREATE CONSTRAINT cours_code IF NOT EXISTS
FOR (c:Cours)
REQUIRE c.code IS UNIQUE;

CREATE CONSTRAINT competence_nom IF NOT EXISTS
FOR (c:Competence)
REQUIRE c.nom IS UNIQUE;


// ─────────────────────────────────────────────────────────────
// 1.2 Compétences
// ─────────────────────────────────────────────────────────────
UNWIND [
  {nom: "Python", categorie: "Programmation"},
  {nom: "Java", categorie: "Programmation"},
  {nom: "SQL", categorie: "BDD"},
  {nom: "NoSQL", categorie: "BDD"},
  {nom: "Machine Learning", categorie: "IA"},
  {nom: "Deep Learning", categorie: "IA"},
  {nom: "React", categorie: "Web"},
  {nom: "Docker", categorie: "DevOps"},
  {nom: "Linux", categorie: "Systèmes"},
  {nom: "Réseaux", categorie: "Infrastructure"}
] AS comp

MERGE (:Competence {
  nom: comp.nom,
  categorie: comp.categorie
});


// ─────────────────────────────────────────────────────────────
// 1.3 Cours
// ─────────────────────────────────────────────────────────────
UNWIND [
  {code: "INFO401", intitule: "BDD Avancées", credits: 6, dept: "INFO"},
  {code: "INFO402", intitule: "Intelligence Artificielle", credits: 6, dept: "INFO"},
  {code: "INFO403", intitule: "Développement Web", credits: 4, dept: "INFO"},
  {code: "INFO404", intitule: "Systèmes Distribués", credits: 5, dept: "INFO"},
  {code: "INFO405", intitule: "Cloud Computing", credits: 4, dept: "INFO"}
] AS cours

MERGE (:Cours {
  code: cours.code,
  intitule: cours.intitule,
  credits: cours.credits,
  departement: cours.dept
});


// ─────────────────────────────────────────────────────────────
// Clubs
// ─────────────────────────────────────────────────────────────
UNWIND [
  {nom: "Club IA", universite: "USTHB", domaine: "IA"},
  {nom: "Club Robotique", universite: "UMBB", domaine: "Robotique"},
  {nom: "Club Dev", universite: "USTO", domaine: "Développement"},
  {nom: "Club Cyber", universite: "UMC", domaine: "Cybersécurité"},
  {nom: "Club Web", universite: "UBMA", domaine: "Web"}
] AS club

MERGE (:Club {
  nom: club.nom,
  universite: club.universite,
  domaine: club.domaine
});


// ─────────────────────────────────────────────────────────────
// Entreprises
// ─────────────────────────────────────────────────────────────
UNWIND [
  {nom: "Sonatrach", secteur: "Energie", ville: "Alger"},
  {nom: "Mobilis", secteur: "Télécom", ville: "Alger"},
  {nom: "Ooredoo", secteur: "Télécom", ville: "Alger"},
  {nom: "CERIST", secteur: "Recherche", ville: "Alger"}
] AS ent

MERGE (:Entreprise {
  nom: ent.nom,
  secteur: ent.secteur,
  ville: ent.ville
});


// ─────────────────────────────────────────────────────────────
// 1.4 Étudiants
// ─────────────────────────────────────────────────────────────
UNWIND [

{id:"E001", prenom:"Ahmed", nom:"Bensalem", universite:"USTHB", filiere:"Informatique", annee:3, ville:"Alger"},
{id:"E002", prenom:"Fatima", nom:"Ouali", universite:"USTHB", filiere:"GL", annee:2, ville:"Alger"},
{id:"E003", prenom:"Yasmine", nom:"Kaci", universite:"USTHB", filiere:"Télécom", annee:4, ville:"Alger"},
{id:"E004", prenom:"Karim", nom:"Messaoud", universite:"USTHB", filiere:"Electronique", annee:3, ville:"Alger"},
{id:"E005", prenom:"Imane", nom:"Bouzid", universite:"USTHB", filiere:"Mathématiques", annee:1, ville:"Alger"},

{id:"E006", prenom:"Sofiane", nom:"Rahmani", universite:"UMBB", filiere:"Informatique", annee:2, ville:"Boumerdes"},
{id:"E007", prenom:"Lina", nom:"Benaissa", universite:"UMBB", filiere:"GL", annee:4, ville:"Boumerdes"},
{id:"E008", prenom:"Walid", nom:"Cherif", universite:"UMBB", filiere:"Télécom", annee:3, ville:"Boumerdes"},
{id:"E009", prenom:"Aya", nom:"Hamdi", universite:"UMBB", filiere:"Electronique", annee:2, ville:"Boumerdes"},
{id:"E010", prenom:"Nadir", nom:"Touati", universite:"UMBB", filiere:"Mathématiques", annee:1, ville:"Boumerdes"},

{id:"E011", prenom:"Samir", nom:"Meziane", universite:"USTO", filiere:"Informatique", annee:3, ville:"Oran"},
{id:"E012", prenom:"Sara", nom:"Benali", universite:"USTO", filiere:"GL", annee:2, ville:"Oran"},
{id:"E013", prenom:"Rania", nom:"Brahimi", universite:"USTO", filiere:"Télécom", annee:4, ville:"Oran"},
{id:"E014", prenom:"Yacine", nom:"Dib", universite:"USTO", filiere:"Electronique", annee:3, ville:"Oran"},
{id:"E015", prenom:"Meriem", nom:"Zeroual", universite:"USTO", filiere:"Mathématiques", annee:1, ville:"Oran"},

{id:"E016", prenom:"Hocine", nom:"Boukhalfa", universite:"UMC", filiere:"Informatique", annee:4, ville:"Constantine"},
{id:"E017", prenom:"Nesrine", nom:"Bettahar", universite:"UMC", filiere:"GL", annee:2, ville:"Constantine"},
{id:"E018", prenom:"Anis", nom:"Ferhat", universite:"UMC", filiere:"Télécom", annee:3, ville:"Constantine"},
{id:"E019", prenom:"Kenza", nom:"Mokrani", universite:"UMC", filiere:"Electronique", annee:2, ville:"Constantine"},
{id:"E020", prenom:"Reda", nom:"Belaid", universite:"UMC", filiere:"Mathématiques", annee:1, ville:"Constantine"},

{id:"E021", prenom:"Amina", nom:"Saidi", universite:"UBMA", filiere:"Informatique", annee:3, ville:"Annaba"},
{id:"E022", prenom:"Bilal", nom:"Gherbi", universite:"UBMA", filiere:"GL", annee:2, ville:"Annaba"},
{id:"E023", prenom:"Ilyes", nom:"Khene", universite:"UBMA", filiere:"Télécom", annee:4, ville:"Annaba"},
{id:"E024", prenom:"Farah", nom:"Mansouri", universite:"UBMA", filiere:"Electronique", annee:3, ville:"Annaba"},
{id:"E025", prenom:"Omar", nom:"Rezgui", universite:"UBMA", filiere:"Mathématiques", annee:1, ville:"Annaba"},

{id:"E026", prenom:"Hakim", nom:"Alloui", universite:"USTHB", filiere:"Informatique", annee:2, ville:"Alger"},
{id:"E027", prenom:"Dina", nom:"Khelifi", universite:"USTHB", filiere:"GL", annee:3, ville:"Alger"},
{id:"E028", prenom:"Amine", nom:"Bouaziz", universite:"USTHB", filiere:"Télécom", annee:4, ville:"Alger"},
{id:"E029", prenom:"Melissa", nom:"Touil", universite:"USTHB", filiere:"Electronique", annee:2, ville:"Alger"},
{id:"E030", prenom:"Younes", nom:"Merabet", universite:"USTHB", filiere:"Mathématiques", annee:1, ville:"Alger"},

{id:"E031", prenom:"Zineb", nom:"Boudiaf", universite:"UMBB", filiere:"Informatique", annee:3, ville:"Boumerdes"},
{id:"E032", prenom:"Nassim", nom:"Boulahbel", universite:"UMBB", filiere:"GL", annee:2, ville:"Boumerdes"},
{id:"E033", prenom:"Lyes", nom:"Tebbal", universite:"UMBB", filiere:"Télécom", annee:4, ville:"Boumerdes"},
{id:"E034", prenom:"Asma", nom:"Moussaoui", universite:"UMBB", filiere:"Electronique", annee:3, ville:"Boumerdes"},
{id:"E035", prenom:"Khaled", nom:"Benhamou", universite:"UMBB", filiere:"Mathématiques", annee:1, ville:"Boumerdes"},

{id:"E036", prenom:"Rim", nom:"Ziani", universite:"USTO", filiere:"Informatique", annee:2, ville:"Oran"},
{id:"E037", prenom:"Islam", nom:"Berrabah", universite:"USTO", filiere:"GL", annee:3, ville:"Oran"},
{id:"E038", prenom:"Nour", nom:"Khelaf", universite:"USTO", filiere:"Télécom", annee:4, ville:"Oran"},
{id:"E039", prenom:"Tarek", nom:"Amrani", universite:"USTO", filiere:"Electronique", annee:2, ville:"Oran"},
{id:"E040", prenom:"Hind", nom:"Zeggar", universite:"USTO", filiere:"Mathématiques", annee:1, ville:"Oran"},

{id:"E041", prenom:"Rayane", nom:"Derradji", universite:"UMC", filiere:"Informatique", annee:3, ville:"Constantine"},
{id:"E042", prenom:"Loubna", nom:"Ait Ali", universite:"UMC", filiere:"GL", annee:2, ville:"Constantine"},
{id:"E043", prenom:"Salim", nom:"Bensaci", universite:"UMC", filiere:"Télécom", annee:4, ville:"Constantine"},
{id:"E044", prenom:"Nadia", nom:"Gacem", universite:"UMC", filiere:"Electronique", annee:3, ville:"Constantine"},
{id:"E045", prenom:"Yahia", nom:"Kherfi", universite:"UMC", filiere:"Mathématiques", annee:1, ville:"Constantine"},

{id:"E046", prenom:"Abir", nom:"Mekki", universite:"UBMA", filiere:"Informatique", annee:2, ville:"Annaba"},
{id:"E047", prenom:"Mourad", nom:"Chaib", universite:"UBMA", filiere:"GL", annee:3, ville:"Annaba"},
{id:"E048", prenom:"Racha", nom:"Benyoucef", universite:"UBMA", filiere:"Télécom", annee:4, ville:"Annaba"},
{id:"E049", prenom:"Adel", nom:"Boudjemaa", universite:"UBMA", filiere:"Electronique", annee:2, ville:"Annaba"},
{id:"E050", prenom:"Sihem", nom:"Mecheri", universite:"UBMA", filiere:"Mathématiques", annee:1, ville:"Annaba"}

] AS data

MERGE (e:Etudiant {id: data.id})
SET e += data;


// ─────────────────────────────────────────────────────────────
// 1.5 Relations CONNAIT
// Graphe connexe
// ─────────────────────────────────────────────────────────────
MATCH (e1:Etudiant), (e2:Etudiant)
WHERE toInteger(substring(e2.id,1)) = toInteger(substring(e1.id,1)) + 1
MERGE (e1)-[:CONNAIT {
  depuis: 2023,
  contexte: "Université"
}]->(e2);


// ─────────────────────────────────────────────────────────────
// Relations SUIT
// ─────────────────────────────────────────────────────────────
MATCH (e:Etudiant), (c:Cours)
WHERE c.code IN ["INFO401","INFO402"]

MERGE (e)-[:SUIT {
  semestre: 2,
  note: 10 + toInteger(rand()*10)
}]->(c);


// ─────────────────────────────────────────────────────────────
// Relations MEMBRE_DE
// ─────────────────────────────────────────────────────────────
MATCH (e:Etudiant), (cl:Club)
WHERE e.universite = cl.universite

MERGE (e)-[:MEMBRE_DE {
  role: "Membre"
}]->(cl);


// ─────────────────────────────────────────────────────────────
// Relations MAITRISE
// ─────────────────────────────────────────────────────────────
MATCH (e:Etudiant), (co:Competence)

WHERE
(e.filiere = "Informatique" AND co.nom IN ["Python","Java","SQL"])
OR
(e.filiere = "GL" AND co.nom IN ["React","Docker"])
OR
(e.filiere = "Télécom" AND co.nom IN ["Réseaux","Linux"])
OR
(e.filiere = "Electronique" AND co.nom IN ["Python","Machine Learning"])
OR
(e.filiere = "Mathématiques" AND co.nom IN ["SQL","Machine Learning"])

MERGE (e)-[:MAITRISE {
  niveau: "Intermédiaire"
}]->(co);


// ─────────────────────────────────────────────────────────────
// Relations Cours → Compétences
// ─────────────────────────────────────────────────────────────
MATCH (c:Cours {code:"INFO401"}), (co:Competence {nom:"SQL"})
MERGE (c)-[:REQUIERT]->(co);

MATCH (c:Cours {code:"INFO402"}), (co:Competence {nom:"Machine Learning"})
MERGE (c)-[:REQUIERT]->(co);

MATCH (c:Cours {code:"INFO403"}), (co:Competence {nom:"React"})
MERGE (c)-[:REQUIERT]->(co);

MATCH (c:Cours {code:"INFO404"}), (co:Competence {nom:"Docker"})
MERGE (c)-[:REQUIERT]->(co);

MATCH (c:Cours {code:"INFO405"}), (co:Competence {nom:"Linux"})
MERGE (c)-[:REQUIERT]->(co);


// ─────────────────────────────────────────────────────────────
// Import CSV
// ─────────────────────────────────────────────────────────────
LOAD CSV WITH HEADERS
FROM 'file:///students.csv' AS row

MERGE (e:Etudiant {id: row.id})

SET e.prenom = row.prenom,
    e.nom = row.nom,
    e.universite = row.universite,
    e.filiere = row.filiere,
    e.annee = toInteger(row.annee),
    e.ville = row.ville;


// ─────────────────────────────────────────────────────────────
// Vérification
// ─────────────────────────────────────────────────────────────
MATCH (n)
RETURN labels(n)[0] AS type,
       count(n) AS total
ORDER BY total DESC;

MATCH ()-[r]->()
RETURN type(r) AS relation,
       count(r) AS total
ORDER BY total DESC;
