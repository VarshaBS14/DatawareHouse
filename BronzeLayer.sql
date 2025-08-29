/*
===================================================
Create Database and Schemas
===================================================
Script Purpose: 
    This script creates a new database names 'DataWarehouse' after checking if it already exists. 
    IF the database exists, it is dropped and recreated. 
    Additionaly, the script sets up three schemas within the database: 'bronze', 'silver' and 'gold'. 

WARNING: 
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in this database will be premanently deleted. Proceed with caution
    and ensure you have a proper backup before running this script. 
*/ 

USE master; 
GO 

-- Drop and create the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
    DROP DATABASE DataWarehouse; 
END; 
GO

-- Create Database 'DataWarehouse'
CREATE DATABASE DataWarehouse; 
GO 

USE DataWarehouse; 
GO 

-- Create Schemas
CREATE SCHEMA bronze; 
GO

CREATE SCHEMA silver; 
GO

CREATE SCHEMA gold; 
GO

/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cast_key NVARCHAR(50),
    cst_firstname NVARCHAR(50), 
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
); 

IF OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50), 
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);

IF OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT, 
    sls_quantity INT,
    sls_price INT
);

IF OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_loc_a101' , 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
    cid NVARCHAR(50), 
    cntry NVARCHAR(50),
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
)

SET NOCOUNT ON --reduce the network traffic by stopping the msg that shows the nb of rows affected
BULK INSERT bronze.crm_cust_info
FROM 'datasets/source_crm/cust_info.csv'  -- within the container, he location of the file
WITH(
    DATA_SOURCE = 'dataset',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK -- Minimize the number of log records for the insert operation
);

--inserting data into table
BULK INSERT bronze.crm_cust_info
FROM 'D:\VARSHA\sql-datawarehouse-project-main\datasets\source_crm\cust_info.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- if your file has headers
)

BULK INSERT bronze.crm_prd_info
FROM 'D:\VARSHA\sql-datawarehouse-project-main\datasets\source_crm\prd_info.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- if your file has headers
)

BULK INSERT bronze.crm_sales_details
FROM 'D:\VARSHA\sql-datawarehouse-project-main\datasets\source_crm\sales_details.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- if your file has headers
)

BULK INSERT bronze.erp_cust_az12
FROM 'D:\VARSHA\sql-datawarehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- if your file has headers
)

BULK INSERT bronze.erp_loc_a101
FROM 'D:\VARSHA\sql-datawarehouse-project-main\datasets\source_erp\LOC_A101.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- if your file has headers
)

BULK INSERT bronze.erp_PX_CAT_G1V2
FROM 'D:\VARSHA\sql-datawarehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- if your file has headers
)

select distinct *
from bronze.crm_cust_info