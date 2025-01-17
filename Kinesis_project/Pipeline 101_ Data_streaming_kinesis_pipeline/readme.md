### **Lesson Plan: Streaming Data and AWS Kinesis Services**

---

#### **1. Introduction to Streaming Data**
   - **Definition**: Streaming data refers to the continuous flow of real-time data generated from various sources like IoT devices, social media platforms, application logs, financial transactions, etc.
   - **Types of Streaming Data**:
     - **Real-time event data**: Transactional data, server logs, clickstreams, etc.
     - **Machine-generated data**: IoT sensors, industrial machinery, smart devices.
     - **Human-generated data**: Social media posts, online activities, user interactions.
   - **Why Streaming Data is Important**: Explaining the need for real-time data processing to gain immediate insights and make decisions in critical scenarios (e.g., financial services, real-time analytics, fraud detection).

---

#### **2. Use Cases of Streaming Data**
   - **Real-time analytics**: Example: Monitoring financial trades, fraud detection, etc.
   - **Log and event monitoring**: Continuous log ingestion for monitoring system performance.
   - **IoT Device Data**: Analyzing sensor data in real-time for smart devices.
   - **Clickstream Analysis**: Understanding user behavior on a website or application.
   - **Gaming Leaderboards**: Streaming data to update leaderboards and stats in real-time.
   
---

#### **3. When to Use Streaming Services like AWS Kinesis**
   - **Scenarios Requiring Real-Time Data Processing**:
     - When systems need immediate data processing and response.
     - Handling large volumes of continuously generated data in real-time.
     - Data lakes or analytics pipelines needing real-time data feeds.
   - **Comparison with Batch Processing**: Explain the difference between batch and streaming processing, and how the latter offers quicker insights.
   - **Key Advantages**: Scalability, real-time data capture, reliable data delivery.

---

#### **4. Overview of AWS Kinesis Services**
   
   - **AWS Kinesis Data Streams**:
     - **Purpose**: Capturing, processing, and storing streaming data.
     - **Core Features**: Real-time data ingestion, scalability, shard architecture for partitioning.
     - **Use Case**: Capturing clickstream data from websites, real-time analytics pipelines.
   
   - **AWS Kinesis Data Firehose**:
     - **Purpose**: Fully managed service for loading streaming data into AWS services like S3, Redshift, and Elasticsearch.
     - **Core Features**: Real-time transformation and data delivery, compression, encryption.
     - **Use Case**: Delivering logs, sensor data, and analytics results into S3 or Redshift for further processing.
   
   - **AWS Kinesis Analytics**:
     - **Purpose**: Real-time analytics on streaming data using standard SQL.
     - **Core Features**: Run SQL queries on data streams, detect anomalies, and monitor real-time trends.
     - **Use Case**: Analyzing data in real-time for use cases like anomaly detection and operational monitoring.
   
   - **AWS Kinesis Video Streams**:
     - **Purpose**: Streaming live video data from devices to AWS.
     - **Core Features**: Securely stream, store, and analyze live video.
     - **Use Case**: Video surveillance, video analysis, or any IoT-driven use case involving live video.
   
---

#### **5. How Kinesis Empowers AWS Engineers, Cloud Engineers, and DevOps Engineers**
   - **Real-Time Data Handling Skills**: Understanding streaming services enables these engineers to design scalable systems capable of handling real-time data for immediate business insights.
   - **Building and Managing Pipelines**: AWS Kinesis makes it easier to build complex data pipelines, ingest and transform data at scale, and deliver insights in real time.
   - **Efficient Log Monitoring**: AWS Kinesis Firehose is a great tool for managing and centralizing log data, which is essential for cloud engineers and DevOps teams to monitor the health of systems.
   - **Automation and Scalability**: Knowledge of services like Kinesis equips engineers with the ability to automate real-time data pipelines, making cloud infrastructure more scalable and resilient.
   - **Better Security and Compliance**: Engineers can use Kinesis to stream data in compliance with security policies by enabling encryption, data retention, and secure delivery.
   
---

#### **6. Advantages of AWS Kinesis Over Other Streaming Services**
   - **Integration with AWS Ecosystem**: Kinesis integrates seamlessly with AWS services like Lambda, S3, Redshift, and OpenSearch.
   - **Scalability**: Kinesis provides scalable, fully managed infrastructure for real-time streaming workloads.
   - **Cost-Effective**: Pay-as-you-go pricing model based on actual data throughput and delivery needs.

---

#### **7. Practical Exercises for Students**
   - **Building a Data Streaming Pipeline with Kinesis Data Streams**: Have students set up a basic pipeline that streams data into Kinesis and performs real-time analysis using Kinesis Analytics.
   - **Logging with Kinesis Data Firehose**: Create an exercise where students configure a Firehose delivery stream to load logs into an S3 bucket for real-time monitoring.
   - **Hands-on with Kinesis Video Streams**: An optional exercise for students to explore real-time video streaming with IoT or camera devices.

---

### **Summary**
Understanding streaming data and mastering AWS Kinesis services is crucial for any AWS, Cloud, or DevOps engineer who deals with real-time systems. Whether it’s monitoring logs, analyzing IoT data, or processing high-volume application events, Kinesis offers essential tools for handling such workloads effectively.

---
### **Project**
- Read this [read me](https://github.com/IzaanSchool/DataPipeline/blob/master/KinesisRecordTransformer/README.md) file for actual project we will deliver.

- Look into this [sam template](https://github.com/IzaanSchool/dataprocessing-sam-app/blob/feature/datapipeline/template.yaml) for automating the pipeline deployemnt
- ![Image](https://github.com/user-attachments/assets/fc9d3616-05f9-46bd-80da-cd2f35920d5a)

Please use below instruction to build your first streaming data pipeline -

# Key factors to consider
- Development 
- Automate the development process
  - CloudFormation, SAM, CDK, Terraform 
  - CI/CD Pipeline 
-  Deployment/Change Strategy **!!!!**
- End to end testing
- Understand Different  Critical component of the system
- Build run book to trouble shoot the problem
- Disaster recovery process. What is the DR Plan for your System
- Make RDS inaccessible by public network

![Image](https://github.com/user-attachments/assets/8e04e302-606e-46f3-9839-22e04f833dbf)



# Create Kinesis Stream

 - Create Kinesis Fire Hose
![image](https://github.com/user-attachments/assets/e093d30c-e34e-4378-b261-b9e00bf8758e)

# API Gateway

1. Build an API Gateway
2. Create API >> Rest API >> Build
3. 
![image](https://github.com/user-attachments/assets/f28ac2b1-d9df-4f3e-bc7a-da4df3fd7ce3)
4. Create Method
![image](https://github.com/user-attachments/assets/ffd64dcc-ce9b-4c04-b796-4b11678c6829)
5. Go to Method Integration Request >> Edit >> Mapping Templates
![image](https://github.com/user-attachments/assets/f471ff52-d7ef-4f93-a742-30227be01d51)
6. Edit Integration Response
![image](https://github.com/user-attachments/assets/916101a5-8d1f-437b-aa7f-0cde560c3856)




