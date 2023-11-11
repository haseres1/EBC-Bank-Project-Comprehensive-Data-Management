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
,TARGET.AvgUnclearBalance = Source.AvgUnclearBalance
,TARGET.AvgTransaction_amount = Source.AvgTransaction_amount
WHEN NOT MATCHED BY TARGET
THEN INSERT(FactCustomerID,DimCustomer_ID,MonthId,yearId,AvgClearBalance, AvgUnclearBalance,AvgTransaction_amount)
VALUES (Source.StagingCustomerID, Source.DimCustomer_ID,Source.MonthId,Source.yearId, Source.AvgClearBalance, 
Source.AvgUnclearBalance,source.AvgTransaction_amount)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;
-------------------
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
