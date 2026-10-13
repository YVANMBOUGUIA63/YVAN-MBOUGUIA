"""
Pipeline d'analyse : Volatilité des prix des matières premières
et vulnérabilité fiscale des pays en développement (2000-2023)

Ce script :
1. Crée la base SQLite et importe les données CSV
2. Exécute les requêtes d'analyse (volatilité, chocs, corrélations)
3. Exporte les résultats en CSV pour alimentation Power BI

Auteur : Yvan Mbouguia Ngouah
"""

import sqlite3
import csv
import os
import math

# ── Configuration ──────────────────────────────────────────────

DB_PATH = "data/volatilite_prix.db"
DATA_DIR = "data"
EXPORT_DIR = "powerbi"

# ── Fonctions utilitaires ──────────────────────────────────────

def charger_csv(cursor, table, fichier_csv):
    """Charge un fichier CSV dans une table SQLite."""
    with open(fichier_csv, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        colonnes = reader.fieldnames
        placeholders = ", ".join(["?"] * len(colonnes))
        col_names = ", ".join(colonnes)
        insert_sql = f"INSERT INTO {table} ({col_names}) VALUES ({placeholders})"

        rows = []
        for row in reader:
            rows.append(tuple(row[c] for c in colonnes))

        cursor.executemany(insert_sql, rows)

    print(f"  {table} : {len(rows)} lignes importées depuis {fichier_csv}")


def exporter_csv(cursor, requete, fichier_sortie, description=""):
    """Exécute une requête et exporte le résultat en CSV."""
    cursor.execute(requete)
    colonnes = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()

    chemin = os.path.join(EXPORT_DIR, fichier_sortie)
    with open(chemin, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(colonnes)
        writer.writerows(rows)

    print(f"  {fichier_sortie} : {len(rows)} lignes ({description})")


# ── Exécution ──────────────────────────────────────────────────

def main():
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # 1. Création des tables
    print("\n1. Création des tables...")
    with open("sql/01_creation_tables.sql", "r") as f:
        cur.executescript(f.read())
    print("  Tables créées.")

    # 2. Import des données
    print("\n2. Import des données CSV...")
    charger_csv(cur, "prix_matieres_premieres",
                os.path.join(DATA_DIR, "prix_matieres_premieres.csv"))
    charger_csv(cur, "recettes_fiscales_pays",
                os.path.join(DATA_DIR, "recettes_fiscales_pays.csv"))
    conn.commit()

    # 3. Calcul de la volatilité annuelle
    print("\n3. Calcul de la volatilité annuelle...")
    cur.execute("""
        INSERT INTO volatilite_annuelle
            (annee, matiere_premiere, prix_moyen, prix_min, prix_max,
             ecart_type, coeff_variation)
        SELECT
            annee,
            matiere_premiere,
            ROUND(AVG(prix_usd), 2),
            ROUND(MIN(prix_usd), 2),
            ROUND(MAX(prix_usd), 2),
            ROUND(SQRT(AVG(prix_usd * prix_usd) - AVG(prix_usd) * AVG(prix_usd)), 4),
            ROUND(SQRT(AVG(prix_usd * prix_usd) - AVG(prix_usd) * AVG(prix_usd))
                  / AVG(prix_usd), 4)
        FROM prix_matieres_premieres
        GROUP BY annee, matiere_premiere
    """)
    conn.commit()
    print(f"  {cur.rowcount} lignes insérées dans volatilite_annuelle.")

    # 4. Création des vues
    print("\n4. Création des vues analytiques...")
    cur.executescript("""
        CREATE VIEW IF NOT EXISTS rendements_mensuels AS
        SELECT
            p1.date, p1.annee, p1.mois, p1.matiere_premiere,
            p1.prix_usd AS prix_courant,
            p2.prix_usd AS prix_precedent,
            ROUND((p1.prix_usd - p2.prix_usd) / p2.prix_usd * 100, 2) AS rendement_pct
        FROM prix_matieres_premieres p1
        INNER JOIN prix_matieres_premieres p2
            ON p1.matiere_premiere = p2.matiere_premiere
            AND ((p1.annee = p2.annee AND p1.mois = p2.mois + 1)
                 OR (p1.mois = 1 AND p2.mois = 12 AND p1.annee = p2.annee + 1));

        CREATE VIEW IF NOT EXISTS volatilite_recettes AS
        SELECT
            r.annee, r.code_pays, r.pays, r.matiere_dominante,
            r.dependance_export, r.recettes_fiscales_pib,
            r.recettes_matieres_mrd,
            v.coeff_variation AS volatilite_prix,
            v.prix_moyen,
            ROUND(r.recettes_matieres_mrd / r.recettes_fiscales_mrd * 100, 2)
                AS part_matieres_recettes
        FROM recettes_fiscales_pays r
        INNER JOIN volatilite_annuelle v
            ON r.annee = v.annee
            AND r.matiere_dominante = v.matiere_premiere;
    """)
    print("  Vues créées.")

    # 5. Exports pour Power BI
    print("\n5. Export des données pour Power BI...")
    os.makedirs(EXPORT_DIR, exist_ok=True)

    exporter_csv(cur,
        "SELECT * FROM prix_matieres_premieres ORDER BY date, matiere_premiere",
        "prix_mensuels.csv",
        "série temporelle des prix")

    exporter_csv(cur,
        "SELECT * FROM volatilite_annuelle ORDER BY annee, matiere_premiere",
        "volatilite_annuelle.csv",
        "volatilité par année et matière")

    exporter_csv(cur,
        "SELECT * FROM rendements_mensuels ORDER BY matiere_premiere, date",
        "rendements_mensuels.csv",
        "rendements mensuels glissants")

    exporter_csv(cur,
        "SELECT * FROM volatilite_recettes ORDER BY annee, pays",
        "volatilite_recettes.csv",
        "croisement volatilité × recettes fiscales")

    exporter_csv(cur,
        """SELECT matiere_premiere,
                  CASE WHEN annee BETWEEN 2000 AND 2007 THEN '2000-2007'
                       WHEN annee BETWEEN 2008 AND 2015 THEN '2008-2015'
                       WHEN annee BETWEEN 2016 AND 2023 THEN '2016-2023'
                  END AS periode,
                  ROUND(AVG(coeff_variation), 4) AS volatilite_moyenne,
                  ROUND(AVG(prix_moyen), 2) AS prix_moyen_periode
           FROM volatilite_annuelle
           GROUP BY matiere_premiere, periode
           ORDER BY matiere_premiere, periode""",
        "volatilite_par_periode.csv",
        "comparaison entre périodes")

    exporter_csv(cur,
        """SELECT pays, matiere_dominante, dependance_export,
                  ROUND(AVG(recettes_fiscales_pib), 2) AS recettes_moy_pib,
                  ROUND(AVG(part_matieres_recettes), 2) AS part_matieres_moy,
                  ROUND(AVG(volatilite_prix), 4) AS volatilite_moy,
                  ROUND(AVG(part_matieres_recettes) * AVG(volatilite_prix), 4)
                      AS indice_vulnerabilite
           FROM volatilite_recettes
           GROUP BY pays
           ORDER BY indice_vulnerabilite DESC""",
        "vulnerabilite_pays.csv",
        "classement des pays par vulnérabilité")

    conn.close()
    print("\nTerminé. Les fichiers CSV dans powerbi/ sont prêts pour Power BI.")


if __name__ == "__main__":
    main()
