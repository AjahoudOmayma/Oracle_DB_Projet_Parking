--========================================================
--              GESTION DES RÔLES ET UTILISATEURS
--========================================================

-- 1) Créer les rôles applicatifs
CREATE ROLE R_ADMIN;
CREATE ROLE R_AGENT;

-- 2) Créer les utilisateurs 
CREATE USER ADMIN1  IDENTIFIED BY "Admin#2025";
CREATE USER AGENT1  IDENTIFIED BY "Agent@2025";
CREATE USER AGENT2  IDENTIFIED BY "Agent@@2025"; 

-- 3) Autoriser la connexion
GRANT CREATE SESSION TO ADMIN1;
GRANT CREATE SESSION TO AGENT1, AGENT2; 


-- 4) Attribuer les rôles
GRANT R_ADMIN  TO ADMIN1;
GRANT R_AGENT  TO AGENT1;
GRANT R_AGENT  TO AGENT2;


--========================================================
--                  CRÉATION DES SÉQUENCES
--========================================================

CREATE SEQUENCE seq_client START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_abonnement START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_tarif START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_place START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_reservation START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ticket START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_paiement START WITH 1 INCREMENT BY 1;


--========================================================
--                      CRÉATION DES TABLES
--========================================================

-- TABLE CLIENT
------------------------------------------------------------

CREATE TABLE Client (
    id_client INT PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL,
    prenom VARCHAR2(50) NOT NULL,
    telephone VARCHAR2(15),
    PMR CHAR(1) DEFAULT 'O' CHECK (PMR IN ('O', 'N')),
    CONSTRAINT unique_telephone UNIQUE (telephone)
);

------------------------------------------------------------
-- TABLE TARIF
------------------------------------------------------------
CREATE TABLE Tarif (
    id_tarif INT PRIMARY KEY,
    type_client VARCHAR2(20) NOT NULL
        CHECK (type_client IN ('Abonne', 'Non_Abonne')),
    tarif_horaire NUMBER(10,2) NOT NULL
);

ALTER TABLE Tarif ADD CONSTRAINT uk_type_client UNIQUE (type_client);

------------------------------------------------------------
-- TABLE ABONNEMENT
------------------------------------------------------------

CREATE TABLE Abonnement (
    id_abonne INT PRIMARY KEY,
    id_client INT NOT NULL,
    date_inscription DATE DEFAULT SYSDATE,
    date_expiration DATE,
    statut VARCHAR2(20) DEFAULT 'Actif' 
        CHECK (statut IN ('Actif', 'Suspendu', 'Expire')),
    
    FOREIGN KEY (id_client) REFERENCES Client(id_client)
);

------------------------------------------------------------
-- TABLE PLACE
------------------------------------------------------------
CREATE TABLE Place (
    id_place INT PRIMARY KEY,
    numero_place VARCHAR2(10) UNIQUE,
    disponible CHAR(1) DEFAULT 'O' CHECK (disponible IN ('O', 'N')),
    type_place VARCHAR2(30) 
                    CHECK (type_place IN ('Standard', 'VIP', 'Handicape'))

);

------------------------------------------------------------
-- TABLE RESERVATION
------------------------------------------------------------
CREATE TABLE Reservation (
    id_reservation INT PRIMARY KEY,
    id_client INT NOT NULL,
    id_place INT NOT NULL,
    id_tarif INT REFERENCES Tarif(id_tarif),
    date_entree DATE DEFAULT SYSDATE,
    date_sortie DATE,
    statut VARCHAR2(20) DEFAULT 'En attente' 
        CHECK (statut IN ('En attente', 'Confirmee', 'Annulee', 'Terminee')),
    montant_total NUMBER(10,2),

    FOREIGN KEY (id_client) REFERENCES Client(id_client) ON DELETE CASCADE, 
    FOREIGN KEY (id_place) REFERENCES Place(id_place)
);

------------------------------------------------------------
-- TABLE TICKET
------------------------------------------------------------
CREATE TABLE Ticket (
    id_ticket INT PRIMARY KEY,
    id_reservation INT NOT NULL,
    date_emission DATE DEFAULT SYSDATE,
    FOREIGN KEY (id_reservation) REFERENCES Reservation(id_reservation)
);

