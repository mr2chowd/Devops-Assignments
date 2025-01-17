
# **Lab: Migrate Data from Amazon S3 to RDS PostgreSQL using AWS DMS**

### **Objective**:
In this lab, you will set up AWS Database Migration Service (DMS) to migrate data from an Amazon S3 bucket to a PostgreSQL database hosted on Amazon RDS.

---

### **Lab Requirements**:
1. **AWS Account** with administrative access.
2. **PostgreSQL RDS Instance** (running and accessible).
3. **Amazon S3 Bucket** (with data in CSV, JSON, or Parquet format).
4. **IAM Role** with sufficient permissions for DMS to access S3 and PostgreSQL.

---
 
### **Step 1: Create an IAM Role for DMS**

#### Instructions:

1. **Navigate to the AWS IAM Console**.
   - Open the AWS Management Console and search for **IAM**.

2. **Create a New Role**:
   - In the left-hand navigation pane, click on **Roles**.
   - Click **Create Role**.
   - Choose **AWS Service** and select **DMS** as the trusted entity.
   - Click **Next**.

3. **Attach an Inline Policy with Specific S3 Access**:
   - Attach the following inline policy to grant read access only to a specific S3 bucket (modify the bucket ARN as needed):
  ```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::my-s3-bucket",
                "arn:aws:s3:::my-s3-bucket/*"
            ]
        }
    ]
}   

```

4. **Review and Create the Role**:
   - Name the role, for example, `DMS-S3AccessRole`.
   - Review your configuration, and click **Create role**.

#### Checkpoint:
- Ensure that your role is listed under **IAM Roles** and has the correct permissions (limited to read access for the specified S3 bucket).
 
---
Your instructions for creating a DMS Replication Instance look excellent! Here's a slightly refined version for clarity and flow, incorporating the feedback and focusing on key actions:

---

### **Step 2: Create a DMS Replication Instance**

#### Instructions:

