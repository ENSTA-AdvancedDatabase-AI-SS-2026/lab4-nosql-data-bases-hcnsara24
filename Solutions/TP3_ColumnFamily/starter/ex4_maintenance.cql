-- 4.1 TWCS explication
-- Utilisée pour séries temporelles car optimisation suppression ancienne data

-- ─── 4.2 TWCS config ──────────────────────────────────────────────────────────

ALTER TABLE mesures_par_capteur
WITH compaction = {
  'class': 'TimeWindowCompactionStrategy',
  'compaction_window_unit': 'DAYS',
  'compaction_window_size': 1
};

-- ─── 4.3 TTL monitoring (approximation) ───────────────────────────────────────

SELECT *
FROM system_views.table_tombstones
WHERE keyspace_name = 'smartgrid';

-- ─── 4.4 Hot partition analysis ───────────────────────────────────────────────
-- Détection :
-- SELECT capteur_id, COUNT(*) GROUP BY capteur_id;

-- Correction :
-- ajouter partition composite (capteur_id + date_jour)
-- ou ajouter wilaya pour distribuer charge
