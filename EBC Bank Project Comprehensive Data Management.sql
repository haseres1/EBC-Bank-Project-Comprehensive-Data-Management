/*
  EBC Bank Project Database Creation Script
  This script creates the EBC Bank Project database and its associated tables.
  It includes tables for regions, branches, employees, account types, customers, accounts, and transaction details.
  Additionally, it sets up a data warehouse with dimension and fact tables for advanced analytics.
*/

-- Drop existing database if it exists and create a new one
DROP DATABASE IF EXISTS EBC_Bank_Project;
CREATE DATABASE EBC_Bank_Project;
USE EBC_Bank_Project;

-- Table 1: Region
CREATE TABLE region (
    Region_ID INTEGER PRIMARY KEY IDENTITY,
    REGION_NAME CHAR(10) NOT NULL,
    IsActive BIT DEFAULT(1),
    CreatedDate DATETIME DEFAULT(GETDATE()),
    ModifiedDate DATETIME
);

-- Table 2: Branch (2 branches in each of the 4 regions, total 8 branches)
CREATE TABLE Branch (
    Branch_ID INT PRIMARY KEY IDENTITY,
    BRANCH_NAME VARCHAR(30) NOT NULL,
    BRANCH_ADDRESS VARCHAR(50) NOT NULL,
    Region_ID INT NOT NULL FOREIGN KEY REFERENCES region(Region_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    IsActive BIT DEFAULT(1),
    CreatedDate DATETIME DEFAULT(GETDATE()),
    ModifiedDate DATETIME
);

-- Table 3: Employee (3 employees per branch, total 24 employees)
CREATE TABLE [Employee] (
    Employee_ID INTEGER PRIMARY KEY IDENTITY,
    [Employee_NAME] VARCHAR(30) NOT NULL,
    DESIGNATION CHAR(7) NOT NULL CHECK (DESIGNATION IN ('MANAGER', 'TELLER', 'CLERK')),
    Branch_ID INT FOREIGN KEY REFERENCES Branch(Branch_ID),
    IsActive BIT DEFAULT(1),
    CreatedDate DATETIME DEFAULT(GETDATE()),
    ModifiedDate DATETIME
);

-- Table 4: Account Type (4 account types)
CREATE TABLE Account_Type (
    AccountType_ID INT PRIMARY KEY IDENTITY,
    Accounttype_Name VARCHAR(20) NOT NULL,
    IsActive BIT DEFAULT(1),
    CreatedDate DATETIME DEFAULT(GETDATE()),
    ModifiedDate DATETIME
);
ALTER TABLE Account_Type ADD CONSTRAINT UQ_accountname UNIQUE (Accounttype_Name);

-- Table 5: Customer (5 customers in each branch, total 40 customers)
CREATE TABLE Customer (
    Customer_ID INTEGER PRIMARY KEY IDENTITY,
    [Customer_Name] VARCHAR(40) NOT NULL,
    [ADDRESS] VARCHAR(50) NOT NULL,
    Branch_ID INT NOT NULL FOREIGN KEY REFERENCES Branch(Branch_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    IsActive BIT DEFAULT(1),
    CreatedDate DATETIME DEFAULT(GETDATE()),
    ModifiedDate DATETIME
);
ALTER TABLE Customer ADD CONSTRAINT UQ_Name_Address_Customer UNIQUE ([ADDRESS], Customer_Name);

-- Table 6: Account
CREATE TABLE Account (
    Account_ID INT PRIMARY KEY IDENTITY(1,1),
    Customer_ID INT NOT NULL FOREIGN KEY REFERENCES Customer(Customer_ID),
    AccountType_ID INT NOT NULL FOREIGN KEY REFERENCES Account_Type(AccountType_ID) ON DELETE NO ACTION ON UPDATE CASCADE,
    CLEAR_BALANCE MONEY NULL,
    UNCLEAR_BALANCE MONEY NULL,
    [Status] CHAR(40) NOT NULL CHECK ([Status] IN ('OPERATIVE', 'INOPERATIVE', 'CLOSED')) DEFAULT ('OPERATIVE'),
    IsActive BIT DEFAULT(1),
    CreatedDate DATETIME DEFAULT(GETDATE()),
    ModifiedDate DATETIME
);

-- Additional constraints for Account table
ALTER TABLE Account ADD CONSTRAINT chk_CLEAR_UNCLEAR_BALANCE_Account CHECK (UNCLEAR_BALANCE > CLEAR_BALANCE);
ALTER TABLE Account ADD CONSTRAINT chk_Savings_Account CHECK ((CLEAR_BALANCE) > 1000);
ALTER TABLE Account ADD CONSTRAINT UK_customer_id_and_Account_id UNIQUE (Customer_ID, AccountType_ID);

-- Table 7: TransactionDetail (5 transactions for each branch, total 40 transactions)
CREATE TABLE [TransactionDetail] (
    TRANSACTION_ID INTEGER PRIMARY KEY IDENTITY,
    TRANSACTION_Date DATETIME NOT NULL DEFAULT GETDATE(),
    Customer_ID INTEGER NOT NULL FOREIGN KEY REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    Branch_ID INT NOT NULL FOREIGN KEY REFERENCES Branch(Branch_ID) ON DELETE NO ACTION ON UPDATE NO ACTION,
    TransactionType_ID INT NOT NULL FOREIGN KEY REFERENCES TransactionType(TransactionType_ID),
    Check_Number INTEGER NULL,
    Check_Date DATETIME NULL,
    Transaction_Amount MONEY NOT NULL,
    Employee_ID INTEGER NOT NULL FOREIGN KEY REFERENCES [Employee](Employee_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    IsActive BIT DEFAULT(1),
    CreatedDate DATETIME DEFAULT(GETDATE()),
    ModifiedDate DATETIME
);

-- Additional constraints for TransactionDetail table
ALTER TABLE [TransactionDetail] ADD CONSTRAINT CHK_Transaction_Date CHECK (TRANSACTION_Date <= GETDATE() AND Check_Date <= GETDATE());
ALTER TABLE [TransactionDetail] ADD CONSTRAINT chk_CHQ_DATE_TRANSACTION_Date_TRANSACTION CHECK (TRANSACTION_Date >= Check_Date);
ALTER TABLE [TransactionDetail] ADD CONSTRAINT chk_CHQ_DATE_TRANSACTION CHECK (Check_Date < DATEADD(MONTH, 6, GETDATE()));
ALTER TABLE [TransactionDetail] ADD CONSTRAINT chk_TXN_AMOUNT_TRANSACTION CHECK (Transaction_Amount > 0);
ALTER TABLE [TransactionDetail] ADD CONSTRAINT chk_TXN_TYPE_TRANSACTION CHECK (TransactionType_ID IN ('1', '3', '2'));

/*
  Insert statements for the EBC Bank Project database.
  These include insertion of data into the region, branch, employee, account_type, customer, and account tables.
  Followed by transaction detail records for each branch.
*/

-- Insert records into tables
-- Insert statements for regions
INSERT INTO region VALUES ('Southern', 1, '01/01/2018', '05/01/2022'), 
                           ('Northern', 1, '12/10/2020', '03/02/2022'),
                           ('Eastern', 1, '01/04/2019', '05/03/2022'),
                           ('Central', 1, '04/04/2021', NULL);

-- Insert statements for branches
INSERT INTO branch (Branch_Name, Branch_Address, Region_ID)
VALUES ('Florida Branch', '2398 Georgia Ave', 1),
       ('Maryland Branch', '289 West Ave', 2),
       ('New Jersey Branch', '1298 Randolph Ave', 3),
       ('Washington Branch', '4592 Kennedy Street', 1),
       ('New York Branch', '1456 New York Ave', 2),
       ('California Branch', '908 Washington Ave', 4),
       ('Dallas Branch', '564 Versville Ave', 3),
       ('Texas Branch', '4592 Colie Dr', 4);

-- Insert statements for account types
INSERT INTO Account_Type (AccountType_Name) VALUES
('Debit Card'),
('Credit Card'),
('Saving Account'),
('Checking Account');

-- Insert statements for employees
Insert into Employee values('Alex','Teller',1,1,'03/08/2019','11/20/2021')    ---- Florida Branch
,('Yitbarek','Manager',1,1,'02/20/2018',getdate())
,('Hilina','Clerk',1,1,'04/11/2019',getdate())

Insert INTO Employee (Employee_NAME, DESIGNATION, branch_id) Values 
('Dan', 'MANAGER', 2),                ----------------------------------------------Maryland Branch
('Helen', 'TELLER', 2),
('Jone', 'CLERK', 2)
insert into employee ([Employee_NAME], DESIGNATION, branch_id) values --from yitbark
('Alex', 'Manager', 3),               -------------------------------------------------NewJersy Branch
('Yitbark', 'Teller', 3),
('Bruk', 'clerk', 3),
('Shandra','Manager', 4),                        ---------------------------------------Washington Branch
('Llywellyn','clerk',4),
('Barbra', 'teller', 4)
Insert into Employee  Values('Josh','Teller',5,1, '05/10/2021','05/11/2022'); -------------New York Branch
Insert into Employee  Values('Kevin','Manager',5,1, '06/07/2021','06/09/2022');
Insert into Employee  Values ('Andre','Clerk',5,1,'09/05/2019',getdate());

Insert into Employee  Values('Tenbit','Teller',6,1, '05/10/2021','05/11/2022');-------------California Branch(Mihret)
Insert into Employee  Values('Dawit','Manager',6,1, '06/07/2021','06/09/2022');
Insert into Employee  Values ('Mulu','Clerk',6,1,'09/05/2019',getdate());

Insert into Employee  Values('Meti','Teller',7,1, '07/11/2021','07/11/2022');   -------------Dallas Branch(Mihret)
Insert into Employee  Values('James','Manager',7,1, '04/05/2021','04/09/2022');
Insert into Employee  Values ('Nati','Clerk',7,1,'02/04/2019',getdate());

Insert into Employee  Values('Nahi','Teller',8,1, '01/11/2021','01/11/2022');   ------------Texas Branch(Mihret)
Insert into Employee  Values('Yoni','Manager',8,1, '03/09/2021','04/09/2022');
Insert into Employee  Values ('Yohi','Clerk',8,1,'03/05/2019',getdate());
-----------------------------------------------------------

 --1st Branch, 5 customers 
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID)VALUES 
							('Tome','2711 Market Ln',1),
                           ('Azeb','4869 Salley Ln',1),
						   ('Muluwork','534 Norhstar Ave',1),
						   ('Yitbark','6273 Jonathon Dr',1),
						   ('Yona','6251 Woodline Dr',1)
--2nd Branch, 5 customers  
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID) VALUES 
						   ('Yonas','6451 Wood Dr',2),
						   ('Yohi','5201 Alexandria pl',2),
						   ('Alem','201 line Dr',2),
						   ('Kidist','5162 Radfor Dr',2),
						   ('Tinbit','1422 Oldtown pl',2)  
--3rd Branch, 5 customers  
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID)VALUES('Christen','87085 Heffernan Road',3),
                          ('Ashley','10460 Orin Terrace',3),
						  ('Jordain','62255 Ramsey Terrace',3),
						  ('Loralyn','87085 Heffernan Road',3),
						  ('Elvyn','323 Glendale Avenue',3)

