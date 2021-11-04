--TP 3
--Procedures
-- J’écris une Procédure qui ajoute un WAREHOUSE pour une location donnée. 

SET SERVEROUTPUT ON;
DECLARE
v_location_id locations.location_id%type;
v_name warehouses.warehouse_name%type;
--declaration de variable v_max  pour la donner nouvelle identifiant de la nouvelle warehouse
v_max warehouses.warehouse_id%type;
--Declaration de la procedure
PROCEDURE ADD_WAREHOUSE (v_location_id locations.location_id%type, v_max warehouses.warehouse_id%type) IS
BEGIN
INSERT INTO WAREHOUSES (warehouse_id,warehouse_name,location_id) VALUES (v_max,v_name,v_location_id);
END ;
BEGIN
v_location_id:=&v_location_id;
v_name :=&v_name ;
--Je selectionne l’id maximal du warehouse et je l’ajoute 1 pour qu’il soit l’id du nouveau warehouse 
select max(warehouse_id)+1 into v_max from warehouses;
ADD_WAREHOUSE(v_location_id,v_max);
END;

 --QUESTION 2
--Une procédure qui met à jour les données relatives à une WAREHOUSE d’une location donnée. 
SET SERVEROUTPUT ON ;
DECLARE
v_location_id locations.location_id%type;
v_name warehouses.warehouse_name%type;
--Déclaration de la procédure qui me permettera de la mise à jour du nom du warehouse
PROCEDURE UPDATED_WAREHOUSE (v_location_id locations.location_id%type,v_name warehouses.warehouse_name%type) IS
BEGIN
UPDATE WAREHOUSES SET warehouse_name = v_name WHERE location_id=v_location_id;
END;

BEGIN
v_location_id:=&v_location_id;
v_name:='&v_name';
UPDATED_WAREHOUSE(v_location_id,v_name);
END;
--Déclaration de la procédure qui me permettera de mettre à jour le nom et l’id du warehouse
CREATE OR REPLACE PROCEDURE UPDATED_WAREHOUSE (v_warehouse_id IN warehouses.warehouse_id%type,
v_name  IN warehouses.warehouse_name%type) IS
BEGIN
UPDATE WAREHOUSES SET warehouse_name = v_name WHERE warehouse_id=v_warehouse_id;
END;


 --question 3
--Une procédure qui permet de supprimer un WAREHOUSE données 
SET SERVEROUTPUT ON;
DECLARE
v_location_id locations.location_id%type;
v_max warehouses.warehouse_id%type;
PROCEDURE DELETE_WAREHOUSE (v_location_id locations.location_id%type) IS
BEGIN
DELETE WAREHOUSES WHERE location_id=v_location_id;
END;
BEGIN
v_location_id:=&v_location_id;
DELETE_WAREHOUSE(v_location_id);
END;
--QUESTION 4
--Procédure permettant d’afficher les warehouses pour une location donnée
 
SET SERVEROUTPUT ON;
DECLARE
v_location_id warehouses.location_id%TYPE ;
--Création procédure d’affichage
PROCEDURE Afficher(v_location_id IN warehouses.location_id%TYPE ) IS
CURSOR table_noms IS
SELECT WAREHOUSE_ID, WAREHOUSE_NAME 
FROM WAREHOUSES WHERE LOCATION_ID = v_location_id;
BEGIN
for i in table_noms loop
DBMS_OUTPUT.PUT_LINE('Warehouse ID : '||i.warehouse_id ||' - '||i.warehouse_name);
end loop;
END;
BEGIN
v_location_id:=&v_location_id;
Afficher(v_location_id);
END;
 
--QUESTION 5
--Une procédure permettant du calcule CA d’un employé 
SET SERVEROUTPUT ON;
DECLARE
v_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE;
somme1 number;
PROCEDURE CA_employee(id_employe IN EMPLOYEES.EMPLOYEE_ID%TYPE,
somme OUT number)IS
BEGIN
SELECT SUM(QUANTITY*UNIT_PRICE) INTO somme
FROM ORDERS
INNER JOIN ORDER_ITEMS USING(ORDER_ID)
WHERE SALESMAN_ID=v_employee_id;
END;
BEGIN
v_employee_id:=&v_employee_id;
CA_employee(v_employee_id,somme1);
dbms_output.put_line('Le chiffre d affaire de   '||v_employee_id||' est : '||somme1);
END;



