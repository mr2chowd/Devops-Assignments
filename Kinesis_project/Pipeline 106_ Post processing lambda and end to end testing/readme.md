 ### 1: Add Post Processing Lambda
 ---

### Step 1: Post Processing Lambda and Add S3 Event Notification 

To create the `post_processing_datapipeline_lambda` function in AWS Lambda and integrate it with the S3 event notification system, follow the expanded steps below:

### Step 1: Create the Lambda Function

1. **Go to AWS Lambda Console**:
   - Open the [AWS Lambda Console](https://console.aws.amazon.com/lambda/home).
   
2. **Create a New Lambda Function**:
   - Click **Create function**.
   - Choose **Author from scratch**.
     - **Function name**: Enter `post_processing_datapipeline_lambda`.
     - **Runtime**: Select **Python 3.9**.
     - **Permissions**: Choose an existing role or create a new role with basic Lambda permissions. 
   - Click **Create function**.

3. **Set Up Execution Role (if necessary)**:
   - Make sure the Lambda execution role has the following AWS permissions:
     - **S3**: Access to read and copy objects between S3 buckets.
     - **CloudWatch Logs**: To log Lambda execution for debugging and monitoring.
   - Example IAM policy:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "logs:CreateLogGroup",
             "logs:CreateLogStream",
             "logs:PutLogEvents"
           ],
           "Resource": "*"
         },
         {
           "Effect": "Allow",
           "Action": [
             "s3:GetObject",
             "s3:PutObject",
             "s3:DeleteObject"
           ],
           "Resource": [
             "arn:aws:s3:::your-source-bucket-name/*",
             "arn:aws:s3:::your-source-bucket-name/*"
           ]
         }
       ]
     }
     ```
-  For testing purposes attach policies if needed: `AWSLambdaBasicExecutionRole,AmazonS3FullAccess,AWSLambda_FullAccess`)


### Step 2: Add the Lambda Function Code

1. **Open Lambda Code Editor**:
   - After the Lambda function is created, scroll down to the **Code** section.

2. **Update the Lambda Function Code**:
   - Copy and paste the following code:

   ```python
   import boto3
   import logging
   import time

   # Initialize logging
   logger = logging.getLogger()
   logger.setLevel(logging.INFO)

   def lambda_handler(event, context):
       # Initialize S3 client
       s3 = boto3.client('s3')

       try:
           # Log the incoming event for troubleshooting
           logger.info(f"Received event: {event}")

           # Get the bucket name and the object key from the event
           source_bucket = event['Records'][0]['s3']['bucket']['name']
           source_key = event['Records'][0]['s3']['object']['key']

           # Define the destination key using the current epoch time
           current_epoch_time = int(time.time())
           dest_key = f"changedata/CDC{current_epoch_time}.csv"

           # Define the destination bucket
           dest_bucket = 'your-source-bucket-name'

           # Copy the S3 object to the new location in the destination bucket
           s3.copy_object(
               Bucket=dest_bucket, 
               CopySource={'Bucket': source_bucket, 'Key': source_key}, 
               Key=dest_key
           )

           # Optionally, delete the original object (uncomment if required)
           # s3.delete_object(Bucket=source_bucket, Key=source_key)

           logger.info(f"Copied object from {source_key} to {dest_key} in bucket {dest_bucket}")

           # Return success response
           return {
               'statusCode': 200,
               'body': f"Successfully copied {source_key} to {dest_key} in bucket {dest_bucket}"
           }
       
       except Exception as e:
           # Log the error message
           logger.error(f"Error occurred: {e}")

           # Return error response
           return {
               'statusCode': 500,
               'body': f"Failed to copy object. Error: {e}"
           }
   ```

3. **Deploy the Lambda Function**:
   - Once you’ve updated the code, click **Deploy** to save and deploy the changes.

### Step 3: Add S3 Trigger for Lambda

1. **Open AWS S3 Console**:
   - Go to the [AWS S3 Console](https://console.aws.amazon.com/s3/home).

2. **Go to the Source Bucket**:
   - Select the bucket where your S3 event will be triggered (the source bucket where files will be uploaded).

3. **Configure S3 Event Notification**:
   - Navigate to **Properties** and scroll down to **Event notifications**.
   - Click **Create event notification**.
     - **Event Name**: Enter `post_processing_event`.
     - **Prefix**: Set the prefix to `2024/` (this means the Lambda function will trigger for any file added under the `2024/` folder).
     - **Event Types**: Select both `PUT` and `POST`.
     - **Destination**: Choose **Lambda Function** and select `post_processing_datapipeline_lambda`.
   - Click **Save** to enable the event notification.

--- 
 

### 2: Testing the Datapipeline Workflow


### Objective:
This lab provides a step-by-step guide to test an end-to-end data pipeline using an API Gateway, Kinesis Firehose, AWS Lambda, S3, and a Postgres database. You will monitor logs, check file structures, and ensure data flows correctly through the pipeline.

---

### **Step 1: Send a POST Request to the API**

**Objective**: Send a POST request to trigger the pipeline.

1. **Postman/Curl**:
   - Use Postman or `curl` to send a POST request to the API Gateway.
   - **API Endpoint**: Use the API Gateway endpoint URL (e.g., `https://your-api-id.execute-api.region.amazonaws.com/prod/endpoint`).
   - **Request Body**: Send a JSON payload.

