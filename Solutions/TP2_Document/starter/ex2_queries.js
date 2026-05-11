/**
 * TP2 - Exercice 2 : Requêtes de Base
 * Use Case : HealthCare DZ - Dossiers Médicaux
 */

use("medical_db");

// ─── 2.1 : Patients diabétiques de plus de 50 ans à Alger ─────────────────────
print("=== 2.1 Diabétiques > 50 ans à Alger ===");

db.patients.find({
  "adresse.wilaya": "Alger",
  antecedents: "Diabète type 2",
  dateNaissance: {
    $lte: new Date(new Date().setFullYear(new Date().getFullYear() - 50))
  }
});

// ─── 2.2 : Allergie pénicilline + ≥ 3 consultations ──────────────────────────
print("=== 2.2 Allergie Pénicilline + 3 consultations ===");

db.patients.find({
  allergies: "Pénicilline",
  "consultations.2": { $exists: true } // au moins 3 consultations
});

// ─── 2.3 : Nom, prénom + dernière consultation ───────────────────────────────
print("=== 2.3 Dernière consultation seulement ===");

db.patients.aggregate([
  {
    $project: {
      nom: 1,
      prenom: 1,
      lastConsultation: { $arrayElemAt: ["$consultations", -1] }
    }
  }
]);

// ─── 2.4 : Sans antécédents + tension > 140 dernière consultation ─────────────
print("=== 2.4 Patients sans antécédents + HTA dernière consultation ===");

db.patients.find({
  antecedents: { $size: 0 },
  "consultations.tension.systolique": { $gt: 140 }
});

// ─── 2.5 : Recherche textuelle sur diagnostics ───────────────────────────────
print("=== 2.5 Recherche textuelle diagnostics ===");

// créer index texte (à faire une seule fois)
db.patients.createIndex({
  "consultations.diagnostic": "text"
});

// exemple de recherche
db.patients.find({
  $text: { $search: "hypertension diabète asthme" }
});
