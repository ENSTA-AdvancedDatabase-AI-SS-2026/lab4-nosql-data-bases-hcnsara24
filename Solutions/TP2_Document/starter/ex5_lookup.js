/**
 * TP2 - Exercice 5 : $lookup et Données Référencées
 * Use Case : HealthCare DZ - Dossiers Médicaux
 */

use("medical_db");

// ─── 5.1 : Dossier complet patient (patients + analyses) ─────────────────────
print("=== 5.1 Dossier complet patient ===");

db.patients.aggregate([
  {
    $lookup: {
      from: "analyses",
      localField: "_id",
      foreignField: "patient_id",
      as: "analyses"
    }
  }
]).toArray();


// ─── 5.2 : Patients avec glycémie > 1.26 g/L ────────────────────────────────
print("=== 5.2 Glycémie élevée (> 1.26 g/L) ===");

db.analyses.aggregate([
  {
    $match: {
      type: "Glycémie",
      "resultats.valeur": { $gt: 1.26 }
    }
  },
  {
    $lookup: {
      from: "patients",
      localField: "patient_id",
      foreignField: "_id",
      as: "patient"
    }
  },
  {
    $unwind: "$patient"
  },
  {
    $project: {
      _id: 0,
      patient: {
        nom: "$patient.nom",
        prenom: "$patient.prenom",
        wilaya: "$patient.adresse.wilaya"
      },
      glycémie: "$resultats.valeur"
    }
  }
]).toArray();


// ─── 5.3 : Taux d’analyses anormales par wilaya ─────────────────────────────
print("=== 5.3 Taux d’analyses anormales par wilaya ===");

db.analyses.aggregate([
  {
    $lookup: {
      from: "patients",
      localField: "patient_id",
      foreignField: "_id",
      as: "patient"
    }
  },
  { $unwind: "$patient" },
  {
    $group: {
      _id: "$patient.adresse.wilaya",
      totalAnalyses: { $sum: 1 },
      analysesAnormales: {
        $sum: {
          $cond: [{ $eq: ["$valide", false] }, 1, 0]
        }
      }
    }
  },
  {
    $project: {
      wilaya: "$_id",
      tauxAnormal: {
        $multiply: [
          { $divide: ["$analysesAnormales", "$totalAnalyses"] },
          100
        ]
      },
      _id: 0
    }
  }
]).toArray();
