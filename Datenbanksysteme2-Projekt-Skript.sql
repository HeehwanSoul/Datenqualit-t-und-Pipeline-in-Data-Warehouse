/* Projektaufgabe
 * Heehwan Soul, 885941
 * Mehmet Görkem Basar, 921637
 * The implementation can be found in the stud_soul or stud_basar database.
 */


-- 1. Aufgabe 1.
CREATE VIEW bestelldaten AS
    SELECT person.id AS person_id,
    person.vorname AS person_vorname,
    person.nachname AS person_nachname,
    person.alterInJahren AS person_alterInJahren,
    person.strasse AS person_strasse,
    person.plz AS person_plz,
    person.ort AS person_ort,
    person.land AS person_land,
    person.anmeldung AS person_anmeldung,
    person.kundengruppe AS person_kundengruppe,
    kundengruppe.id AS kundengruppe_id,
    kundengruppe.name AS kundengruppe_name,
    bestellung.bestellnummer AS bestellung_bestellnummer,
    bestellung.bestellDatum AS bestellung_bestellDatum,
    bestellung.lieferDatum AS bestellung_lieferDatum,
    bestellung.zahlungsDatum AS bestellung_zahlungsDatum,
    bestellung.mahnDatum AS bestellung_mahnDatum,
    bestellung.versandkosten AS bestellung_versandkosten,
    bestellung.kunde AS bestellung_kunde,
    bestellung.verkaufskanal AS bestellung_verkaufskanal,
    bestellung.versandart AS bestellung_versandart,
    bestellung.gesamtwert AS bestellung_gesamtwert,
    verkaufskanal.id AS verkaufskanal_id,
    verkaufskanal.name AS verkaufskanal_name,
    verkaufskanal.online AS verkaufskanal_online,
    versandart.id AS versandart_id,
    versandart.name AS versandart_name,
    versandart.pauschalkosten AS versandart_pauschalkosten,
    bestellposition.bestellung_bestellnummer AS bestellposition_bestellung_bestellnummer,
    bestellposition.lieferant AS bestellposition_lieferant,
    bestellposition.artikelnummer AS bestellposition_artikelnummer,
    bestellposition.menge AS bestellposition_menge,
    liefert.lieferant AS liefert_lieferant,
    liefert.artikelnummer AS liefert_artikelnummer,
    liefert.lieferpreis AS liefert_lieferpreis,
    artikel.artikelnummer AS artikel_artikelnummer,
    artikel.bezeichnung AS artikel_bezeichnung,
    artikel.preis AS artikel_preis,
    artikel.artikelgruppe AS artikel_artikelgruppe,
    artikel.hersteller AS artikel_hersteller,
    lieferant.id AS lieferant_id,
    lieferant.name AS lieferant_name,
    lieferant.ort AS lieferant_ort,
    artikelgruppe.id AS artikelgruppe_id,
    artikelgruppe.name AS artikelgruppe_name,
    hersteller.id AS hersteller_id,
    hersteller.name AS hersteller_name,
    hersteller.land AS hersteller_land
    FROM sose24_dbs_oltp.person
    JOIN sose24_dbs_oltp.kundengruppe ON sose24_dbs_oltp.person.kundengruppe = sose24_dbs_oltp.kundengruppe.id
    JOIN sose24_dbs_oltp.bestellung ON sose24_dbs_oltp.person.id = sose24_dbs_oltp.bestellung.kunde
    JOIN sose24_dbs_oltp.verkaufskanal ON sose24_dbs_oltp.bestellung.verkaufskanal = sose24_dbs_oltp.verkaufskanal.id
    JOIN sose24_dbs_oltp.versandart ON sose24_dbs_oltp.bestellung.versandart = sose24_dbs_oltp.versandart.id
    JOIN sose24_dbs_oltp.bestellposition ON sose24_dbs_oltp.bestellung.bestellnummer = sose24_dbs_oltp.bestellposition.bestellung_bestellnummer
    JOIN sose24_dbs_oltp.liefert ON sose24_dbs_oltp.bestellposition.artikelnummer = sose24_dbs_oltp.liefert.artikelnummer AND sose24_dbs_oltp.bestellposition.lieferant = sose24_dbs_oltp.liefert.lieferant
    JOIN sose24_dbs_oltp.artikel ON sose24_dbs_oltp.liefert.artikelnummer = sose24_dbs_oltp.artikel.artikelnummer
    JOIN sose24_dbs_oltp.lieferant ON sose24_dbs_oltp.liefert.lieferant = sose24_dbs_oltp.lieferant.id
    JOIN sose24_dbs_oltp.artikelgruppe ON sose24_dbs_oltp.artikel.artikelgruppe = sose24_dbs_oltp.artikelgruppe.id
    JOIN sose24_dbs_oltp.hersteller ON sose24_dbs_oltp.artikel.hersteller = sose24_dbs_oltp.hersteller.id;



---- 2.Aufgabe --> 2.1 (a) ---------
-- 1) They both(bestellung_bestellnummer, bestellung_bestelldatum) are in the same table and bestellung_bestellnummer is a primary key in this table, so we expect full functional dependency = 1 !!! ---
WITH UniqueMappings AS (
    SELECT bestellung_bestellnummer, COUNT(DISTINCT bestellung_bestelldatum) AS bestellung_bestelldatum_count
    FROM bestelldaten
    GROUP BY bestellung_bestellnummer
),
PerfectMappings AS (
    SELECT COUNT(*) AS PerfectCount
    FROM UniqueMappings
    WHERE bestellung_bestelldatum_count = 1
),
TotalMappings AS (
    SELECT COUNT(*) AS TotalCount
    FROM UniqueMappings
)
SELECT
    PerfectMappings.PerfectCount / TotalMappings.TotalCount AS functional_dependency
