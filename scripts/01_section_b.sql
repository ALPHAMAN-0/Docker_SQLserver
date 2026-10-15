-- Runs automatically on every "docker compose up" (service "sqlserver-init").
-- Database + tables for the .Net_B_Fall_26-27 course projects.
-- Every statement checks first, so running it again never deletes or duplicates data.

IF DB_ID('section_b') IS NULL
    CREATE DATABASE section_b;
GO

USE section_b;
GO

-- Without this, ids jump by ~1000 (e.g. 3 -> 1002) after every container restart
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF;
GO

-- IntroToEF_B -> Models/Product.cs
IF OBJECT_ID('dbo.products', 'U') IS NULL
    CREATE TABLE dbo.products (
        id          INT IDENTITY(1,1) PRIMARY KEY,
        name        NVARCHAR(MAX) NOT NULL,
        description NVARCHAR(MAX) NULL,
        price       FLOAT         NOT NULL,
        stock       INT           NOT NULL,
        category    NVARCHAR(MAX) NOT NULL
    );
GO

-- IntroToMVC_B -> Models/StudentModel.cs, IntroToMVC_W2_Th -> Models/Student.cs
IF OBJECT_ID('dbo.students', 'U') IS NULL
    CREATE TABLE dbo.students (
        id   INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(MAX) NOT NULL,
        dept NVARCHAR(MAX) NOT NULL,
        cgpa REAL          NULL
    );
GO

-- IntroToMVC_W2_Lab -> Models/Employee.cs
IF OBJECT_ID('dbo.employees', 'U') IS NULL
    CREATE TABLE dbo.employees (
        id          INT IDENTITY(1,1) PRIMARY KEY,
        email       NVARCHAR(MAX) NOT NULL,
        name        NVARCHAR(MAX) NOT NULL,
        designation NVARCHAR(MAX) NOT NULL,
        age         INT           NULL,
        salary      INT           NOT NULL
    );
GO

-- Sample rows, only added while a table is empty
IF NOT EXISTS (SELECT 1 FROM dbo.products)
    INSERT INTO dbo.products (name, description, price, stock, category) VALUES
        ('Laptop',     '14 inch, 16GB RAM', 85000, 10,  'Electronics'),
        ('Headphones', 'Wireless',           4500, 25,  'Electronics'),
        ('Notebook',   NULL,                  120, 200, 'Stationery');

IF NOT EXISTS (SELECT 1 FROM dbo.students)
    INSERT INTO dbo.students (name, dept, cgpa) VALUES
        ('John Doe',   'Computer Science', 3.5),
        ('Jane Smith', 'EEE',              3.8),
        ('Rahim Uddin','BBA',              NULL);

IF NOT EXISTS (SELECT 1 FROM dbo.employees)
    INSERT INTO dbo.employees (email, name, designation, age, salary) VALUES
        ('email0@example.com', 'Employee 0', 'Designation 0', 25, 50000),
        ('email1@example.com', 'Employee 1', 'Designation 1', 26, 51000),
        ('email2@example.com', 'Employee 2', 'Designation 2', 27, 52000),
        ('email3@example.com', 'Employee 3', 'Designation 3', 28, 53000),
        ('email4@example.com', 'Employee 4', 'Designation 4', 29, 54000);
GO
