-- ==============================================================================
-- Projet : Volatilité des prix des matières premières et recettes fiscales
--          dans les pays en développement (2000-2023)
-- Auteur  : Yvan Mbouguia Ngouah
-- Script  : 01 — Création des tables
-- ==============================================================================

-- Table des prix mensuels des matières premières
CREATE TABLE IF NOT EXISTS prix_matieres_premieres (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    date            DATE        NOT NULL,
    annee           INTEGER     NOT NULL,
    mois            INTEGER     NOT NULL,
    matiere_premiere VARCHAR(50) NOT NULL,
    prix_usd        DECIMAL(12,2) NOT NULL,
    unite           VARCHAR(20)  NOT NULL
);

-- Table des recettes fiscales annuelles par pays
CREATE TABLE IF NOT EXISTS recettes_fiscales_pays (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    annee               INTEGER     NOT NULL,
    code_pays           VARCHAR(3)  NOT NULL,
    pays                VARCHAR(50) NOT NULL,
    matiere_dominante   VARCHAR(50) NOT NULL,
    dependance_export   DECIMAL(5,1) NOT NULL,
    pib_mrd_usd         DECIMAL(10,2) NOT NULL,
    recettes_fiscales_pib DECIMAL(5,2) NOT NULL,
    recettes_fiscales_mrd DECIMAL(10,2) NOT NULL,
    recettes_matieres_mrd DECIMAL(10,2) NOT NULL
);

-- Table dérivée : volatilité annuelle par matière première
CREATE TABLE IF NOT EXISTS volatilite_annuelle (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    annee           INTEGER     NOT NULL,
    matiere_premiere VARCHAR(50) NOT NULL,
    prix_moyen      DECIMAL(12,2),
    prix_min        DECIMAL(12,2),
    prix_max        DECIMAL(12,2),
    ecart_type      DECIMAL(12,4),
    coeff_variation DECIMAL(8,4),
    rendement_annuel DECIMAL(8,4)
);
