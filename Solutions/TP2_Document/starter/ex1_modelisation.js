/**
 * TP2 - Exercice 1 : Modélisation MongoDB
 * Use Case : HealthCare DZ - Dossiers Médicaux
 */

// Se connecter à la base médicale
use("medical_db");

// ─── 1.1 : Créer la collection avec validation ────────────────────────────────
db.createCollection("patients", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["cin", "nom", "prenom", "dateNaissance", "sexe", "adresse", "consultations"],
      properties: {
        cin: { bsonType: "string", description: "CIN obligatoire" },
        nom: { bsonType: "string" },
        prenom: { bsonType: "string" },
        dateNaissance: { bsonType: "date" },
        sexe: { enum: ["M", "F"] },
        adresse: {
          bsonType: "object",
          required: ["wilaya", "commune"],
          properties: {
            wilaya: { bsonType: "string" },
            commune: { bsonType: "string" }
          }
        },
        groupeSanguin: { bsonType: "string" },
        antecedents: { bsonType: "array" },
        allergies: { bsonType: "array" },
        consultations: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["date", "medecin", "diagnostic"],
            properties: {
              date: { bsonType: "date" },
              medecin: {
                bsonType: "object",
                properties: {
                  nom: { bsonType: "string" },
                  specialite: { bsonType: "string" }
                }
              },
              diagnostic: { bsonType: "string" }
            }
          }
        }
      }
    }
  }
});

// ─── 1.2 : Insérer des patients avec données algériennes ──────────────────────
const patients = [
  {
    cin: "198001012300",
    nom: "Bensalem",
    prenom: "Ahmed",
    dateNaissance: new Date("1980-01-01"),
    sexe: "M",
    adresse: { wilaya: "Alger", commune: "Bab Ezzouar" },
    groupeSanguin: "O+",
    antecedents: ["Diabète type 2", "HTA"],
    allergies: ["Pénicilline"],
    consultations: [
      {
        id: UUID(),
        date: new Date("2024-01-15"),
        medecin: { nom: "Dr. Mansouri", specialite: "Cardiologie" },
        diagnostic: "Hypertension artérielle",
        tension: { systolique: 145, diastolique: 92 },
        medicaments: [
          { nom: "Amlodipine", dosage: "5mg", duree: "30 jours" }
        ],
        notes: "Surveillance tensionnelle recommandée"
      },
      {
        id: UUID(),
        date: new Date("2024-06-10"),
        medecin: { nom: "Dr. Khelifi", specialite: "Endocrinologie" },
        diagnostic: "Diabète type 2",
        tension: { systolique: 130, diastolique: 85 },
        medicaments: [
          { nom: "Metformine", dosage: "850mg", duree: "3 mois" }
        ],
        notes: "Régime alimentaire conseillé"
      }
    ]
  },

  {
    cin: "199205154567",
    nom: "Zerrouki",
    prenom: "Nadia",
    dateNaissance: new Date("1992-05-15"),
    sexe: "F",
    adresse: { wilaya: "Oran", commune: "Bir El Djir" },
    groupeSanguin: "A+",
    antecedents: ["Asthme"],
    allergies: [],
    consultations: [
      {
        id: UUID(),
        date: new Date("2023-11-20"),
        medecin: { nom: "Dr. Saidi", specialite: "Pneumologie" },
        diagnostic: "Crise d'asthme",
        medicaments: [
          { nom: "Ventoline", dosage: "100µg", duree: "selon besoin" }
        ],
        notes: "Contrôle respiratoire régulier"
      }
    ]
  },

  {
    cin: "197512309876",
    nom: "Boumediene",
    prenom: "Karim",
    dateNaissance: new Date("1975-12-30"),
    sexe: "M",
    adresse: { wilaya: "Constantine", commune: "El Khroub" },
    groupeSanguin: "B+",
    antecedents: ["HTA"],
    allergies: ["Aspirine"],
    consultations: [
      {
        id: UUID(),
        date: new Date("2024-02-12"),
        medecin: { nom: "Dr. Belkacem", specialite: "Cardiologie" },
        diagnostic: "Hypertension artérielle",
        medicaments: [
          { nom: "Atenolol", dosage: "50mg", duree: "1 mois" }
        ],
        notes: "Réduction du sel recommandée"
      }
    ]
  }
];

// compléter automatiquement jusqu’à 20 patients (simplifié ici)
for (let i = 4; i <= 20; i++) {
  patients.push({
    cin: "20000000" + i,
    nom: "Patient" + i,
    prenom: "Test" + i,
    dateNaissance: new Date("1990-01-01"),
    sexe: i % 2 === 0 ? "M" : "F",
    adresse: { wilaya: "Alger", commune: "Centre" },
    groupeSanguin: "O+",
    antecedents: [],
    allergies: [],
    consultations: [
      {
        id: UUID(),
        date: new Date("2024-01-01"),
        medecin: { nom: "Dr. Test", specialite: "Generaliste" },
        diagnostic: "Consultation générale"
      }
    ]
  });
}

// insertion patients
db.patients.insertMany(patients);

// ─── 1.3 : Collection analyses (référencée) ───────────────────────────────────
const analyses = [];

patients.forEach(p => {
  analyses.push({
    patient_id: p._id,
    date: new Date(),
    type: "Glycémie",
    resultats: { valeur: 1.1 },
    laboratoire: "Labo Central Alger",
    valide: true
  });
});

db.analyses.insertMany(analyses);

print("✅ Modélisation terminée. Patients insérés:", db.patients.countDocuments());
print("✅ Analyses insérées:", db.analyses.countDocuments());
