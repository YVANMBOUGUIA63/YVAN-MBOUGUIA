-- ==============================================================================
-- Script : 02 — Import des données CSV dans SQLite
-- ==============================================================================

-- Importer les prix des matières premières
.mode csv
.headers on
.import --skip 1 data/prix_matieres_premieres.csv prix_matieres_premieres

-- Importer les recettes fiscales
.import --skip 1 data/recettes_fiscales_pays.csv recettes_fiscales_pays

-- Vérification
SELECT 'prix_matieres_premieres' AS table_name, COUNT(*) AS nb_lignes
FROM prix_matieres_premieres
UNION ALL
SELECT 'recettes_fiscales_pays', COUNT(*)
FROM recettes_fiscales_pays;