------------------------------------------------------------
-- TABLE PAIEMENT
------------------------------------------------------------
CREATE TABLE Paiement (
    id_paiement INT PRIMARY KEY,
    id_reservation INT NOT NULL,
    date_paiement DATE DEFAULT SYSDATE,
    montant NUMBER(10,2) NOT NULL,
    mode_paiement VARCHAR2(20) 
        CHECK (mode_paiement IN ('Especes', 'Carte', 'En ligne')),
    statut VARCHAR2(20) DEFAULT 'Effectue' 
        CHECK (statut IN ('Effectue', 'Annule', 'En attente')),

    FOREIGN KEY (id_reservation) REFERENCES Reservation(id_reservation)
);



--INSERTION DANS TARIF---

INSERT INTO Tarif (id_tarif, type_client, tarif_horaire) VALUES (1, 'Abonne', 5.00);
INSERT INTO Tarif (id_tarif, type_client, tarif_horaire) VALUES (2, 'Non_Abonne', 10.00);


--INSERTION DANS PLACE----

INSERT INTO Place VALUES (seq_place.NEXTVAL, 'A1', 'O', 'Standard');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'A2', 'N', 'Standard');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'A3', 'N', 'Standard');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'A4', 'N', 'Standard');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'A5', 'N', 'Standard');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'A6', 'N', 'Standard');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'C1', 'O', 'Handicape');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'C2', 'O', 'Handicape');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'C3', 'O', 'Handicape');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'C4', 'O', 'Handicape');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'C5', 'O', 'Handicape');
INSERT INTO Place VALUES (seq_place.NEXTVAL, 'C6', 'O', 'Handicape');
COMMIT;
--========================================================
--                      ATTRIBUTION DES DROITS
--========================================================

-- 1) ADMIN : tous droits sur toutes les tables de l'application
GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENT      TO R_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON PLACE       TO R_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON TARIF       TO R_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON TICKET      TO R_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON PAIEMENT    TO R_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON ABONNEMENT  TO R_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON RESERVATION TO R_ADMIN;

GRANT SELECT ON SEQ_CLIENT    TO R_ADMIN;
GRANT SELECT ON SEQ_PLACE     TO R_ADMIN;
GRANT SELECT ON SEQ_TARIF     TO R_ADMIN;
GRANT SELECT ON SEQ_TICKET    TO R_ADMIN;
GRANT SELECT ON SEQ_PAIEMENT  TO R_ADMIN;
GRANT SELECT ON SEQ_RESERVATION TO R_ADMIN;
GRANT SELECT ON SEQ_ABONNEMENT TO R_ADMIN;

-- 2) AGENT : droits opérationnels (terrain)
--    - peut lire les référentiels
GRANT SELECT, INSERT ON CLIENT TO R_AGENT;
GRANT SELECT, UPDATE ON PLACE  TO R_AGENT;
GRANT SELECT ON TARIF  TO R_AGENT;

--    - gère les entrées/sorties, paiements, réservations, abonnements
GRANT SELECT, INSERT, UPDATE ON TICKET      TO R_AGENT;
GRANT SELECT, INSERT        ON PAIEMENT    TO R_AGENT;
GRANT SELECT, INSERT, UPDATE ON RESERVATION TO R_AGENT;
GRANT SELECT, INSERT, UPDATE ON ABONNEMENT  TO R_AGENT;


GRANT SELECT ON SEQ_TICKET     TO R_AGENT;
GRANT SELECT ON SEQ_PAIEMENT    TO R_AGENT;
GRANT SELECT ON SEQ_RESERVATION TO R_AGENT;


-- Création des index pour accélérer les recherches sur les colonnes utilisées
CREATE INDEX idx_client_tel ON CLIENT(telephone);
CREATE INDEX idx_res_client ON RESERVATION(id_client);
CREATE INDEX idx_res_place ON RESERVATION(id_place);
CREATE INDEX idx_ticket_res ON TICKET(id_reservation);