--4th Branch, 5 customers 
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID)VALUES('Niko','5 Lillian Point',4),
                     ('Betsy','42 Corben Trail',4),
					 ('Mel','870810 Graedel Drive',4),
					 ('Xylina','1 Golf Center',4),
					 ('Jim','4764 Scoville Hill',4)

--5th Branch, 5 customers 
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID)VALUES ('Meheret','1117 7th Ave',5),
                      ('Lina','4401 Rossi St',5),
					  ('Stephani','14703 Aspen hillRoad',5),
					  ('Gary','13910 Long	Meade',5),
					  ('Yared','2132 Georgia Avenue',5)

--6th Branch 5 customers
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID)VALUES ('Jackson','2224 Bitch Drive',6),
                      ('Sam','5672 Aspen wood Drive',6),
					  ('John','2892 Wheaton road',6),
					  ('Glen','7634 Newhampshier Avenue',6),
					  ('Alexa','1444 Bluvard court',6)


--7th Branch 5 customers
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID)VALUES('Alen','1454 Bluvard court',7),
                     ('Abraham','3278 DareWood Drive',7),
					 ('Ephrem','1429 GlenAllen Avenue',7),
					 ('Sami','1329 GnAllen Avenue',7),
					 ('who','429 Alexanri Avenue',7)


