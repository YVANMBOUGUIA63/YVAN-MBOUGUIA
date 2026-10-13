# Volatilité des prix des matières premières et vulnérabilité fiscale

Analyse de la volatilité des prix de huit matières premières (pétrole, cacao, café, coton, or, cuivre, riz, blé) sur la période 2000-2023 et de son impact sur les recettes fiscales de dix pays en développement d'Afrique subsaharienne.

## Problématique

Les économies d'Afrique subsaharienne dépendantes des matières premières sont exposées à une double vulnérabilité. La volatilité des cours mondiaux se transmet aux recettes d'exportation, puis aux recettes fiscales lorsque la part des revenus tirés des ressources naturelles est élevée. Ce projet mesure cette volatilité, identifie les épisodes de choc et construit un indice de vulnérabilité fiscale par pays.

## Méthodes

Le coefficient de variation annuel mesure la volatilité intra-annuelle de chaque matière première. Les rendements mensuels glissants permettent d'identifier les chocs de prix (variations supérieures à deux écarts-types). Un indice de vulnérabilité fiscale est construit en croisant la part des matières premières dans les recettes fiscales avec la volatilité du cours de la matière dominante.

## Données

Les prix mensuels sont calibrés sur les tendances réelles des cours mondiaux (Banque mondiale, Commodity Markets Outlook). Les recettes fiscales sont simulées à partir des ordres de grandeur observés pour dix pays : Nigéria, Cameroun, Côte d'Ivoire, Ghana, Éthiopie, Burkina Faso, Mali, Zambie, Tchad, Sénégal.

## Outils

SQL (SQLite) pour le stockage, les transformations et les requêtes analytiques. Python pour le pipeline d'alimentation et d'export. Power BI pour le tableau de bord interactif.

## Structure

```
├── data/
│   ├── prix_matieres_premieres.csv     # Prix mensuels (8 matières, 2000-2023)
│   ├── recettes_fiscales_pays.csv      # Recettes fiscales (10 pays, 2000-2023)
│   └── volatilite_prix.db             # Base SQLite générée par le pipeline
├── sql/
│   ├── 01_creation_tables.sql          # Schéma de la base
│   ├── 02_import_donnees.sql           # Import des CSV
│   └── 03_analyse_volatilite.sql       # Requêtes analytiques complètes
├── powerbi/
│   ├── guide_powerbi.md                # Guide de construction du tableau de bord
│   ├── prix_mensuels.csv               # Export pour Power BI
│   ├── volatilite_annuelle.csv
│   ├── rendements_mensuels.csv
│   ├── volatilite_recettes.csv
│   ├── volatilite_par_periode.csv
│   └── vulnerabilite_pays.csv
├── pipeline.py                         # Pipeline complet (import → analyse → export)
└── README.md
```

## Exécution

```bash
python pipeline.py
```

Le script crée la base SQLite, importe les données, exécute les analyses et exporte les résultats dans `powerbi/` pour alimentation du tableau de bord Power BI.