```
{
        "identificationProfile": {
            "jobID": "201709-I-2vbbce59ejamme9h70z87ma851",
            "zoneSpecification": [
                {
                    "tollBoothID": "310990851",
                    "roadway": "I-555",
                    "videoTolling": true
                }
            ],
            "eventNumber": "107",
            "eventDateTime": "{{current_timestamp}}",
            "licensePlateNo": "9BT3467"
        },
        "messageHeader":{
            "messageUUID": "{{messageUUID}}",
            "sourceSystemEventDateTime": "2024-10-09T01:05:31.966Z"
        },
        "systemIdentificationProfile": {
            "UUID": "d8a2b0a5-f225-390b-9ccf-794d61eaa72b"
        }
}
```
![Image](https://github.com/user-attachments/assets/93d1534d-5e63-405b-9bad-4107e3f37e03)



2. **Log Check**:
   - After sending the request, verify the CloudWatch logs for the API Gateway to ensure the request was received.
   - Go to **CloudWatch Console** > **Log Groups**.
   - Open the log group for your API Gateway (e.g., `API-Gateway-Execution-Logs_{rest-api-id}/{stage-name}`) and check the log stream.
   
   > **Note**: If the logs are not showing as expected, there may be errors in the request or API setup. Check the logs for any error messages.

---

### **Step 2: Verify the Kinesis Data Firehose Stream**

**Objective**: Inspect Kinesis Firehose metrics and verify that the POST data is being streamed to Firehose.

1. **Go to Firehose Console**:
   - Navigate to the [Kinesis Data Firehose Console](https://console.aws.amazon.com/firehose/home).

2. **Check Firehose Metrics**:
   - In the Firehose stream linked to the API, go to the **Monitoring** tab.
   - Check metrics such as `IncomingBytes`, `IncomingRecords`, and `DeliveryToS3.Bytes`.

3. **Log Check**:
   - View CloudWatch logs for the Firehose stream, if logging is enabled, to verify that the request data was received.

   > **Note**: If no metrics or logs are found, check the configuration of the Firehose stream and verify that the API request data was properly sent.

---

### **Step 3: Inspect Lambda Triggered by Kinesis Firehose**

**Objective**: Inspect logs for the Lambda function that processes the Kinesis data.

1. **Go to CloudWatch Logs for Lambda**:
   - In the **CloudWatch Console** > **Log Groups**, search for the log group associated with the Lambda function triggered by the Kinesis Firehose (e.g., `Lambda-Kinesis-Handler`).
   - Inspect the logs to ensure the Lambda function was triggered and processed the incoming Kinesis stream.

   > **Note**: If logs are missing or show errors, check the Lambda function's permissions and the Kinesis Firehose setup.

---

### **Step 4: Check the S3 Bucket for New Folder Creation**
![Image](https://github.com/user-attachments/assets/f604cc50-8df8-4570-96cd-b280c7a7f445)

**Objective**: Verify that a new folder (e.g., `2024/`) and an object have been created in the destination S3 bucket.

1. **Go to S3 Console**:
   - Navigate to the [S3 Console](https://console.aws.amazon.com/s3/).
   - Find the destination bucket (e.g., `your-destination-bucket`).

2. **Check Folder Structure**:
   - Verify that a new folder named `2024/` has been created.
   - Inspect the contents of the folder and verify that the object has been created.

3. **Download the File**:
   - Download the file and inspect the contents to ensure the correct data is stored.

   > **Note**: If the file or folder is missing, check the preceding steps (Kinesis Firehose and Lambda) for any issues.

---

### **Step 5: Inspect Logs for Post-Processing Lambda Trigger**

**Objective**: Verify that the post-processing Lambda is triggered when a new object is created in the `2024/` folder.

1. **Go to CloudWatch Logs for Post-Processing Lambda**:
   - In the **CloudWatch Console**, search for the log group associated with the post-processing Lambda function (e.g., `post_processing_datapipeline_lambda`).
   - Inspect the logs to ensure the Lambda function was triggered by the new object in S3.

   > **Note**: If the logs do not show the Lambda function being triggered, verify that the correct S3 event notification is set up on the bucket.

---

### **Step 6: Check the `changedata/` Folder for New CSV File**

![Image](https://github.com/user-attachments/assets/f968045e-234a-4a5e-99f2-b342fc0eeebe)


**Objective**: Verify that a new `.csv` object has been created in the `changedata/` folder in the S3 bucket.

1. **Go to S3 Console**:
   - In the S3 bucket, navigate to the `changedata/` folder.

2. **Verify CSV File**:
   - Ensure a new CSV file is created (e.g., `CDC{timestamp}.csv`).

3. **Download and Inspect CSV**:
   - Download the CSV file and check its format and content to ensure the data is correctly processed.

   > **Note**: If the CSV file is not present, check the logs for the post-processing Lambda function.

---

### **Step 7: Check Database Migration Logs**

**Objective**: Verify that the database migration task processed the data correctly.

1. **Open AWS DMS Console**:
   - Navigate to the [AWS DMS Console](https://console.aws.amazon.com/dms/home).

2. **View CloudWatch Logs**:
   - Select the database migration task and click on **View CloudWatch Logs** to check the latest logs.
   - Verify that the data from the S3 object was processed and inserted into the Postgres database.

   > **Note**: If the logs show errors or missing data, investigate the DMS task and ensure the correct S3 bucket and file are being used.

---

### **Step 8: Check Table Statistics in the Postgres Database**

![Image](https://github.com/user-attachments/assets/ad0c8358-e415-49e2-aada-481b7c80ac17)

**Objective**: Verify that the data was inserted into the Postgres database.

1. **Go to Database Migration Task**:
   - In the **AWS DMS Console**, select the migration task.

2. **Click on `Table statistics` Tab**:
   - Check the statistics to see how many rows were inserted into the Postgres database.

3. **Verify Schema**:
   - Open the database (using a SQL client such as pgAdmin or DBeaver) and inspect the schema to ensure the data was correctly inserted.

   > **Note**: If the data is not showing, verify the DMS task and S3 configuration for errors.

---

### **Step 9: Run SELECT Query on the Postgres Database**

**Objective**: Run a query to check the new data inserted into the Postgres database.

![Image](https://github.com/user-attachments/assets/92984b74-0f2f-4339-a7d3-da56c13041d3)


1. **Open SQL Client**:
   - Use a SQL client like **pgAdmin** or **DBeaver** to connect to the Postgres database.

2. **Run a SELECT Query**:
   - Execute a `SELECT` query on the relevant table to check if the new data has been inserted.
   
   Example query:
   ```sql
   SELECT * FROM your_table_name ORDER BY id DESC LIMIT 10;
   ```

3. **Verify Data**:
   - Ensure that the recently inserted data appears in the result set.

   > **Note**: If the data is not found, check previous steps (DMS, Lambda, S3) to identify where the failure occurred.

---

This lab walks through the entire data pipeline process, from API requests to database insertion. Each step includes monitoring logs, inspecting file structures, and validating database updates. If the expected output is not seen at any step, logs should be carefully checked to identify and fix potential errors.