--Fonctions
--QUESTION 1
-- Ecriture de la  fonction retournant le prix total d’une commande d’un client 
SET SERVEROUTPUT ON;
DECLARE
v_customer_id ORDERS.CUSTOMER_ID%TYPE;
prix_total number;
FUNCTION prix_total(id_customer IN ORDERS.CUSTOMER_ID%TYPE)
RETURN number 
IS
prix number;
BEGIN
SELECT SUM(QUANTITY*UNIT_PRICE)INTO prix
FROM ORDERS
INNER JOIN ORDER_ITEMS USING(ORDER_ID)
WHERE ORDERS.CUSTOMER_ID=v_customer_id AND (STATUS='Pending' or STATUS='Shipeed');
return prix;
END;
BEGIN
v_customer_id:=&v_customer_id;
prix_total:=prix_total(v_customer_id);
dbms_output.put_line('Le prix total  de '||v_customer_id||' est : '||prix_total);
END;

--QUESTION 2
--Ecriture de la fonction retournant le nombre de commande qui ont le statut : Pending 
SET SERVEROUTPUT ON;
DECLARE
nombre_commande number;
FUNCTION CALCUL_orders
RETURN number 
IS
nombre number;

BEGIN
select count(*) INTO nombre from orders where STATUS='Pending' or STATUS='Shipped';
return nombre;
END;
BEGIN
nombre_commande:=CALCUL_orders;
dbms_output.put_line('Le nombre de commande qui ont comme status: Pending est:  '||nombre_commande);
END;
WAREHOUSE(v_location_id);
END;

--Les DECLENCHEURS
--QUESTION 1
-- Ecriture d’un déclencheur qui affiche le résumé d’une commande 
Create TRIGGER trigg_resume
BEFORE INSERT ON ORDER_ITEMS
FOR EACH ROW
DECLARE
BEGIN
DBMS_OUTPUT.PUT_LINE('id du commande '|| :NEW.order_id);
DBMS_OUTPUT.PUT_LINE('quantité du commande '|| :new.quantity);
DBMS_OUTPUT.PUT_LINE('prix : '|| :new.unit_price);
END;

--QUESTION 2
--Ecriture un déclencheur qui affiche une alerte du stocke une fois le nombre d’article disponible en inventaire est < 10 
create  TRIGGER trigg_alerte
AFTER  UPDATE ON INVENTORIES
FOR EACH ROW
DECLARE
BEGIN
if :NEW.quantity<10 then
DBMS_OUTPUT.PUT_LINE('ALERTE : QUANTITY  <10');
end if ;
END;

--QUESTION  3
--Ecriture d’un déclencheur qui n’autorise pas la modification du CREDIT_LIMIT des clients entre le 28 et 30 de chaque mois 
Create  TRIGGER dec_update_credit
BEFORE UPDATE OF credit_limit
ON customers
DECLARE
v_day NUMBER;
BEGIN
-- On utilise la fonction sysdate pour déterminer la date du jour en l’affectant à la variable  v_day 
v_day := EXTRACT(DAY FROM sysdate);
IF v_day BETWEEN 28 AND 31 THEN
dbms_output.put_line('tu ne paux pas modifier le credit_limit entre 28 &31');
END IF;
END;

--QUESTION 4
--Ecriture d’un déclencheur qui interdit l’ajout d’un employé si HIRE_DATE est > a Date d’aujourd’hui 
Create  TRIGGER trig_add_employe
BEFORE INSERT ON EMPLOYEES
FOR EACH ROW
BEGIN
IF sysdate < :NEW.hire_date THEN
dbms_output.put_line('Impossible d'ajouter l'employé (today date<hire_date)');
END IF;
END;

--QUESTION 5
--Ecriture du déclencheur qui applique une remise de 5% si le prix total de la commande est > 10000$ 
create  TRIGGER dec_remise_comandes
BEFORE INSERT ON order_items
FOR EACH ROW
DECLARE
--On affecte le prix après la remise à la variable total_price 
Total_price number;
BEGIN
if :New.unit_price*:NEW.Quantity > 10000 then
total_price:=:New.unit_price*:NEW.Quantity - :New.unit_price*:NEW.Quantity*0.05;
DBMS_OUTPUT.PUT_LINE(' le prix final après remise  est ' ||total_price '$');
end if;
END;