--========================================================
--                  DÉVELOPPEMENT PL/SQL
--========================================================



--==================================================
--                      FONCTIONS
--==================================================
-----------------------------------------------------------
    -- Fonction : Ajouter un client
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION Ajouter_client (
    p_nom IN VARCHAR2 ,
    p_prenom IN VARCHAR2 ,  
    p_telephone IN VARCHAR2,
    p_PMR IN CHAR
) RETURN NUMBER
IS
    v_id_client NUMBER ;
BEGIN
    SELECT id_client INTO v_id_client FROM CLIENT
    WHERE telephone = p_telephone ;
    RETURN v_id_client ;
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        v_id_client := seq_client.NEXTVAL ;
        INSERT INTO CLIENT(id_client, nom, prenom, telephone, PMR) VALUES ( v_id_client, p_nom, p_prenom, p_telephone, p_PMR) ;
        DBMS_OUTPUT.PUT_LINE( 'Client ' || p_nom ||' '|| p_prenom || ' ajoute. ' ) ;
        
        RETURN v_id_client ;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'Erreur ajout client : ' || SQLERRM ) ;
        RETURN -1 ;

END ;
/

-----------------------------------------------------------
    -- Fonction : verifier l'abonnement d'un client
-----------------------------------------------------------
    
CREATE OR REPLACE FUNCTION verifier_abonnement (
    p_id_client IN NUMBER
) RETURN BOOLEAN
IS
    v_date_expiration DATE ;
BEGIN
    SELECT date_expiration INTO v_date_expiration FROM ABONNEMENT
    WHERE id_client = p_id_client
    AND statut = 'Actif' ;
    
    IF v_date_expiration <= SYSDATE THEN
        UPDATE ABONNEMENT
        SET statut = 'Expire'
        WHERE id_client = p_id_client 
        AND statut = 'Actif' ;
        RETURN FALSE ;
    ELSE 
        RETURN TRUE ;
    END IF ;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;
/

-----------------------------------------------------------
    -- Fonction : chercher une place libre
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION chercher_place_libre (
    p_PMR IN CHAR
) RETURN NUMBER 
IS
    v_id_place NUMBER ;
BEGIN
    SELECT id_place INTO v_id_place FROM PLACE
    WHERE disponible = 'O'
      AND (
           (p_PMR = 'O' AND type_place = 'Handicape')
        OR (p_PMR = 'N' AND type_place = 'Standard') 
            )
      AND ROWNUM = 1;
    RETURN v_id_place ;
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        RETURN NULL ;
END;
/

-----------------------------------------------------------
    -- Fonction : Verifier si un ticket est deja paye 
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION verifier_paiement(
    p_id_reservation IN NUMBER 
) RETURN NUMBER
IS
    v_count NUMBER;
BEGIN
    SELECT count(*) into v_count FROM PAIEMENT
    WHERE id_reservation=p_id_reservation ;
    
    RETURN v_count;
    
END;
/

-----------------------------------------------------------
    -- Fonction : Determiner le tarif horaire du client
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION Determiner_tarif (
    p_id_client IN NUMBER
) RETURN NUMBER
IS
    v_tarif NUMBER ;
BEGIN 
    IF verifier_abonnement( p_id_client ) THEN
        SELECT tarif_horaire INTO v_tarif 
        FROM TARIF
        WHERE type_client = 'Abonne' ;
    ELSE
        SELECT tarif_horaire INTO v_tarif 
        FROM TARIF
        WHERE type_client = 'Non_Abonne' ;
    END IF ;
    RETURN v_tarif ;
END ;
/

-----------------------------------------------------------
    -- Procedure : Mettre à jour les tarifs
-----------------------------------------------------------

