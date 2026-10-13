-- ==============================================================================
-- Script : 03 — Analyse de la volatilité des prix
-- ==============================================================================


-- -------------------------------------------------------
-- 1. Statistiques descriptives par matière première
-- -------------------------------------------------------

SELECT
    matiere_premiere,
    COUNT(*)                          AS nb_observations,
    ROUND(AVG(prix_usd), 2)          AS prix_moyen,
    ROUND(MIN(prix_usd), 2)          AS prix_min,
    ROUND(MAX(prix_usd), 2)          AS prix_max,
    ROUND(MAX(prix_usd) - MIN(prix_usd), 2) AS amplitude
FROM prix_matieres_premieres
GROUP BY matiere_premiere
ORDER BY prix_moyen DESC;


-- -------------------------------------------------------
-- 2. Volatilité annuelle (coefficient de variation)
-- -------------------------------------------------------

INSERT INTO volatilite_annuelle (annee, matiere_premiere, prix_moyen, prix_min, prix_max, ecart_type, coeff_variation)
SELECT
    annee,
    matiere_premiere,
    ROUND(AVG(prix_usd), 2)                          AS prix_moyen,
    ROUND(MIN(prix_usd), 2)                          AS prix_min,
    ROUND(MAX(prix_usd), 2)                          AS prix_max,
    ROUND(
        SQRT(
            AVG(prix_usd * prix_usd) - AVG(prix_usd) * AVG(prix_usd)
        ), 4
    )                                                  AS ecart_type,
    ROUND(
        SQRT(
            AVG(prix_usd * prix_usd) - AVG(prix_usd) * AVG(prix_usd)
        ) / AVG(prix_usd), 4
    )                                                  AS coeff_variation
FROM prix_matieres_premieres
GROUP BY annee, matiere_premiere
ORDER BY annee, matiere_premiere;


-- -------------------------------------------------------
-- 3. Rendements mensuels (variation en pourcentage)
-- -------------------------------------------------------

CREATE VIEW IF NOT EXISTS rendements_mensuels AS
SELECT
    p1.date,
    p1.annee,
    p1.mois,
    p1.matiere_premiere,
    p1.prix_usd                                       AS prix_courant,
    p2.prix_usd                                       AS prix_precedent,
    ROUND((p1.prix_usd - p2.prix_usd) / p2.prix_usd * 100, 2) AS rendement_pct
FROM prix_matieres_premieres p1
INNER JOIN prix_matieres_premieres p2
    ON p1.matiere_premiere = p2.matiere_premiere
    AND (
        (p1.annee = p2.annee AND p1.mois = p2.mois + 1)
        OR (p1.mois = 1 AND p2.mois = 12 AND p1.annee = p2.annee + 1)
    )
ORDER BY p1.matiere_premiere, p1.date;


-- -------------------------------------------------------
-- 4. Identification des chocs de prix (> 2 écarts-types)
-- -------------------------------------------------------

CREATE VIEW IF NOT EXISTS chocs_prix AS
WITH stats AS (
    SELECT
        matiere_premiere,
        AVG(rendement_pct) AS rendement_moyen,
        SQRT(
            AVG(rendement_pct * rendement_pct)
            - AVG(rendement_pct) * AVG(rendement_pct)
        ) AS rendement_ecart_type
    FROM rendements_mensuels
    GROUP BY matiere_premiere
)
SELECT
    r.date,
    r.matiere_premiere,
    r.rendement_pct,
    s.rendement_moyen,
    s.rendement_ecart_type,
    CASE
        WHEN r.rendement_pct > s.rendement_moyen + 2 * s.rendement_ecart_type
            THEN 'Choc positif'
        WHEN r.rendement_pct < s.rendement_moyen - 2 * s.rendement_ecart_type
            THEN 'Choc négatif'
        ELSE 'Normal'
    END AS type_choc
FROM rendements_mensuels r
INNER JOIN stats s ON r.matiere_premiere = s.matiere_premiere
WHERE type_choc != 'Normal'
ORDER BY r.date;


-- -------------------------------------------------------
-- 5. Corrélation volatilité — recettes fiscales
-- -------------------------------------------------------

CREATE VIEW IF NOT EXISTS volatilite_recettes AS
SELECT
    r.annee,
    r.code_pays,
    r.pays,
    r.matiere_dominante,
    r.dependance_export,
    r.recettes_fiscales_pib,
    r.recettes_matieres_mrd,
    v.coeff_variation    AS volatilite_prix,
    v.prix_moyen,
    ROUND(r.recettes_matieres_mrd / r.recettes_fiscales_mrd * 100, 2)
                         AS part_matieres_recettes
FROM recettes_fiscales_pays r
INNER JOIN volatilite_annuelle v
    ON r.annee = v.annee
    AND r.matiere_dominante = v.matiere_premiere
ORDER BY r.annee, r.pays;


-- -------------------------------------------------------
-- 6. Années de forte volatilité et impact fiscal
-- -------------------------------------------------------

SELECT
    vr.annee,
    vr.pays,
    vr.matiere_dominante,
    ROUND(vr.volatilite_prix * 100, 2) AS volatilite_pct,
    vr.recettes_fiscales_pib,
    vr.part_matieres_recettes
FROM volatilite_recettes vr
WHERE vr.volatilite_prix > 0.10
ORDER BY vr.volatilite_prix DESC
LIMIT 30;


-- -------------------------------------------------------
-- 7. Comparaison de la volatilité entre périodes
-- -------------------------------------------------------

SELECT
    matiere_premiere,
    CASE
        WHEN annee BETWEEN 2000 AND 2007 THEN '2000-2007'
        WHEN annee BETWEEN 2008 AND 2015 THEN '2008-2015'
        WHEN annee BETWEEN 2016 AND 2023 THEN '2016-2023'
    END AS periode,
    ROUND(AVG(coeff_variation), 4) AS volatilite_moyenne,
    ROUND(AVG(prix_moyen), 2)     AS prix_moyen_periode
FROM volatilite_annuelle
GROUP BY matiere_premiere, periode
ORDER BY matiere_premiere, periode;


-- -------------------------------------------------------
-- 8. Classement des pays par vulnérabilité fiscale
-- -------------------------------------------------------

SELECT
    pays,
    matiere_dominante,
    dependance_export,
    ROUND(AVG(recettes_fiscales_pib), 2)     AS recettes_moy_pib,
    ROUND(AVG(part_matieres_recettes), 2)    AS part_matieres_moy,
    ROUND(AVG(volatilite_prix), 4)           AS volatilite_moy,
    ROUND(AVG(part_matieres_recettes) * AVG(volatilite_prix), 4)
                                              AS indice_vulnerabilite
FROM volatilite_recettes
GROUP BY pays
ORDER BY indice_vulnerabilite DESC;
