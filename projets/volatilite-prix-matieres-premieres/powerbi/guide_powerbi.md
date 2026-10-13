# Guide Power BI — Tableau de bord Volatilité des prix

Ce guide décrit la construction du tableau de bord Power BI à partir des fichiers CSV exportés par le pipeline.

## Sources de données

Importer les fichiers CSV suivants via Obtenir les données > Texte/CSV :

| Fichier | Description |
|---------|-------------|
| `prix_mensuels.csv` | Prix mensuels de 8 matières premières (2000-2023) |
| `volatilite_annuelle.csv` | Coefficient de variation annuel par matière |
| `rendements_mensuels.csv` | Rendements mensuels glissants |
| `volatilite_recettes.csv` | Croisement volatilité × recettes fiscales par pays |
| `volatilite_par_periode.csv` | Comparaison de la volatilité entre trois sous-périodes |
| `vulnerabilite_pays.csv` | Classement des pays par indice de vulnérabilité |

## Modèle de données

Les relations à configurer dans Power BI :

- `prix_mensuels[matiere_premiere]` → `volatilite_annuelle[matiere_premiere]` + `volatilite_annuelle[annee]`
- `volatilite_recettes[annee]` + `volatilite_recettes[matiere_dominante]` → `volatilite_annuelle[annee]` + `volatilite_annuelle[matiere_premiere]`

## Pages du tableau de bord

### Page 1 — Évolution des prix

- Graphique en courbes : prix mensuels par matière première (axe X = date, axe Y = prix_usd, légende = matiere_premiere)
- Segment (slicer) sur la matière première pour filtrer
- Carte KPI : prix moyen, prix min, prix max sur la période sélectionnée

### Page 2 — Volatilité

- Graphique en barres groupées : coefficient de variation annuel par matière première
- Matrice : volatilité moyenne par période (2000-2007, 2008-2015, 2016-2023) × matière première
- Graphique en aires : distribution des rendements mensuels

### Page 3 — Vulnérabilité fiscale

- Nuage de points (scatter) : volatilité des prix (axe X) × recettes fiscales/PIB (axe Y), taille = dépendance aux exportations, couleur = pays
- Graphique en barres horizontales : indice de vulnérabilité par pays (trié décroissant)
- Tableau : détail par pays et par année

### Page 4 — Chocs et crises

- Graphique en courbes avec zones ombrées pour les périodes de choc (2008-2009, 2014-2015, 2020, 2022)
- Tableau des événements de choc identifiés (rendements > 2 écarts-types)

## Mesures DAX recommandées

```dax
-- Volatilité glissante sur 12 mois
Volatilite_12M =
VAR PrixTable = CALCULATETABLE(
    VALUES(prix_mensuels[prix_usd]),
    DATESINPERIOD(prix_mensuels[date], LASTDATE(prix_mensuels[date]), -12, MONTH)
)
RETURN DIVIDE(STDEVX.P(PrixTable, [prix_usd]), AVERAGEX(PrixTable, [prix_usd]))

-- Rendement annualisé
Rendement_Annualise =
VAR PrixDebut = CALCULATE(MIN(prix_mensuels[prix_usd]), FIRSTDATE(prix_mensuels[date]))
VAR PrixFin = CALCULATE(MAX(prix_mensuels[prix_usd]), LASTDATE(prix_mensuels[date]))
RETURN DIVIDE(PrixFin - PrixDebut, PrixDebut)

-- Indice de vulnérabilité
Indice_Vulnerabilite =
AVERAGE(volatilite_recettes[part_matieres_recettes])
    * AVERAGE(volatilite_recettes[volatilite_prix])
```
