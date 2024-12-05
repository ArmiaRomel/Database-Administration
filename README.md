# Database Administration

## Project Overview

In this project, I worked with a database dump file (`employeesdb.zip`)  and performed several key tasks:
1. **Data Import**: Loaded the data into MySQL from a SQL dump file.
2. **Query Optimization**: Improved query performance through indexing.
3. **Data Security**: Implemented AES encryption for sensitive data.
4. **Role and User Management**: Created roles and users with specific permissions.
5. **Automated Backups**: Created a shell script to automate weekly backups and enabled logs for point-in-time recovery.

## Database ERD

<img width="400" alt="employees-schema" src="https://github.com/user-attachments/assets/5b0226df-d56d-46fe-8b53-5c7815579f9d">

## Project Setup

### 1. Download and Extract the Database

The first step involves downloading the database file and extracting it:

```bash
wget https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBM-DB0231EN-SkillsNetwork/datasets/employeesdb.zip
unzip employeesdb.zip
```

### 2. Load the Data into MySQL

Once the database file is extracted, we start the MySQL server and load the `employees.sql` file:

```bash
sudo systemctl start mysql
sudo mysql -t < employees.sql
```

### 3. Query to Explore Database Tables

This query lists all tables in the `employees` database, along with their types

```sql
USE employees;
SELECT table_name, table_type FROM information_schema.tables WHERE table_schema='employees';
```

![6 1](https://github.com/user-attachments/assets/5372496e-f146-4e36-ab55-e0d02ab9db62)

This query filters the tables to show only the **BASE TABLES**, excluding views. Base tables are those that store actual data in which will be used in this project.

```sql
SELECT table_name, table_type FROM information_schema.tables WHERE table_schema='employees' AND table_type='BASE TABLE';
```

![6 2](https://github.com/user-attachments/assets/2929c0ab-a000-42c7-9799-fa32f4268691)

### 4. Query Performance Optimization

The performance of the query that selects all employees hired after `2000-01-01` is first evaluated:

```sql
SELECT * FROM employees WHERE hire_date >= '2000-01-01';
```

![7](https://github.com/user-attachments/assets/95e520f5-8e3e-4a41-9ed2-4ba6e6f32ab4)

The query execution time was **0.16 seconds**. To gain more insight on this query, run the `EXPLAIN` statement.

```sql
EXPLAIN SELECT * FROM employees WHERE hire_date >= '2000-01-01';
```

![8](https://github.com/user-attachments/assets/029d49c6-88a3-447c-9bef-c901768ba79a)

The number of rows scanned are 299290 while the number of rows fetched are only 13.
To optimize it, an index on the `hire_date` column is created:

```sql
CREATE INDEX hire_date_index ON employees(hire_date);
```

Re-running the query with `EXPLAIN` shows the improvement then re-running the query to notice time improved to **0.0 seconds**.

![10](https://github.com/user-attachments/assets/81c9f471-7aa0-400d-b024-9a70593aed66)

### 5. Data Encryption

As the salary of every individual is private. The encryption of the salary column is a must and only users with the key can view it.
The `salary` column is first converted to a `VARBINARY` type, and then encrypted using AES with a SHA2 hashed key:

```sql
SET @key = SHA2('password', 512);
ALTER TABLE salaries MODIFY COLUMN salary VARBINARY(255);
UPDATE salaries SET salary = AES_ENCRYPT(salary, @key);
SELECT CAST(AES_DECRYPT(salary, @key) AS CHAR(255)) FROM salaries LIMIT 5;
```

![16](https://github.com/user-attachments/assets/8237ab7d-2400-4a1a-b914-4b7aca884ba0)

### 6. Role and User Management

In MySQL, **roles** are a powerful way to manage user permissions. In this step, a role is created for HR personnel, granting them access to specific operations in the `employees` database.

1. **Create a Role**: 
   A role called `hr` is created to group together specific privileges for HR users.

   ```sql
   CREATE ROLE 'hr';
   ```

2. **Grant Privileges to the Role**: 
   The `hr` role is given permissions to perform `SELECT`, `INSERT`, `UPDATE`, and `DELETE` operations on all tables in the `employees` database.

   ```sql
   GRANT SELECT, INSERT, UPDATE, DELETE ON employees.* TO 'hr';
   ```

3. **Create a User**: 
   A user, `hruser`, is created with a password and associated with the host (`localhost`).

   ```sql
   CREATE USER 'hruser'@'localhost' IDENTIFIED BY '1234';
   ```

4. **Assign the Role to the User**: 
   The `hr` role is granted to the `hruser`, so they inherit the permissions associated with the role.

   ```sql
   GRANT 'hr' TO 'hruser'@'localhost';
   ```

5. **Set Default Role**: 
   The default role for `hruser` is set to `hr`. This ensures that whenever the user logs in, they automatically have the `hr` role activated.

   ```sql
   SET DEFAULT ROLE 'hr' TO 'hruser'@'localhost';
   ```

By using roles, we simplify the management of user privileges and ensure a cleaner, more secure database environment.

### 7. Automated Backups and Point-in-Time Recovery

A [shell script](https://github.com/user-attachments/files/18016385/backupV2.zip) is created to automate the process of creating a full backup of all databases every week. The script includes creating full backup, compression and deleting a month old backup files.

In this line, the system sometimes prompts sudo password during execution. To prevent that, the visudo file is modified.

```bash
if sudo mysqldump --flush-logs --delete-master-logs --all-databases > $sqlfile
```

First open the visudo file.

```bash
sudo visudo
```

Add this line. (Replace the `user_name` with your name on linux)

```bash
user_name ALL=(ALL) NOPASSWD: /usr/bin/mysqldump
```

### 8. Automating the Backup Process with Cron Jobs

To schedule the backup process every week, a cron job is created. (Replace the `user_name` with your name on linux)

```bash
0 0 * * 7 /home/user_name/Desktop/project/backup_script.sh > /home/user_name/Desktop/project/backup.log
```

## Conclusion

This project demonstrates various essential database administration tasks, such as query optimization, data encryption, role-based access control, and automated backup management, all aimed at improving database security, performance, and reliability.
