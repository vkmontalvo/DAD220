/* Database creation and analysis project for DAD220, SNHU 
Valerie Montalvo 2022*/

-- PART ONE --
-- Create the database and tables
CREATE SCHEMA QuantigrationUpdates;

USE QuanitgrationUpdates;

CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
FirstName VARCHAR(25),
LastName VARCHAR(25),
Street VARCHAR(50),
City VARCHAR(50),
State VARCHAR(25),
ZipCode INT,
Telephone VARCHAR(15)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    CONSTRAINT fk_customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customers(CustomerID),
    SKU VARCHAR(20),
    Description VARCHAR(50)
);

CREATE TABLE RMA (
    RMAID INT PRIMARY KEY,
    OrderID INT,
    CONSTRAINT fk_order
    FOREIGN KEY (OrderID)
    REFERENCES Orders(OrderID),
    Step VARCHAR(50),
    Status VARCHAR(15),
    Reason VARCHAR(25)
);

-- Load data from CSV files into tables
LOAD DATA INFILE 'home/codio/workspace/customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';

LOAD DATA INFILE 'home/codio/workspace/orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';

LOAD DATA INFILE 'home/codio/workspace/rma.csv'
INTO TABLE RMA
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';

/* ---- Write basic queries against imported tables to organize and analyze
target data. ----

1. Write an SQL query that returns the count of orders for customers 
located only in Framingham, Massachusetts. */
SELECT Customers.State, Customers.City, COUNT(Orders.OrderID) AS Orders
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE Customers.State = 'Massachusetts' AND Customers.City = 'Framingham';

-- 2. Write an SQL query to select all of the Customers located in the state of Massachusetts.
SELECT *
FROM Customers
WHERE State = 'Massachusetts';

-- 3. Write queries to insert four new records into the Orders and Customers tables.

INSERT INTO Customers VALUES(100004,"Luke","Skywalker","15 Maiden Lane","New York","New York",10222,"212-555-1234"),
(100005,"Winston","Smith","123 Sycamore Street","Greensboro","North Carolina",27401,"919-555-6623"),
(100006,"MaryAnne","Jenkins","1 Coconut Way","Jupiter","Florida",33458,"321-555-8907"),
(100007,"Janet","Williams","55 Redondo Beach Blvd","Torrence","California",90501,"310-555-5678");

INSERT INTO Orders VALUES(1204305, 100004, "ADV-24-10C", "Advanced Switch 10GigE Copper 24 port"),
(1204306, 100005, "ADV-48-10F", "Advanced Switch 10 GigE Copper/Fiber 44 port copper 4 port fiber"),
(1204307, 100006, "ENT-24-10F", "Enterprise Switch 10GigE SFP+ 24 Port"),
(1204308, 100007, "ENT-48-10F", "Enterprise Switch 10GigE SFP+ 48 port");

-- 4. Perform a query to count all records where the city is Woonsocket, Rhode Island.
SELECT State, City, COUNT(CustomerID)
FROM Customers
WHERE State = 'Rhode Island' AND City = 'Woonsocket';

-- 5. Write an SQL statement to select the current fields of status and step for the record in the RMA table with an OrderID of 5175.
SELECT OrderID, Status, Step
FROM RMA
WHERE OrderID = 5175;

-- 6. Write an SQL statement to update the status and step to status = 'Complete' and step = 'Credit Customer Account'.
UPDATE RMA
SET Status = 'Complete', Step = 'Credit Customer'
WHERE OrderID = 5175;

-- 7. Write an SQL statement to delete all records with a reason of 'Rejected'.
DELETE FROM RMA
WHERE Reason = 'Rejected';

-- 8. Rename all instances of "Customer" to "Collaborator".
CREATE OR REPLACE VIEW Collaborators AS
SELECT CustomerID AS CollaboratorID, FirstName, LastName, Street, City, State, ZipCode, Telephone
FROM Customers;

--9. Create an output file of the contents of the Orders table.
SELECT * 
FROM Orders   
INTO OUTFILE '/home/codio/workspace/QuantigrationOrders.csv' 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n';


-- PART TWO --
-- Full analysis is in Word document report.

-- 1. Analyze the number of returns by state.
SELECT Customers.State, COUNT(RMA.RMAID) AS Returns, COUNT(Orders.OrderID) AS Sales, ((COUNT(RMA.RMAID)/COUNT(Orders.OrderID))*100) AS ReturnPercent
FROM Customers
INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
LEFT JOIN RMA
ON Orders.OrderID = RMA.OrderID
GROUP BY Customers.State
ORDER BY COUNT(RMA.RMAID) DESC;

-- 2. Analyze the percentage of returns by product type.
SELECT Orders.SKU, Orders.Description, COUNT(Orders.OrderID) AS Sales, COUNT(RMA.RMAID) AS Returns, ((COUNT(RMA.RMAID)/COUNT(Orders.OrderID))*100) AS ReturnPercent
FROM Orders
LEFT JOIN RMA
ON Orders.OrderID = RMA.OrderID
GROUP BY Orders.SKU
ORDER BY ((COUNT(RMA.RMAID)/COUNT(Orders.OrderID))*100) DESC;

-- I exported the tables into CSV files to create visual analytic in Tableau.
-- https://public.tableau.com/app/profile/valerie.montalvo/viz/DAD2207-1/RMAReasonPercentage

SELECT * 
FROM Orders   
INTO OUTFILE '/home/codio/workspace/NewOrders.csv' 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n';

SELECT * 
FROM RMA  
INTO OUTFILE '/home/codio/workspace/NewRMA.csv' 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n';

SELECT * 
FROM Customers 
INTO OUTFILE '/home/codio/workspace/NewCustomers.csv' 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n';