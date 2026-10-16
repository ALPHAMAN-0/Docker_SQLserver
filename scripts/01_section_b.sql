-- Tables + data for the .Net_B_Fall_26-27 course projects (database: section_b).
--
-- Just save this file. The "sqlserver-watch" container then deletes section_b, creates it
-- empty and runs this whole file inside it, so write plain SQL (no IF NOT EXISTS needed).
-- Results and errors of the last run: scripts-run.log
-- Don't add CREATE DATABASE or USE: the file already runs inside section_b.
-- Every save erases data your apps added to section_b.

-- IntroToEF_B -> Models/Product.cs
CREATE TABLE dbo.products (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(MAX) NOT NULL,
    description NVARCHAR(MAX) NULL,
    price       FLOAT         NOT NULL,
    stock       INT           NOT NULL,
    category    NVARCHAR(MAX) NOT NULL
);

-- IntroToMVC_B -> Models/StudentModel.cs, IntroToMVC_W2_Th -> Models/Student.cs
CREATE TABLE dbo.students (
    id   INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(MAX) NOT NULL,
    dept NVARCHAR(MAX) NOT NULL,
    cgpa REAL          NULL
);

-- IntroToMVC_W2_Lab -> Models/Employee.cs
CREATE TABLE dbo.employees (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    email       NVARCHAR(MAX) NOT NULL,
    name        NVARCHAR(MAX) NOT NULL,
    designation NVARCHAR(MAX) NOT NULL,
    age         INT           NULL,
    salary      INT           NOT NULL
);
GO

-- Sample rows
INSERT INTO dbo.products (name, description, price, stock, category) VALUES
    ('Laptop',     '14 inch, 16GB RAM', 85000, 10,  'Electronics'),
    ('Headphones', 'Wireless',           4500, 25,  'Electronics'),
    ('Notebook',   NULL,                  120, 200, 'Stationery');

INSERT INTO dbo.students (name, dept, cgpa) VALUES
    ('John Doe',   'Computer Science', 3.5),
    ('Jane Smith', 'EEE',              3.8),
    ('Rahim Uddin','BBA',              NULL);

INSERT INTO dbo.employees (email, name, designation, age, salary) VALUES
    ('email0@example.com', 'Employee 0', 'Designation 0', 25, 50000),
    ('email1@example.com', 'Employee 1', 'Designation 1', 26, 51000),
    ('email2@example.com', 'Employee 2', 'Designation 2', 27, 52000),
    ('email3@example.com', 'Employee 3', 'Designation 3', 28, 53000),
    ('email4@example.com', 'Employee 4', 'Designation 4', 29, 54000);
GO

-- Queries: their results show up in scripts-run.log
SELECT * FROM dbo.products;
