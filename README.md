# Datenqualitaet-und-Pipeline-in-Data-Warehouse
Dieses Projekt zielt darauf ab, die Datenqualität zu überprüfen und ein Data-Warehouse (DWH) einzurichten.

1. Bei der Datenqualität werden drei Aspekte betrachtet: (a) die funktionale Abhängigkeit zwischen Merkmalen, (b) die Vollständigkeit der Angabe "Straße" und (c) ein weiteres Qualitätsmerkmal nach Wahl.

2. Die Qualität der Daten wird im zeitlichen Verlauf beobachtet, indem die Ergebnisse regelmäßig aktualisiert und in einer Tabelle gespeichert werden.

3. Für das Data-Warehouse wird ein 5-dimensionaler Analyse-Würfel in einem Stern-Schema modelliert, der stündlich mit aktuellen Daten gefüllt wird. Die Umsetzung umfasst das Einrichten des Schemas, das Kopieren neuer Daten, die Verwendung von Transaktionen, das Planen von Events zur Aktualisierung und die Verbindung mit Tableau Desktop zur Analyse des Umsatzes in zwei Dimensionen.


# Inhalte
Das Repository enthält die folgenden Dateien:

- _Datenbanksysteme2-Projekt-Skript.sql_: Diese Datei enthält alle SQL-Abfragen für dieses Projekt ohne Prozeduren.
- _Datenbanksysteme2-Projekt-Skript-Prozeduren.sql_: Diese Datei enthält alle Prozeduren für dieses Projekt
- _Datenbanksysteme2-Projekt-Bericht.pdf_: Diese Datei enthält eine detaillierte Beschreibung des Projekts, einschließlich der Methodik, der Ergebnisse und der Besonderheiten.
- _Sales-By-Product-Group-Germany.pdf, Computer-Sales-Trends-Over-Time.pdf_: Diese PDF-Dateien sind Ergebnisse der zweidimensionalen Analyse unter Verwendung eines Data Warehouses und Tableau.
- _README.md_: Die Datei, die Sie gerade lesen.
