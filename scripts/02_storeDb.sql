-- storeDb: a separate database with a Products table and 5 sample rows.
--
-- The "sqlserver-watch" container runs this file after 01_section_b.sql on every save in
-- scripts/. It deletes storeDb and creates it again, so rows your apps added are erased.
-- Put rows you want to keep as INSERTs below.

USE master;
GO

IF DB_ID('storeDb') IS NOT NULL
BEGIN
    ALTER DATABASE storeDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- disconnects SSMS/apps
    DROP DATABASE storeDb;
END
GO

CREATE DATABASE storeDb;
GO

USE storeDb;
GO

-- Without this, ids jump by ~1000 (e.g. 3 -> 1002) after every server restart
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF;
GO

CREATE TABLE dbo.Products (
    Id       INT IDENTITY(1,1) PRIMARY KEY,
    Name     NVARCHAR(100)  NOT NULL,
    Category NVARCHAR(50)   NOT NULL,
    Price    DECIMAL(10,2)  NOT NULL CHECK (Price >= 0),
    Stock    INT            NOT NULL CHECK (Stock >= 0),
    AddedAt  DATETIME2(0)   NOT NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO dbo.Products (Name, Category, Price, Stock, AddedAt) VALUES
    ('Laptop',          'Electronics', 85000.00,  10, '2026-11-01 10:00:00'),
    ('Wireless Mouse',  'Electronics',  1500.00,  40, '2026-11-03 14:30:00'),
    ('Office Chair',    'Furniture',   12500.00,   8, '2026-11-05 09:15:00'),
    ('Notebook (A5)',   'Stationery',    120.00, 200, '2026-11-10 11:45:00'),
    ('Water Bottle',    'Kitchen',       650.00,  60, '2026-11-15 16:20:00');
GO

-- Result shows up in scripts-run.log
SELECT * FROM dbo.Products;