1. **Navigate to AWS DMS Console**:
   - Open the [AWS DMS Console](https://console.aws.amazon.com/dms).

2. **Create Replication Instance**:
   - On the left-hand panel, click on **Replication Instances**.
   - Click the **Create Replication Instance** button.

3. **Configure Replication Instance**:

   - **Name**: Enter a name for the instance, for example, `dms-replication-instance`.
   - **Instance Class**: Choose the instance size based on your workload. For development purposes, `dms.t3.medium` is a cost-effective option.
   - **VPC**: Select the same **VPC** where your PostgreSQL RDS instance is located.
   - **High Availability**: If this is a `dev/test environment`, choose **Single-AZ** for non-high availability.

4. **Storage Configuration**:
   - **Allocated Storage**: Set the storage to `50 GB`. Adjust the size if you anticipate higher storage needs based on your data.

5. **Connectivity and Security**:
   - **IPv4 VPC**: Select the **VPC** where your RDS instance is running (e.g., `vpc-53062129`).
   - **Replication Subnet Group**: From the dropdown, select the appropriate **subnet group** that has connectivity to your RDS instance.
   - **Public Access**: Choose **Yes** for **Publicly Accessible** if you want to access the instance from outside your VPC. For production environments, consider setting this to **No**.

6. **Review Additional Settings**:
   - For most use cases, you can leave the remaining settings as their default values. If you have specific security or performance requirements, adjust these accordingly.

7. **Create the Replication Instance**:
   - After reviewing your settings, click **Create**. It may take a few minutes for the instance to launch and become available.

#### Checkpoint:
- Confirm that the **Status** of the replication instance shows as **Available** in the AWS DMS Console under **Replication Instances**.

---

### **Step 3: Create the Source Endpoint (S3)**

**Prerequisite**:  
Create a folder in your S3 bucket (`my-s3-bucket`): **`changedata`**.

#### Instructions:

1. **Navigate to DMS Endpoints**:
   - On the left-hand side of the DMS Console, click on **Endpoints**.

2. **Create Source Endpoint**:
   - Click the **Create Endpoint** button.
   - **Endpoint Type**: Select **Source**.
   - **Endpoint Identifier**: Enter `datapipeline-s3-source-endpoint`.
   - **Source Engine**: Choose **Amazon S3**.

3. **Endpoint Configuration**:
   - **Amazon Resource Name (ARN) for service access role**: Select the IAM role ARN created earlier (e.g., `arn:aws:iam::666680140343:role/DMS-S3AccessRole`).
   - **Bucket Name**: Input your S3 bucket name (e.g., `my-s3-bucket`).
   - **Table Structure**:
     ```json
     {
       "TableCount": "1",
       "Tables": [
         {
           "TableName": "toll_booth_camera_log",
           "TablePath": "izaan/toll_booth_camera_log/",
           "TableOwner": "izaan",
           "TableColumns": [
             {
               "ColumnName": "time_stamp_received",
               "ColumnType": "STRING"
             },
             {
               "ColumnName": "original_request_txt",
               "ColumnType": "STRING",
               "ColumnNullable": "false",
               "ColumnLength": "6000"
             }
           ],
           "TableColumnsTotal": "2"
         }
       ]
     }
     ```
   - **Bucket Folder**: Specify **`changedata/`** for the CDC path.

4. **Endpoint Settings**:
   - **Use Endpoint Connection Attributes**:  
     - **Extra Connection Attributes**: 
       ```
       compressionType=NONE;csvDelimiter=,;csvRowDelimiter=\n;
       ```
 
**Leave all other settings at their defaults.**

5. **Test Endpoint Connection (optional)**:
   - **VPC**: Choose **Default VPC**.
   - **Replication Instance**: Select your replication instance from the dropdown.
   - Click **Run test** and wait for the test to complete successfully.


6. **Create Endpoint**:
   - Click the **Create endpoint** button to finalize the setup.

#### Checkpoint:
- Verify that the newly created **Source Endpoint** appears in the **Endpoints** list.

---

### **Step 4: Create the Target Endpoint (PostgreSQL)**

#### Instructions:

1. **Create Target Endpoint**:
   - Navigate to **Endpoints** and click **Create Endpoint**.
   - **Endpoint Type**: Select **Target**.
   - **Endpoint Identifier**: Enter `postgres-target-endpoint`.
   - **Target Engine**: Choose **PostgreSQL**.

2. **Configure PostgreSQL Connection**:
   - **Access to Endpoint Database**: Select **Provide access information manually**.
   - **Server Name**: Enter your RDS PostgreSQL endpoint (e.g., `my-postgres-db.xxxxxxxxx.us-east-1.rds.amazonaws.com`).
   - **Port**: Enter the port number (e.g., `5999`).
   - **Username/Password**: Input the credentials for your RDS PostgreSQL instance
   - Select SSL mode: Require
(e.g., Username: `pipeline_service`, Password: `k_39MBm6-vnK`).
   - **Database Name**: Specify the target database name (e.g., `tolling`).

3. **Test Endpoint Connection (optional)**:
   - **VPC**: Choose **Default VPC**.
   - **Replication Instance**: Select your replication instance from the dropdown.
   - Click **Run test** and wait for the test to complete successfully.

4. **Create Endpoint**:
   - Once all configurations are set, click the **Create endpoint** button.

#### Checkpoint:
- Verify that the newly created target endpoint appears in the list of **Endpoints**.

---
 
### **Step 5: Create a DMS Migration Task**

#### Instructions:

1. **Create Migration Task**:
   - In the DMS console, navigate to **Tasks** and click **Create Task**.

2. **Configure Task Settings**:
   - **Task Identifier**: Enter a name for your task, e.g., `s3-to-postgres-task`.
   - **Replication Instance**: Select the previously created replication instance (`dms-replication-instance`).
   - **Source Endpoint**: Choose the S3 source endpoint (`datapipeline-s3-source-endpoint`).
   - **Target Endpoint**: Select the PostgreSQL target endpoint (`postgres-target-endpoint`).
   - **Migration Type**: Choose **Migrate existing data and replicate ongoing changes**.

3. **Task Settings**:
   - Configure the following settings:
     - **Editing Mode**: Set to **Wizard**.
     - **Target Table Preparation Mode**: Select **Do nothing**.
     - **Stop Task After Full Load Completes**: Choose **Don't stop** (adjust if necessary).
     - **LOB Column Settings**: Select **Limited LOB mode** (adjust if necessary).
     - **Maximum LOB Size (KB)**: Set to `10000` (if your data contains large objects).
     - **Data Validation**: Set to **Off**.
     - **Task Logs**: Set to **Yes** (optional).
     - **Log Context**: Enable **Log context**.
   - Leave the rest of the settings at their default values.

4. **Table Mapping**:
   - In the **Table Mapping** section, specify how S3 data maps to tables in PostgreSQL:
     - **Editing Mode**: Set to **Wizard**.
     - **Add New Selection Rule**:
       - **Schema**: Enter the target schema.
       - **Source Name**: Enter `%`.
       - **Source Table Name**: Enter `%`.
       - **Action**: Select **Include**.

5. **Uncheck**: Disable the option for **Turn on pre-migration assessment**.

6. **Migration Task Startup Configuration**:
   - Set to **Manually later**.

7. **Start Task**:
   - After configuring all settings, click **Create task** and then **Start task**.

#### Checkpoint:
- The migration task should begin, and you can monitor its status from the DMS console.


---


### **Step 6: Monitor and Verify the Migration**

#### Instructions:

1. **Monitor Task Progress**:
   - In the DMS console, go to **Tasks**.
   - Monitor the task status. It will go through the stages: **Starting**, **Running**, and eventually **Completed** when the data migration is finished.

2. **Upload CSV to S3**:
   - Upload your `.csv` file to the **`changedata`** folder in your S3 bucket (e.g., `my-s3-bucket/changedata/your-file.csv`).
   - Example CSV file link:  [Format](https://github.com/IzaanSchool/B2401_CloudComputing_DevOps_Resources/blob/master/DataPipeline/CDC6381364614788536699.CSV).

3. **Verify Data in PostgreSQL**:
   - Once the migration task completes, use **pgAdmin** or another SQL client to log in to your RDS PostgreSQL instance.
   - Run SQL queries on the target database (e.g., `tolling`) to confirm that the data from the CSV file in the S3 bucket has been migrated to the corresponding table (`toll_booth_camera_log`) in PostgreSQL.

4. **SQL Query Example**:
   ```sql
   SELECT * FROM izaan.toll_booth_camera_log;
   ```
5. **Check Data Statistics**:
You can check how much data was inserted by going to the Table Statistics section under the Task Details tab of your migration task.

#### Checkpoint:
- Verify that the migrated data matches the source data in the S3 bucket, ensuring that all records from the CSV file have been inserted correctly into the PostgreSQL table.


### **Post-Lab Clean-Up (Optional)**

1. **Stop or Delete Replication Instance**:
   - Navigate to **Replication Instances** in DMS, and stop or delete the replication instance to avoid charges.
   
2. **Remove Endpoints and IAM Role**:
   - If no longer needed, remove the S3 and PostgreSQL endpoints and the IAM role used in this lab.

---

### **Lab Completed**

You have successfully set up AWS DMS to migrate data from an Amazon S3 bucket to a PostgreSQL database on RDS. Make sure to check the migration result and clean up resources to avoid unnecessary costs.