CREATE OR REPLACE PROCEDURE mettre_a_jour_tarifs (
    p_tarif_abonne IN NUMBER,
    p_tarif_non_abonne IN NUMBER
)
IS
BEGIN
    -- Vérifier si les valeurs sont positives
    IF p_tarif_abonne <= 0 OR p_tarif_non_abonne <= 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'Les tarifs doivent être positifs.');
    END IF;

    -- Mettre à jour le tarif Abonné
    UPDATE TARIF
    SET tarif_horaire = p_tarif_abonne
    WHERE type_client = 'Abonne';
    
    -- Mettre à jour le tarif Non Abonné
    UPDATE TARIF
    SET tarif_horaire = p_tarif_non_abonne
    WHERE type_client = 'Non_Abonne';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Tarifs mis à jour avec succès :');
    DBMS_OUTPUT.PUT_LINE('- Abonné : ' || p_tarif_abonne || ' MAD/h');
    DBMS_OUTPUT.PUT_LINE('- Non Abonné : ' || p_tarif_non_abonne || ' MAD/h');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la mise à jour des tarifs : ' || SQLERRM);
        RAISE;
END mettre_a_jour_tarifs;
/
-----------------------------------------------------------
    -- Fonction : calcul de la duree
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION calculer_duree (
    p_date_entree DATE , 
    p_date_sortie DATE
) RETURN NUMBER
IS
BEGIN
    RETURN (p_date_sortie - p_date_entree) * 24 ;
END ;
/

-----------------------------------------------------------
    -- Fonction : calculer le montant
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION calculer_montant (
    p_duree IN NUMBER,
    p_tarif_horaire IN NUMBER 
)RETURN NUMBER
IS
BEGIN
    RETURN CEIL(p_duree) * p_tarif_horaire ;

END ;
/

-----------------------------------------------------------
    -- Fonction : calcul du nombre  total des clients 
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION total_clients
RETURN NUMBER
IS 
    v_total NUMBER;
BEGIN
    SELECT count(*) INTO v_total FROM CLIENT;
    RETURN v_total;
END;
/

-----------------------------------------------------------
    -- Fonction : calcul du nombre des clients abonnes
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION total_abonnes
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT count(*) INTO v_total FROM ABONNEMENT
    WHERE statut = 'Actif' ;
    RETURN v_total;
END;
/


-----------------------------------------------------------
    -- Fonction : calcul du taux d'occupation des places
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION taux_d_occup_places
RETURN NUMBER
IS
    v_total NUMBER;
    v_occup NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM PLACE;
    SELECT count(*) INTO v_occup FROM PLACE
    WHERE disponible = 'N';
    RETURN (v_occup / v_total) * 100;
END;
/

-----------------------------------------------------------
    -- Fonction : calcul du taux des places libres
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION taux_places_libres
RETURN NUMBER
IS
    v_total NUMBER;
    v_dispo NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM PLACE;
    SELECT count(*) INTO v_dispo FROM PLACE
    WHERE disponible = 'O';
    RETURN (v_dispo / v_total)*100;
END;
/

-----------------------------------------------------------
    -- Fonction : calcul du revenu du jour 
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION revenu_d_jour
RETURN NUMBER
IS
    v_revenu NUMBER;
BEGIN
    SELECT NVL(SUM(montant), 0) INTO v_revenu FROM PAIEMENT
    WHERE TRUNC(date_paiement) = TRUNC(SYSDATE);
    RETURN v_revenu;
END;
/

-----------------------------------------------------------
    -- Fonction : calcul du nombre des paiements valides
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION nbr_paiement_valide
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT count(*) INTO v_total FROM PAIEMENT
    WHERE statut = 'Effectue';
    RETURN v_total;
END;
/

--==================================================
            -- PROCEDURES
--==================================================
-----------------------------------------------------------
    -- Procedure : s'abonner
-----------------------------------------------------------

CREATE OR REPLACE PROCEDURE s_abonner (
    p_nom IN VARCHAR2,
    p_prenom IN VARCHAR2,
    p_telephone IN VARCHAR2,
    p_PMR IN CHAR
)
IS
    v_id_client NUMBER;
BEGIN
    v_id_client := Ajouter_client( p_nom, p_prenom, p_telephone, p_PMR);
    IF v_id_client >= 0 THEN
        INSERT INTO ABONNEMENT (id_abonne, id_client, date_inscription, date_expiration, statut)
        VALUES (seq_abonnement.NEXTVAL, v_id_client, SYSDATE, SYSDATE + 30, 'Actif');
        COMMIT;
        DBMS_OUTPUT.PUT_LINE ( 'Abonnement effectué avec succès pour ' || p_nom || ' ' || p_prenom || '.' ) ;
    END IF ;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE ( 'Erreur lors de l’abonnement : ' || SQLERRM ) ;
