/**
 * TP2 - Exercice 3 : Pipelines d'Agrégation
 * Use Case : Statistiques médicales HealthCare DZ
 */

use("medical_db");

// ─── 3.1 : Distribution des diagnostics par wilaya ────────────────────────────
print("=== 3.1 : Top diagnostics par wilaya ===");

const diagParWilaya = db.patients.aggregate([
  { $unwind: "$consultations" },
  {
    $group: {
      _id: {
        wilaya: "$adresse.wilaya",
        diagnostic: "$consultations.diagnostic"
      },
      count: { $sum: 1 }
    }
  },
  { $sort: { count: -1 } },
  { $limit: 20 }
]).toArray();

// printjson(diagParWilaya);

// ─── 3.2 : Médicament le plus prescrit par spécialité ─────────────────────────
print("\n=== 3.2 : Top médicaments par spécialité ===");

const medsParSpecialite = db.patients.aggregate([
  { $unwind: "$consultations" },
  { $unwind: "$consultations.medicaments" },
  {
    $group: {
      _id: {
        specialite: "$consultations.medecin.specialite",
        medicament: "$consultations.medicaments.nom"
      },
      count: { $sum: 1 }
    }
  },
  { $sort: { "_id.specialite": 1, count: -1 } },
  {
    $group: {
      _id: "$_id.specialite",
      topMedicament: { $first: "$_id.medicament" },
      total: { $first: "$count" }
    }
  }
]).toArray();

// ─── 3.3 : Évolution mensuelle des consultations ──────────────────────────────
print("\n=== 3.3 : Consultations par mois (12 derniers mois) ===");

const evolutionMensuelle = db.patients.aggregate([
  { $unwind: "$consultations" },
  {
    $match: {
      "consultations.date": {
        $gte: new Date(new Date().setFullYear(new Date().getFullYear() - 1))
      }
    }
  },
  {
    $group: {
      _id: {
        year: { $year: "$consultations.date" },
        month: { $month: "$consultations.date" }
      },
      count: { $sum: 1 }
    }
  },
  { $sort: { "_id.year": 1, "_id.month": 1 } },
  {
    $project: {
      _id: 0,
      periode: {
        $concat: [
          { $toString: "$_id.year" },
          "-",
          { $toString: "$_id.month" }
        ]
      },
      count: 1
    }
  }
]).toArray();

// ─── 3.4 : Patients à risque multiple ────────────────────────────────────────
print("\n=== 3.4 : Profil patients à risque élevé ===");

const patientsRisque = db.patients.aggregate([
  {
    $addFields: {
      age: {
        $floor: {
          $divide: [
            { $subtract: [new Date(), "$dateNaissance"] },
            1000 * 60 * 60 * 24 * 365
          ]
        }
      }
    }
  },
  {
    $match: {
      antecedents: { $all: ["Diabète type 2", "HTA"] },
      age: { $gt: 60 }
    }
  },
  {
    $addFields: {
      nbConsultations: { $size: "$consultations" }
    }
  },
  {
    $group: {
      _id: null,
      totalPatients: { $sum: 1 },
      moyenneConsultations: { $avg: "$nbConsultations" }
    }
  }
]).toArray();

// ─── 3.5 : Rapport médecins ───────────────────────────────────────────────────
print("\n=== 3.5 : Top 5 médecins & taux de ré-consultation ===");

const rapportMedecins = db.patients.aggregate([
  { $unwind: "$consultations" },
  {
    $group: {
      _id: {
        medecin: "$consultations.medecin.nom"
      },
      patients: { $addToSet: "$_id" },
      totalConsultations: { $sum: 1 }
    }
  },
  {
    $addFields: {
      nbPatients: { $size: "$patients" },
      tauxReconsultation: {
        $cond: [
          { $gt: [{ $size: "$patients" }, 0] },
          {
            $multiply: [
              {
                $divide: [
                  { $subtract: ["$totalConsultations", { $size: "$patients" }] },
                  { $size: "$patients" }
                ]
              },
              100
            ]
          },
          0
        ]
      }
    }
  },
  { $sort: { totalConsultations: -1 } },
  { $limit: 5 }
]).toArray();

printjson(rapportMedecins);
