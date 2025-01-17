
### 1. **Log in to AWS Console**
   - Navigate to the AWS [RDS Console](https://console.aws.amazon.com/rds).

### 2. **Create Database**
   - In the left-hand menu, click **Databases**.
   - Click **Create database**.

### 3. **Choose Database Creation Method**
   - Under **Database creation method**, select **Standard create**.

### 4. **Choose Database Engine**
   - Under **Engine options**, choose **PostgreSQL** as the database engine.
   - Version: Select **14.6-R1**.

### 5. **DB Instance Class**
   - Scroll down to the **DB instance class** section.
   - Under **Instance size**, choose **Free tier**.

### 6. **Set Up Database Instance**
   - DB instance identifier: Enter `izaan-pipeline-1`.
   - Master username: Enter `pipeline_service`.
   - Credentials management: Select **Self managed**.
   - Master password: Enter `k_39MBm6-vnK`, and confirm the password.

### 7. **Instance Configuration**
   - Under **Instance configuration**, select **db.t3.micro** as the instance class.

### 8. **Configure Storage**
   - Storage type: Select **SSD (gp2)**.
   - Allocated storage: Set to **200 GB**.
   - Enable **Storage autoscaling** and set the maximum limit to **240 GB**.

### 9. **Configure Connectivity**
   - For **Connectivity**:
     - **Don't connect** to an EC2 compute resource.
     - **VPC**: Choose the **Default VPC (vpc-53062129)**.
     - **Subnet group**: Select **default-vpc-53062129**.
     - **Public access**: Choose **Yes** to allow public access.
     - **VPC security group**: Use the default security group and also select **DBAExternal** (`sg-0bae7d386b18144f5`).
     - **Availability Zone**: Select **us-east-1a**.
   - Under **Additional configuration**, set the database port to **5999**.

### 10. **Database Authentication**
   - Choose **Password authentication**.

### 11. **Monitoring**
   - Uncheck **Turn on Performance Insights**.

### 12. **Additional Configuration**
   - In **Additional configuration**:
     - Initial database name: Enter `tolling`.

### 13. **Backup Configurations**
   - Uncheck **Enable automated backups**.
   - (Optional) If needed, enable backups and set the retention period to **7 days**.

### 14. **Additional Configurations**
   - **Parameter group**: Choose **default.postgres14**.
   - Leave **Encryption**, **CloudWatch logs**, and **Auto minor version upgrade** as **Disabled**.

### 15. **Create Database**
   - Review all the settings and click **Create database**.
After the database is created, the connection endpoint will be:  
`izaan-pipeline-1.cen58y5cse53.us-east-1.rds.amazonaws.com` on port **5999**.

### 15. Steps to Allow Port in the Security Group for AWS RDS:

- **Navigate to RDS**
   - In the console, find and click on **RDS** under the "Databases" section.

- **Select Your DB Instance**
   - In the RDS dashboard, click on **Databases** in the left sidebar.
   - Find your PostgreSQL RDS instance in the list and click on its name to view its details.

- **Locate the Security Group**
   - In the **Connectivity & security** tab of your RDS instance details, scroll down to the **VPC security groups** section.
   - Click on the security group link (it will look something like `sg-xxxxxxxx`).

- **Edit Inbound Rules**
   - In the **Security Groups** page, click on the **Inbound rules** tab.
   - Click on the **Edit inbound rules** button.

- **Add a Rule to Allow PostgreSQL Port**
   - Click on **Add rule**.
   - For **Type**, select **PostgreSQL** from the dropdown (this automatically sets the port to `5432`) or select **Custom TCP** and manually enter `5999` (or whatever port you are using).
   - For **Source**, choose **My IP** to restrict access to your current IP address or **Anywhere** (0.0.0.0/0) if you want to allow access from any IP (not recommended for production environments).
   - **Description** (optional): Add a description, e.g., `Allow pgAdmin access`.


- **Save Rules**
   - Click on **Save rules** to apply the changes.

- **Confirm Changes**
   - Go back to your RDS instance and confirm that the inbound rules are updated. 

--- 



### **Install PgAdmin and Verify Connection**
   - Now, return to **pgAdmin** and try connecting to your PostgreSQL RDS instance again using the steps previously provided.
#102 

---

### 2. **Set up Database Schema and Users**

Once your database instance is ready, you can access it via **pgAdmin** or another PostgreSQL client. Here’s how to apply the SQL commands you provided:

1. **Connect to PostgreSQL Instance via pgAdmin:**
   - Use the following connection details:
     - Hostname: `izaan-pipeline-1.cen58y5cse53.us-east-1.rds.amazonaws.com`
     - Port: **5999**
     - Username: `pipeline_service`
     - Password: `k_39MBm6-vnK`
     - Database: `tolling`

2. **Execute the SQL Script:**

   Once connected, open a query window and run the following commands:

   ```sql
   -- Create service account for the pipeline
   CREATE USER pipeline_service WITH LOGIN PASSWORD 'k_39MBm6-vnK';

   -- Create db account to own all objects
   CREATE USER izaan_owner WITH NOLOGIN;

   -- Create privilege roles
   CREATE ROLE iz_read_only WITH NOLOGIN;
   CREATE ROLE iz_dml WITH NOLOGIN;

   -- Grant izaan_admin permission to create objects on behalf of izaan_owner
   GRANT izaan_owner TO pipeline_service;

-- Grant public schema permission to pipeline_service user
SELECT * FROM information_schema.role_table_grants WHERE table_schema = 'public' AND grantee = 'pipeline_service';
GRANT CREATE ON SCHEMA public TO pipeline_service;

   -- Create schema
   CREATE SCHEMA izaan AUTHORIZATION izaan_owner;

   -- Grant schema usage to pipeline_service
   GRANT USAGE ON SCHEMA izaan TO pipeline_service;

   -- Switch to izaan_owner role to create the table
   SET ROLE izaan_owner;

```
   -- Create table
   CREATE TABLE izaan.toll_booth_camera_log (
    log_id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    payload JSONB,
    identification_profile JSONB,
    message_uuid UUID,
    source_date TIMESTAMP WITH TIME ZONE,
    sid UUID,
    import_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    eventNumber VARCHAR(255),
    tollboothid VARCHAR(255),
    videoTolling VARCHAR(255),
    roadway VARCHAR(255),
    licensePlateNo VARCHAR(255),          -- New column for license plate number
    original_request_txt TEXT              -- New column for original request text
     );

```
  ```
 -- Grant privileges
   GRANT SELECT ON izaan.toll_booth_camera_log TO iz_read_only;
   GRANT INSERT, UPDATE, DELETE ON izaan.toll_booth_camera_log TO iz_dml;

   -- Reset role back to izaan_admin
   RESET ROLE;

   -- Grant read/write privileges to pipeline_service
   GRANT iz_read_only TO pipeline_service;
   GRANT iz_dml TO pipeline_service;

   -- Install UUID extension
   CREATE EXTENSION "uuid-ossp";
   ```
```

### 3. **Testing the Insert Query**

Now you can run the following test insert query as the `pipeline_service` user:

```sql
-- Connect to the DB as the pipeline_service account
BEGIN;

-- Test insert without JSON data
INSERT INTO izaan.toll_booth_camera_log (message_uuid, source_date, sid)
SELECT uuid_generate_v4(), now(), uuid_generate_v4()
RETURNING *;

COMMIT;
```

### 4. **Create Trigger for Payload Processing**

Run the following SQL code to create the trigger function:

```sql
CREATE OR REPLACE FUNCTION izaan.tf_update_camera_log_before_insert()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    NEW.payload = (convert_from(DECODE(NEW.original_request_txt, 'base64'), 'UTF8'))::JSONB;

    -- identification_profile 
    NEW.identification_profile = NEW.payload->'identificationProfile';

    -- message_uuid
    NEW.message_uuid = NEW.payload->'messageHeader'->>'messageUUID';

    -- source_date
    NEW.source_date = (NEW.payload->'messageHeader'->>'sourceSystemEventDateTime')::TIMESTAMP WITH TIME ZONE;

    -- sid 
    NEW.sid = NEW.payload->'systemIdentificationProfile'->>'UUID';
    
    -- Extract tollBoothID
    NEW.tollboothid = (NEW.payload->'identificationProfile'->'zoneSpecification'->0->>'tollBoothID')::TEXT;
    
    -- videoTolling
    NEW.videoTolling = (NEW.payload->'identificationProfile'->'zoneSpecification'->0->>'videoTolling')::BOOL;

    -- roadway
    NEW.roadway = (NEW.payload->'identificationProfile'->'zoneSpecification'->0->>'roadway')::TEXT;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Problem handling toll booth data: (%) %', SQLSTATE, SQLERRM;
END;
$BODY$;

ALTER FUNCTION izaan.tf_update_camera_log_before_insert() OWNER TO pipeline_service;

CREATE TRIGGER before_insert_camera_log
BEFORE INSERT ON izaan.toll_booth_camera_log
FOR EACH ROW
EXECUTE FUNCTION izaan.tf_update_camera_log_before_insert();


```