END s_abonner;
/

-----------------------------------------------------------
    -- Procedure : ajouter l'entree
-----------------------------------------------------------

CREATE OR REPLACE PROCEDURE ajouter_entree (
    p_nom IN VARCHAR2 ,
    p_prenom IN VARCHAR2 ,  
    p_telephone IN VARCHAR2,
    p_PMR IN CHAR
) IS 
    v_id_client NUMBER ;
    v_id_place NUMBER ;
    v_tarif_horaire NUMBER ;
    v_id_reservation NUMBER ;
    v_id_tarif NUMBER ;
BEGIN
    BEGIN
        SELECT id_client INTO v_id_client FROM CLIENT
        WHERE telephone = p_telephone ;
        iF NOT verifier_abonnement( v_id_client ) THEN
            DBMS_OUTPUT.PUT_LINE('Client non abonné, mais déjà enregistré.');
        END IF ;
        
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            v_id_client := ajouter_client( p_nom, p_prenom, p_telephone, p_PMR ) ; 
    END ;
    
    v_id_place := chercher_place_libre ( p_PMR ) ;
    IF v_id_place IS NULL THEN
        RAISE_APPLICATION_ERROR ( -20001, 'Aucune place disponible !' );
    END IF ;
    
    v_tarif_horaire := Determiner_tarif ( v_id_client ) ;
    
    SELECT id_tarif INTO v_id_tarif 
    FROM TARIF
    WHERE tarif_horaire = v_tarif_horaire ;
    
    v_id_reservation := seq_reservation.NEXTVAL;
    INSERT INTO RESERVATION ( id_reservation, id_client, id_place, id_tarif, date_entree, date_sortie, statut, montant_total )
    VALUES( v_id_reservation, v_id_client, v_id_place, v_id_tarif, SYSDATE, NULL, 'Confirmee', NULL ) ;
    
    INSERT INTO TICKET ( id_ticket, id_reservation, date_emission )
    VALUES( seq_ticket.NEXTVAL, v_id_reservation, SYSDATE ) ;
    
    COMMIT ;
    DBMS_OUTPUT.PUT_LINE('Entrée validée pour le client ' || p_nom || p_prenom || ', place ' || v_id_place);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK ;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de l’entrée : ' || SQLERRM);
END ;
/

-----------------------------------------------------------
    -- Procedure : valider la sortie
-----------------------------------------------------------

CREATE OR REPLACE PROCEDURE valider_sortie ( 
    p_id_ticket  IN NUMBER ,
    p_mode_paiement VARCHAR2
) IS
    v_paiemnt_exist NUMBER;
    v_duree NUMBER ;
    v_montant NUMBER ;
    v_tarif NUMBER ;
    v_id_client NUMBER ;
    v_id_place NUMBER ;
    v_date_entree DATE ;
    v_id_reservation NUMBER ;
    
BEGIN
    
    SELECT id_reservation INTO v_id_reservation
    FROM TICKET 
    WHERE id_ticket = p_id_ticket;
    
    v_paiemnt_exist := verifier_paiement(v_id_reservation);
    IF v_paiemnt_exist>0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paiement déjà effectué pour ce ticket.');
    END IF;

    SELECT date_entree , id_client , id_place 
    INTO v_date_entree , v_id_client , v_id_place
    FROM RESERVATION
    WHERE id_reservation = v_id_reservation;
    
    v_tarif := Determiner_tarif ( v_id_client ) ;
    v_duree := calculer_duree ( v_date_entree , SYSDATE ) ;
    v_montant := calculer_montant ( v_duree , v_tarif ) ;
    
    INSERT INTO PAIEMENT (id_paiement, id_reservation, date_paiement, montant, mode_paiement, statut )
    VALUES ( seq_paiement.NEXTVAL , v_id_reservation, SYSDATE, v_montant, p_mode_paiement, 'Effectue' ) ;
    
    UPDATE RESERVATION
    SET date_sortie = SYSDATE, statut = 'Terminee', montant_total = v_montant
    WHERE id_reservation = v_id_reservation ;
    
    COMMIT ;
    DBMS_OUTPUT.PUT_LINE('Sortie validée. Montant à payer : ' || v_montant || ' DH');
    
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK ;
    DBMS_OUTPUT.PUT_LINE ( 'Erreur lors de la sortie : ' || SQLERRM ) ;
    
