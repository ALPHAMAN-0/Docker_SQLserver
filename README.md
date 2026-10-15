# SQL Server in Docker (shared by all .NET projects)

SQL Server 2022 in Docker for .NET development on macOS, including Apple Silicon.
One `docker compose up -d` starts the server and creates your databases and tables from the SQL scripts in `scripts/`.

Pairs with [EFBoilerplate](https://github.com/ALPHAMAN-0/EFBoilerplate), a `dotnet new` template for ASP.NET Core MVC + EF Core that's already connected to this database.

| Setting  | Value                                  |
|----------|----------------------------------------|
| Server   | `localhost`, port `1433`               |
| User     | `sa`                                   |
| Password | the one you set in `.env` (see Setup)  |

The port is bound to `127.0.0.1`, so only your own computer can connect.

## Setup

You need [Docker Desktop](https://www.docker.com/products/docker-desktop/).
On Apple Silicon, turn on **Settings → General → Use Rosetta for x86_64/amd64 emulation**, because SQL Server has no ARM image.

```sh
git clone https://github.com/ALPHAMAN-0/docker-sqlserver.git
cd docker-sqlserver
cp .env.example .env          # then open .env and choose your own SA password
docker compose up -d
```

`.env` is gitignored, so your password never gets committed.

## Start / stop

```sh
docker compose up -d                  # start the server and run every scripts/*.sql
docker compose logs sqlserver-init    # see what the scripts did
docker compose stop                   # stop (data is kept)
```

The server also starts by itself whenever Docker Desktop starts. That doesn't re-run the scripts; only `docker compose up -d` does.
Your databases are stored in the `mssql-data` volume, so they survive container rebuilds. Only `docker volume rm mssql-data` deletes them.

## Tables are created automatically

On every `docker compose up -d`, the `sqlserver-init` container waits for the server, runs each file in `scripts/` in name order, and then exits.

`scripts/01_section_b.sql` creates the `section_b` database with these tables:

| Table       | Columns                                       | Sample rows |
|-------------|-----------------------------------------------|-------------|
| `products`  | id, name, description, price, stock, category | 3 |
| `students`  | id, name, dept, cgpa                          | 3 |
| `employees` | id, email, name, designation, age, salary     | 5 |

**To add your own tables**, create a new file such as `scripts/02_lab5.sql` and run `docker compose up -d`.
The scripts run again on every `up`, so guard each statement so it only runs once:

```sql
USE section_b;
GO
IF OBJECT_ID('dbo.courses', 'U') IS NULL
    CREATE TABLE dbo.courses (
        id    INT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(MAX) NOT NULL
    );
GO
```

## Start a new project: `dotnet new efmvc`

See [EFBoilerplate](https://github.com/ALPHAMAN-0/EFBoilerplate). It's a template that creates a ready-to-run MVC + EF Core project wired to this database:

```sh
dotnet new efmvc -n Lab5
cd Lab5/Lab5
dotnet run                            # open http://localhost:5173/product
```

## Connection string for any .NET project

Put this in `appsettings.Development.json` (keep that file out of git) and change only `Database=` and `Password=`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost,1433;Database=section_b;User Id=sa;Password=YOUR_SA_PASSWORD;TrustServerCertificate=True"
}
```

Code that uses `Server=(localdb)\\MSSQLLocalDB;...;Trusted_Connection=True` only works on Windows.
On the Mac, replace it with the string above.

## DBeaver

1. **Database → New Database Connection → SQL Server → Next.**
2. Fill in the **Main** tab:
   - Host `localhost`, Port `1433`, Database `master`
   - Authentication: **SQL Server Authentication**, user `sa`, your password from `.env`, tick *Save password*
   - Tick **Trust server certificate**. If you don't see that box, open **Driver properties** and set `trustServerCertificate` = `true`.
   - Tick **Show all databases**.
3. Click **Test Connection**. Download the driver if DBeaver asks. Then click **Finish**.
4. To run queries: right-click the connection → **SQL Editor → New SQL script**.
   Pick `section_b` in the editor toolbar, or start with `USE section_b;`.