FROM PerfectMappings, TotalMappings;


-- 2)  We expect the full functional dependency(1) between bestellung_bestellnummer -> verkaufskanal_name, because
---    bestellung_bestellnummer is a primary key in the table 'bestellung' and the table 'verkaufskanal' which has the column 'verkaufskanal_name' 
---    is joined with the table 'bsetellung'.
WITH UniqueMappings AS (
	SELECT bestellung_bestellnummer, COUNT(DISTINCT verkaufskanal_name) AS verkaufskanal_name_count
	FROM bestelldaten
	GROUP BY bestellung_bestellnummer
),
PerfectMappings AS (
    SELECT COUNT(*) AS PerfectCount
    FROM UniqueMappings
    WHERE verkaufskanal_name_count = 1
),
TotalMappings AS (
    SELECT COUNT(*) AS TotalCount
    FROM UniqueMappings
)
SELECT 
    PerfectCount / TotalCount AS FunctionalDependencyScore
FROM PerfectMappings, TotalMappings;


--- 2.1 (b) --- Completeness Ratio version 1---
--- we calculate the ratio: the number of rows which have german characters(straßename) and numbers(Hausnummer) as their values in the column 'person_strasse' /
---                        the number of all rows.
SELECT 
    COUNT(*) AS total_entries,
    COUNT(CASE WHEN person_strasse REGEXP '[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZßüöäÜÖÄ]' AND person_strasse REGEXP '[0123456789]' THEN 1 END) AS strassennamen_und_hausnummer,
    COUNT(CASE WHEN person_strasse REGEXP '[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZßüöäÜÖÄ]' AND person_strasse REGEXP '[0123456789]' THEN 1 END) / COUNT(*) AS completeness_ratio
FROM 
    bestelldaten;
   

--- 2.1 (b) --- Completeness Ratio version 2---

SELECT 
    COUNT(*) AS total_entries,
    COUNT(CASE WHEN person_strasse IS NOT NULL AND person_strasse <> '' THEN 1 END) AS complete_addresses,
    COUNT(CASE WHEN person_strasse IS NOT NULL AND person_strasse <> '' THEN 1 END) / COUNT(*) AS completeness_ratio
FROM 
    bestelldaten;
*/



--- 2.1 (c) Range Test ---
--- 0 is good and 1 is bad in this case ---

SELECT 
    COUNT(*) AS total_entries,
    COUNT(CASE WHEN artikel_preis < 0 THEN 1 END) AS negative_artikel_preis,
    COUNT(CASE WHEN artikel_preis < 0 THEN 1 END) / COUNT(*) AS negativ_preis_ratio
FROM 
    bestelldaten;
    


--- 2.2 (a) --- Table that store quality metrics ---
drop table if exists datenqualitaet;


CREATE TABLE datenqualitaet (
       ID INT auto_increment PRIMARY KEY,
       check_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       functional_dependency FLOAT,
       completeness_ratio FLOAT,
       negativ_preis_ratio FLOAT);
      
      
--- Insert quality metrics into the table ---
INSERT INTO datenqualitaet (functional_dependency, completeness_ratio, negativ_preis_ratio)
SELECT
    (SELECT COUNT(*) FROM (SELECT bestellung_bestellnummer, COUNT(DISTINCT bestellung_bestellDatum) AS bestellung_bestellDatum_count FROM bestelldaten GROUP BY bestellung_bestellnummer HAVING COUNT(DISTINCT bestellung_bestellDatum) = 1) AS PerfectMappings) / 
    (SELECT COUNT(*) FROM (SELECT bestellung_bestellnummer FROM bestelldaten GROUP BY bestellung_bestellnummer) AS TotalMappings) AS functional_dependency,
    (SELECT COUNT(CASE WHEN person_strasse REGEXP '[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZßüöäÜÖÄ]' AND person_strasse REGEXP '[0123456789]' THEN 1 END) / COUNT(*) FROM bestelldaten) AS completeness_ratio,
    (SELECT COUNT(CASE WHEN artikel_preis < 0 THEN 1 END) / COUNT(*) FROM bestelldaten ) AS negativ_preis_ratio;

   


--- 2.2 (b) --- Automate Quality Checks ---
--- The Procedure update_datenqualitaet() is written in the file DBS2-Projektaufgabe-Procedures.   
CREATE EVENT IF NOT EXISTS update_datenqualitaet_event
ON SCHEDULE EVERY 1 HOUR
DO
    CALL update_datenqualitaet();

--- verify ---

CALL update_datenqualitaet();

SELECT * FROM datenqualitaet ;



-- 3. Aufgabe: ETL und Data-Warehouse
-- 3.2 
-- The procedure is written in the file DBS2-Projektaufgabe-Procedures.


-- 3.4 Create an event to run the ETL Procedure every hour
CREATE EVENT hourly_etl_event
ON SCHEDULE EVERY 1 HOUR
DO
CALL etl_update();

-- to test
CALL etl_update();