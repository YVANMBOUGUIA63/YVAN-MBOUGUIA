# IDE, gouvernance et chaînes de valeur mondiales

Dans quelle mesure les IDE et la qualité de la gouvernance influencent-ils l'intégration des pays dans les chaînes de valeur mondiales ?

## Contexte

Rapport d'économétrie réalisé en Magistère 2e année (M2 Économie du Développement, CERDI), sous la direction de J.L. Combes et A. Vialefont, année universitaire 2025-2026.

Auteurs : Yvan Mbouguia Ngouah, Olinga Olinga, Ovono Obiang.

## Méthodes

L'analyse se déroule en deux temps. La première étape construit un indice synthétique de gouvernance à partir de six indicateurs de la Banque mondiale (voix et responsabilité, stabilité politique, efficacité du gouvernement, qualité de la réglementation, état de droit, contrôle de la corruption) au moyen d'une analyse en composantes principales. La seconde étape estime l'effet des IDE et de cet indice de gouvernance sur la participation aux chaînes de valeur mondiales, mesurée par les indicateurs GVC du FERDI.

Les estimations reposent sur des données de panel. Le modèle principal est estimé en effets fixes. Pour traiter l'endogénéité potentielle des IDE, une approche par variables instrumentales (IV-2SLS) est mise en œuvre avec `xtivreg2`. Une approche à la Mundlak complète l'analyse en intégrant les moyennes intra-individuelles des variables explicatives.

## Données

Les données proviennent de plusieurs sources : indicateurs de gouvernance de la Banque mondiale (WGI), flux d'IDE (WDI), indicateurs de participation aux CVM (FERDI), capital humain (Penn World Table) et variables macroéconomiques standard.

## Structure

```
├── rapport_gouvernance_ide_cvm.pdf   # Rapport complet
├── script.R                          # Nettoyage, fusion des bases, ACP, visualisations (R)
├── do.do                             # Régressions panel FE et IV-2SLS (Stata)
├── base4.dta                         # Base de données Stata
├── gouvernance2.dta                  # Base indicateurs de gouvernance
└── README.md
```

## Outils

R (tidyverse, FactoMineR, factoextra, corrplot, ggplot2, haven) · Stata (xtreg, xtivreg2)
