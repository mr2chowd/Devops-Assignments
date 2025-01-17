To connect to your newly created PostgreSQL database on AWS RDS using **pgAdmin**, follow these steps:

### Prerequisites:
- pgAdmin installed on your local machine. If not, you can download it from [pgAdmin's official site](https://www.pgadmin.org/download/).
- Ensure your local machine can connect to the database by configuring the security group to allow inbound traffic from your IP.

### Steps to Connect:



### 1. **Launch pgAdmin**
   - Open **pgAdmin** on your computer.

### 2. **Add New Server**
   - In the pgAdmin dashboard, right-click on **Servers** in the left navigation pane and select **Create** > **Server**.


### 3. **General Tab: Name the Server**
   - In the **General** tab, provide a name for your connection, e.g., `Izaan PostgreSQL`.

### 4. **Connection Tab: Database Connection Details**
   - Go to the **Connection** tab and fill in the following details:
     - **Host name/address**: Enter the RDS endpoint, e.g., `izaan-pipeline-1.cen58y5cse53.us-east-1.rds.amazonaws.com`.
     - **Port**: Enter `5999`.
     - **Username**: Enter the master username, e.g., `izaan_admin`.
     - **Password**: Enter the password you used, e.g., `Texas!75023`.
     - **Database**: Optionally, enter the database name you created (`tolling`). If you leave this blank, it will connect to the default database.

   - Click the **Save password** option if you prefer not to enter the password each time.

### 5. **SSL Tab (Optional)**
   - AWS RDS provides SSL connections by default. If you wish to use SSL, navigate to the **SSL** tab and set the following:
     - **SSL mode**: Select `Require`.

   *(You can leave this step for now unless you specifically need SSL connections.)*

### 6. **Test the Connection**
   - Click **Save**.
   - If all details are correct, pgAdmin will connect to your PostgreSQL RDS instance, and you will see the new server in the left-hand panel.

### 7. **Expand the Server**
   - Expand the server by clicking on it to see databases, schemas, tables, etc., associated with your RDS instance.


![Image](https://github.com/user-attachments/assets/bdab57bb-bc79-400b-a6e3-9201dfefd65b)

![Image](https://github.com/user-attachments/assets/bc14e606-ad7b-40f4-8006-9dd7eda28071)