--8th Branch 5 customers
INSERT INTO Customer (Customer_Name,ADDRESS,Branch_ID)VALUES('Alemu','2454 Bluvard court',8),
                      ('Hawi','2524 Arlington court',8),
					  ('Sole','1425 Arlington Blvd',8),
					  ('mercy','9393 washington court',8),
					  ('marthi','1234 old court',8)

-----------------------------------------------------
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES  (1,1,40000,110000,'Operative')
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES (1,2,5000,80000,'Operative')
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES(2,1,10000,700000,'Operative')
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES(2,4,10000,50000,'Operative')
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES(3,3,40000,900000,'Operative')
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES(3,2,40000,900000,'Operative')
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES(4,1,50000,600000,'Operative')
INSERT INTO Account(Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) VALUES(4,3,50000,9200000,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(5,1,30450,45970,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(5,2,33020,42927,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(6,1,11567,26000,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(7,2,9789,12504,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(8,1,21090,23675,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(9,2,5467,9789,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(10,1,12435,16789,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(10,2,9807,9908,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(11,1,67853,87209,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(12,2,67876,70768,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(13,1,55463,57689,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(13,2,35678,42100,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(14,1,23678,52100,'Operative')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(14,2,23878,52100,'INOPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(15,1,13878,122100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(16,1,2678,52100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(16,2,38678,42100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(17,1,38678,52100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(17,3,2678,42100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(17,4,2378,52100,'INOPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(18,1,4878,12100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(18,4,23678,52100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(19,2,5678,62100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(20,1,7678,42100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(20,3,4378,72100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(21,1,2378,52100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(22,2,24878,42100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(23,2,1678,52100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(24,1,38678,52100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(25,1,78678,352100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(25,3,78678,352100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(26,2,18678,52100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(27,1,2878,92100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(27,3,6748,12100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(28,2,1878,12100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(29,1,2278,92100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(30,2,6378,92100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(31,1,28678,32100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(31,4,28678,42100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(32,1,28678,32100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(32,2,28678,32100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(33,2,8678,102100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(34,1,28678,32100,'CLOSED')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(34,3,58678,332100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(35,1,48678,432100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(35,4,18678,32100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(36,2,78678,132100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(37,1,6278,42100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(37,3,1678,2100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(38,2,15678,72100,'OPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(39,1,1678,2100,'INOPERATIVE')
Insert into Account (Customer_ID,AccountType_ID,CLEAR_BALANCE, UNCLEAR_BALANCE,status) values(40,2,1678,2100,'INOPERATIVE')

dbcc checkident(factstagingcustomer,reseed,100)
dbcc checkident(stagingbranch,reseed,100)
dbcc checkident(Account_type,reseed,0)
dbcc checkident(Customer,reseed,0)
dbcc checkident(TransactionDetail,reseed,0)
dbcc checkident(employee,reseed,0)
---------------------------------------
--5 TRANSACTION FOR THE 1ST BRANCH 
insert into TransactionDetail (Transaction_date,Customer_ID,Branch_ID,transactionType_ID,check_number,  -- from yitbark
Check_Date,Transaction_amount,Employee_ID) values 
('01/23/2022',1,1, '2', 13890454, '01/23/2022',1200,1),
('03/29/2022',2,1, '2', 8932233, '03/20/2022',12200,2),
('03/23/2022',3,1,'2',1234568,	'01/12/2022', 4500,3),			
('10/23/2021',4,1,'2',3490832,'10/13/2021',5500,2),
('11/09/2021',5,1,'2', 45476876, '10/02/2021', 23000, 3),
('10/15/2021',13,3,'2', 1234, '09/21/2021',500,8)

--5 TRANSACTION FOR THE 2ND BRANCH 
insert into TransactionDetail (Transaction_date,Customer_ID,Branch_ID,  ----- from yitbark
transactionType_ID,Transaction_amount,Employee_ID) values 
('05/3/2022', 6,2, '1',18000,4),
('04/30/2022',7,2, '3', 30000, 4),
('01/23/2022',8,2 ,'3', 30000, 5),
('12/27/2021',9,2, '3', 30000, 6),
('11/20/2021',10,2, '1', 30000, 6)

--5 TRANSACTION FOR THE 3RD BRANCH

Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
('05/01/22',11,3,'3',8000,7),
('04/20/21',12,3,'1',450,7),
('02/20/20',14,3,'3',1400,8),
('09/10/17',15,3,'1',1234,9)

--5 TRANSACTION FOR THE 4TH BRANCH
Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,check_number,Check_Date,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
('02/25/2022',16,4,900,'02/20/2022','2',5676,10),
('11/10/21',17,4,212,'10/10/2021','2',900,10)
Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
('12/20/21',18,4,'1',367,11),
('12/10/21',19,4,'1',900,12),
('08/23/19',20,4,'3',2020,12)

--5 TRANSACTION FOR THE 5TH BRANCH
Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,check_number,Check_Date,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
('12/06/21',21,5,900,'11/20/2021','2',5676,13),
('10/10/21',22,5,212,'10/10/2021','2',900,13)
Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
('11/20/21',23,5,'1',367,14),
('04/10/21',24,5,'1',900,14),
('08/23/19',25,5,'3',2020,15)

--5 TRANSACTION FOR THE 6TH BRANCH
Insert into  [TransactionDetail] (Transaction_date,Customer_ID,Branch_ID,check_number,Check_Date,transactionType_ID,  --from azeb
Transaction_Amount,Employee_ID) Values
			('02/03/2022',26,6,1001,'01/02/2022','2',1000,16),
			('04/02/2022',28,6,1003,'02/20/2022','2',500,16)
Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
			('02/20/2022',29,6,'3',1400,17),
			('12/02/2021',30,6,'1',2000,18),
			('07/02/2019',27,6,'1',200,16)

--5 TRANSACTION FOR THE 7TH BRANCH
Insert into  [TransactionDetail] (Transaction_date,Customer_ID,Branch_ID,check_number,Check_Date,transactionType_ID,  --from azeb
				Transaction_Amount,Employee_ID) Values
			('05/09/2022',31,7,1006,'05/1/2022','2',5000,19),
			('04/10/2022',32,7,1007,'1/1/2022','2',9000,19)
Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
			('12/20/2021',33,7,'1',3000,20),
			('12/10/2019',34,7,'1',9000,20),
			('08/23/2019',35,7,'3',7000,21)

--5 TRANSACTION FOR THE 8TH BRANCH
Insert into  [TransactionDetail] (TRANSACTION_Date,Customer_ID,Branch_ID,check_number,Check_Date,transactionType_ID,  --from azeb
Transaction_Amount,Employee_ID) Values
			('05/07/2022',36,8,1006,'05/1/2022','2',5000,22),
			('03/10/2022',37,8,1007,'1/1/2022','2',9000,23)
Insert into  [Transactiondetail] (Transaction_date,Customer_ID,Branch_ID,transactionType_ID,  --- from bruk
Transaction_Amount,Employee_ID) 	Values
			('11/20/2021',38,8,'1',3000,24),
			('12/10/2019',39,8,'1',9000,22),
			('08/23/2019',40,8,'3',7000,23)
---------------

create database [EBC_Bank_ProjectDW]
use  [EBC_Bank_ProjectDW]
----------------------------------------
create table Dimregion		
		(DimRegion_ID	INTEGER	Primary Key
		,REGION_NAME	CHAR(10) NOT NULL
		,IsCurrent char(5) default 'true'
		,StartDate datetime null DEFAULT(GETDATE())
		,EndDate datetime null)
-----------------------------------------
create table DimBranch						
		(DimBranch_id INTEGER Primary Key
		,BRANCH_NAME	VARCHAR(30)	NOT NULL,
		BRANCH_ADDRESS	VARCHAR(50)	NOT NULL
		,IsCurrent char (5) default 'true',
		StartDate datetime DEFAULT(GETDATE()),
		EndDate datetime)
------------------------------------------
create table DimEmployee			
		(DimEmployee_ID	INTEGER	Primary Key,
		[Employee_NAME] VARCHAR(30)	NOT NULL,
		DESIGNATION	CHAR(7) NOT NULL
		,IsCurrent char (5) default 'true',
		StartDate datetime DEFAULT(GETDATE()),
		EndDate datetime)
-------------------------------------------
create table DimAccount_type  
		(DimAccountType_ID int Primary Key,
		Accounttype_Name VARCHAR(20)	not NULL
		,IsCurrent char (5) default 'true',
		StartDate datetime DEFAULT(GETDATE()),
		EndDate datetime)
-------------------------------------------
CREATE TABLE DimAccount  
		(DimAccount_ID int PRIMARY KEY
		,CLEAR_BALANCE	MONEY	NULL,
		UNCLEAR_BALANCE	MONEY	NULL,
		[status] CHAR(40) not null 
		,IsCurrent char (5) default 'true',
		StartDate datetime DEFAULT(GETDATE()),
		EndDate datetime)

-----------------------------------
create table DimCustomer (		
		DimCustomer_ID	INTEGER	Primary Key 
		,[Customer_Name]	VARCHAR(40)	NOT NULL ,
		[ADDRESS]	VARCHAR(50)	NOT NULL
		,IsCurrent char (5) default 'true',
		StartDate datetime DEFAULT(GETDATE()),
		EndDate datetime)
---------------------------------------------
create table StagingCustomer (
		StagingCustomerID int primary key identity
		,DimCustomer_ID int foreign key references dimcustomer(DimCustomer_ID)
		,MonthID int
		,YearID int
		,AvgClearBalance money
		,AvgUnclearBalance money
		,AvgTransaction_amount money)
--drop table stagingcustomer
select * from StagingCustomer
---------------------------------------------
create table factCustomer (
		FactCustomerID int primary key
		,DimCustomer_ID int foreign  key references dimcustomer(DimCustomer_ID)
		,MonthID int
		,YearID int
		,AvgClearBalance money
		,AvgUnclearBalance money
		,AvgTransaction_amount money)

select * from factCustomer
-----------------------------------------------
MERGE FactCustomer AS TARGET -- Target Table
USING stagingcustomer AS Source -- Source Table
ON (TARGET.DimCustomer_ID = Source.DimCustomer_ID and target.MonthId = Source.yearId)
WHEN MATCHED
AND (TARGET.AvgClearBalance <> Source.AvgClearBalance
OR TARGET.AvgUnclearBalance <> Source.AvgUnclearBalance
OR TARGET.AvgTransaction_amount <> Source.AvgTransaction_amount)
THEN UPDATE
SET TARGET.AvgClearBalance = Source.AvgClearBalance
, TARGET.AvgUnclearBalance = Source.AvgUnclearBalance
, TARGET.AvgTransaction_amount = Source.AvgTransaction_amount
WHEN NOT MATCHED BY TARGET
THEN INSERT(FactCustomerID,DimCustomer_ID,MonthId,yearId,AvgClearBalance, AvgUnclearBalance,AvgTransaction_amount)
VALUES (Source.StagingCustomerID, Source.DimCustomer_ID,Source.MonthId,Source.yearId, Source.AvgClearBalance, 
Source.AvgUnclearBalance,source.AvgTransaction_amount)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;
-------------------

create procedure sp_mergetoFctBranch
as
begin
MERGE FactBranch AS TARGET -- Target Table
USING stagingbranch AS Source -- Source Table
ON (TARGET.DimBranch_id = Source.DimBranch_id and TARGET.MonthId = Source.MonthId)
WHEN MATCHED
AND (TARGET.AvgClearBalance <> Source.AvgClearBalance
OR TARGET.AvgUnclearBalance <> Source.AvgUnclearBalance
OR TARGET.AvgTransaction_amount <> Source.AvgTransaction_amount)
THEN UPDATE
SET TARGET.AvgClearBalance = Source.AvgClearBalance
, TARGET.AvgUnclearBalance = Source.AvgUnclearBalance
, TARGET.AvgTransaction_amount = Source.AvgTransaction_amount
WHEN NOT MATCHED BY TARGET
THEN INSERT(FactBranch_id,DimBranch_id,MonthId,yearId,totalnumberofcustomer,AvgClearBalance,AvgUnclearBalance,AvgTransaction_amount)
VALUES (Source.StagingBranch_id, Source.DimBranch_id,Source.MonthId,Source.yearId,Source.totalnumberofcustomer,Source.AvgClearBalance,
Source.AvgUnclearBalance,source.AvgTransaction_amount)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;
end
go
execute sp_mergetoFctBranch
----------------------------------------
create procedure sp_mergetoFctCustomer
as
begin
MERGE FactCustomer AS TARGET -- Target Table
USING stagingcustomer AS Source -- Source Table
ON (TARGET.DimCustomer_ID = Source.DimCustomer_ID and target.MonthId = Source.yearId)
WHEN MATCHED
AND (TARGET.AvgClearBalance <> Source.AvgClearBalance
OR TARGET.AvgUnclearBalance <> Source.AvgUnclearBalance
OR TARGET.AvgTransaction_amount <> Source.AvgTransaction_amount)
THEN UPDATE
SET TARGET.AvgClearBalance = Source.AvgClearBalance
, TARGET.AvgUnclearBalance = Source.AvgUnclearBalance
, TARGET.AvgTransaction_amount = Source.AvgTransaction_amount
WHEN NOT MATCHED BY TARGET
THEN INSERT(FactCustomerID,DimCustomer_ID,MonthId,yearId,AvgClearBalance, AvgUnclearBalance,AvgTransaction_amount)
VALUES (Source.StagingCustomerID, Source.DimCustomer_ID,Source.MonthId,Source.yearId, Source.AvgClearBalance, 
Source.AvgUnclearBalance,source.AvgTransaction_amount)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;
end
go

execute sp_mergetoFctCustomer
-------------------------------------------
--drop table StagingBranch
create table StagingBranch						
		(StagingBranch_id INTEGER Primary Key identity
		,DimBranch_id int foreign key references dimbranch(dimbranch_id)
		,MonthID int
		,YearID int
		,TotalNumberOfCustomer int
		,AvgClearBalance money
		,AvgUnclearBalance money
		,AvgTransaction_amount money)

select * from StagingBranch
--------------------------
--drop table factBranch
create table FactBranch						
		(FactBranch_id INTEGER Primary Key
		,DimBranch_id int foreign key references dimbranch(dimbranch_id)
		,MonthID int
		,YearID int
		,TotalNumberOfCustomer int
		,AvgClearBalance money
		,AvgUnclearBalance money
		,AvgTransaction_amount money)

select * from FactBranch
-------------------------------
alter view vwFactBranch
as
select c.Branch_ID
,MONTH(TRANSACTION_Date) AS MonthID
,Year(TRANSACTION_Date) AS YearID
,sum(c.customer_id) as TotalNumberOfCustomer
,avg(t.Transaction_amount) AvgTransactionAmount 
,avg(a.clear_balance) AvgClearBalance 
,avg(a.unclear_Balance) AvgUnclearBalance 
from customer C
join TransactionDetail T
on t.Customer_ID = c.Customer_ID 
join account A
on c.customer_id = a.customer_id
group by c.Branch_ID
,MONTH(TRANSACTION_Date) 
,Year(TRANSACTION_Date)
GO

alter view [dbo].[vwFactCustomer]
as
select c.Customer_ID
,MONTH(t.TRANSACTION_Date) AS MonthID
,Year(t.TRANSACTION_Date) AS YearID
,avg(t.Transaction_amount) AvgTransactionAmount 
,avg(a.clear_balance) AvgClearBalance 
,avg(a.unclear_Balance) AvgUnclearBalance 
from customer C
join TransactionDetail T
on t.Customer_ID = c.Customer_ID 
join account A
on c.customer_id = a.customer_id
group by c.Customer_ID
,MONTH(t.TRANSACTION_Date)
,Year(t.TRANSACTION_Date)

select * from vwFactBranch
-------------------------------------
MERGE FactBranch AS TARGET -- Target Table
USING stagingbranch AS Source -- Source Table
ON (TARGET.DimBranch_id = Source.DimBranch_id and TARGET.MonthId = Source.MonthId)
WHEN MATCHED
AND (TARGET.AvgClearBalance <> Source.AvgClearBalance
OR TARGET.AvgUnclearBalance <> Source.AvgUnclearBalance
OR TARGET.AvgTransaction_amount <> Source.AvgTransaction_amount)
THEN UPDATE
SET TARGET.AvgClearBalance = Source.AvgClearBalance
, TARGET.AvgUnclearBalance = Source.AvgUnclearBalance
, TARGET.AvgTransaction_amount = Source.AvgTransaction_amount
WHEN NOT MATCHED BY TARGET
THEN INSERT(FactBranch_id,DimBranch_id,MonthId,yearId,totalnumberofcustomer,AvgClearBalance,AvgUnclearBalance,AvgTransaction_amount)
VALUES (Source.StagingBranch_id, Source.DimBranch_id,Source.MonthId,Source.yearId,Source.totalnumberofcustomer,Source.AvgClearBalance,
Source.AvgUnclearBalance,source.AvgTransaction_amount)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;
----------------
select * from stagingcustomer
select * from factcustomer
select * from stagingbranch
select * from factbranch
select * from dimcustomer
select * from  dimregion
select * from  dimbranch
select * from  dimEmployee
select * from  dimAccount_type
select * from  dimAccount