END valider_sortie ;
/

--==================================================
            -- TRIGGERS
--==================================================
               
-----------------------------------------------------------
    -- Trigger : Eviter que la place reste bloquée
-----------------------------------------------------------

CREATE OR REPLACE TRIGGER liberer_place 
AFTER UPDATE OF date_sortie ON Reservation 
FOR EACH ROW 
BEGIN
    IF :NEW.date_sortie IS NOT NULL THEN
        UPDATE PLACE 
        SET disponible = 'O'
        WHERE id_place = :NEW.id_place ;
        DBMS_OUTPUT.PUT_LINE( 'La place '|| :NEW.id_place || ' est liberee' ) ;
    END IF ;
END ;
/

-----------------------------------------------------------
    -- Trigger : Eviter qu'un administrateur d’oublier de mettre la place en N
-----------------------------------------------------------

CREATE OR REPLACE TRIGGER reserver_place 
AFTER INSERT ON Reservation 
FOR EACH ROW 
BEGIN
    UPDATE PLACE
        SET disponible = 'N'
        WHERE id_place = :NEW.id_place ;
        DBMS_OUTPUT.PUT_LINE( 'La place '|| :NEW.id_place || ' est Occupée' ) ;
END ;
/

-----------------------------------------------------------
    -- Trigger : vérifier si la place est libre avant réservation
-----------------------------------------------------------

CREATE OR REPLACE TRIGGER verifier_place_libre 
BEFORE INSERT ON Reservation 
FOR EACH ROW 
DECLARE
    v_disponible VARCHAR2(20) ;
BEGIN
    SELECT disponible INTO v_disponible FROM PLACE
    WHERE id_place = :NEW.id_place ;
    IF v_disponible = 'N' THEN 
        RAISE_APPLICATION_ERROR (-20010, 'Erreur : la place est déjà occupée.') ;
    END IF ;
END ;
/

-----------------------------------------------------------
    -- Trigger : Eviter d’ajouter plusieurs abonnements actifs pour un même client
-----------------------------------------------------------  
    
CREATE OR REPLACE TRIGGER verifier_abonnement_actif
BEFORE INSERT ON ABONNEMENT 
FOR EACH ROW
DECLARE
    v_count NUMBER ;
BEGIN
    SELECT count(*) INTO v_count FROM ABONNEMENT
    WHERE id_client = :NEW.id_client 
    AND statut = 'Actif' ;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR (-20020, 'Erreur : le client a déjà une abonnement actif.') ;
    END IF ;
END; 
/


-- Droits sur les fonctions
GRANT EXECUTE ON Ajouter_client          TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON verifier_abonnement     TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON chercher_place_libre    TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON verifier_paiement       TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON Determiner_tarif        TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON calculer_duree          TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON calculer_montant        TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON total_clients           TO R_ADMIN;
GRANT EXECUTE ON total_abonnes           TO R_ADMIN;
GRANT EXECUTE ON taux_d_occup_places     TO R_ADMIN;
GRANT EXECUTE ON taux_places_libres      TO R_ADMIN;
GRANT EXECUTE ON revenu_d_jour           TO R_ADMIN;
GRANT EXECUTE ON nbr_paiement_valide     TO R_ADMIN;

-- Droits sur les procédures
GRANT EXECUTE ON s_abonner               TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON ajouter_entree          TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON valider_sortie          TO R_ADMIN, R_AGENT;
GRANT EXECUTE ON mettre_a_jour_tarifs TO R_ADMIN;
-- Note: R_AGENT n'a pas besoin de cette permission
COMMIT;


