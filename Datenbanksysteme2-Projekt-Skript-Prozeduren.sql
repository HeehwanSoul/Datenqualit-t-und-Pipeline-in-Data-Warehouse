/* Projektaufgabe
 * Heehwan Soul, 885941
 * Mehmet Görkem Basar, 921637
 * The implementation can be found in the stud_soul or stud_basar database.
 */

--- 2.2 (b) --- Automate Quality Checks ---


   
DELIMITER //

CREATE PROCEDURE update_datenqualitaet()
BEGIN
    INSERT INTO datenqualitaet (functional_dependency, completeness_ratio, negativ_preis_ratio)
	SELECT
    	(SELECT COUNT(*) FROM (SELECT bestellung_bestellnummer, COUNT(DISTINCT bestellung_bestellDatum) AS bestellung_bestellDatum_count FROM bestelldaten GROUP BY bestellung_bestellnummer HAVING COUNT(DISTINCT bestellung_bestellDatum) = 1) AS PerfectMappings) / 
    	(SELECT COUNT(*) FROM (SELECT bestellung_bestellnummer FROM bestelldaten GROUP BY bestellung_bestellnummer) AS TotalMappings) AS functional_dependency,
    	(SELECT COUNT(CASE WHEN person_strasse REGEXP '[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZßüöäÜÖÄ]' AND person_strasse REGEXP '[0123456789]' THEN 1 END) / COUNT(*) FROM bestelldaten) AS completeness_ratio,
    	(SELECT COUNT(CASE WHEN artikel_preis < 0 THEN 1 END) / COUNT(*) FROM bestelldaten ) AS negativ_preis_ratio;
END //



CREATE PROCEDURE etl_update()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback transaction in case of error
        ROLLBACK;
    END;

    -- Start transaction
    START TRANSACTION;

    -- Extract and load new data into dimension tables
    INSERT INTO t_dim_zeit (bestellung_datum, bestellung_jahr, bestellung_monat, bestellung_tag, bestellung_quartal, bestellung_wochentag)
    SELECT DISTINCT DATE(bestellung_bestellDatum), YEAR(bestellung_bestellDatum), MONTH(bestellung_bestellDatum), DAY(bestellung_bestellDatum), QUARTER(bestellung_bestellDatum), WEEKDAY(bestellung_bestellDatum)
    FROM bestelldaten
    WHERE DATE(bestelldaten.bestellung_bestellDatum) NOT IN (SELECT DATE(bestellung_datum) FROM t_dim_zeit) ;


    INSERT INTO t_dim_artikel (idt_dim_artikel, bezeichnung, artikelgruppe_name, hersteller_name, hersteller_land)
    SELECT DISTINCT artikel_artikelnummer, artikel_bezeichnung, artikelgruppe_name, hersteller_name, hersteller_land
    FROM bestelldaten
    WHERE bestelldaten.artikel_artikelnummer NOT IN (SELECT idt_dim_artikel FROM t_dim_artikel);


    INSERT INTO t_dim_kunde (idt_dim_kunde, alterInJahren, kunde_ort, kunde_land, kundengruppe)
    SELECT DISTINCT person_id, person_alterInJahren, person_ort, person_land, kundengruppe_name
    FROM bestelldaten
    WHERE bestelldaten.person_id NOT IN (SELECT idt_dim_kunde FROM t_dim_kunde);

    INSERT INTO t_dim_bestellung (idt_dim_bestellung, versandart, verkaufskanal, online)
    SELECT DISTINCT bestellung_bestellnummer, versandart_name, verkaufskanal_name, verkaufskanal_online
    FROM bestelldaten
    WHERE bestelldaten.bestellung_bestellnummer NOT IN (SELECT idt_dim_bestellung FROM t_dim_bestellung);

    INSERT INTO t_dim_lieferant (idt_dim_lieferant, lieferant_name, lieferant_ort)
    SELECT DISTINCT lieferant_id, lieferant_name, lieferant_ort
    FROM bestelldaten
    WHERE bestelldaten.lieferant_id NOT IN (SELECT idt_dim_lieferant FROM t_dim_lieferant);

    -- Extract and load new data into the fact table
    INSERT INTO t_facts (idt_dim_artikel, idt_dim_kunde, idt_dim_zeit, idt_dim_bestellung, idt_dim_lieferant, anzahl, preis, einkaufspreis, versandkosten)
    SELECT
        t_dim_artikel.idt_dim_artikel,
        t_dim_kunde.idt_dim_kunde,
        t_dim_zeit.idt_dim_zeit,
        t_dim_bestellung.idt_dim_bestellung,
        t_dim_lieferant.idt_dim_lieferant,
        bestelldaten.bestellposition_menge,
        bestelldaten.artikel_preis,
        bestelldaten.liefert_lieferpreis,
        bestelldaten.bestellung_versandkosten
    FROM bestelldaten
    JOIN t_dim_zeit ON DATE(bestelldaten.bestellung_bestellDatum) = DATE(t_dim_zeit.bestellung_datum)
    JOIN t_dim_kunde ON bestelldaten.person_id = t_dim_kunde.idt_dim_kunde
    JOIN t_dim_artikel ON bestelldaten.artikel_artikelnummer = t_dim_artikel.idt_dim_artikel
    JOIN t_dim_bestellung ON bestelldaten.bestellung_bestellnummer  = t_dim_bestellung.idt_dim_bestellung
    JOIN t_dim_lieferant ON bestelldaten.lieferant_id = t_dim_lieferant.idt_dim_lieferant
    WHERE t_dim_bestellung.idt_dim_bestellung  NOT IN (SELECT idt_dim_bestellung FROM t_facts);

    -- Commit transaction
    COMMIT;
END //


DELIMITER ;

