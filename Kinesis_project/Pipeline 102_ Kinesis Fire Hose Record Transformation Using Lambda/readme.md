### Objective: In this lab, we’ll set up a data processing pipeline using AWS services, involving Route 53, Amazon Cognito, API Gateway, Kinesis Firehose, Lambda, and S3.

![image](https://github.com/user-attachments/assets/6a6e00c8-f58e-4d5d-b1f6-7fe6e4bc24c4)

### 1. Purchase Route53 Domain 
- Naviagate to Route53
- Check domain availability
- Follow the prompt to purchase domain
![Image](https://github.com/user-attachments/assets/459ef087-ce65-4f7c-845e-904368c1c9aa)
![Image](https://github.com/user-attachments/assets/381f4f80-981b-429a-b5b6-fa3534f7f214)

### 2. Create an AWS Certificate Manager
- Request a certificate
- Next
![Image](https://github.com/user-attachments/assets/7e2d786b-b8dc-4873-8b49-fec640774f55)
- Enter domain names in Fully qualified domain name
![Image](https://github.com/user-attachments/assets/2955e950-569c-4d25-8ab4-05a1241e20ee)
- Click Request

### 3. Create an S3 Bucket
- name: demo-kinesisfirehose-bucket
![image](https://github.com/user-attachments/assets/ac8fda13-3a18-43a8-aef9-bdc127624052)
![image](https://github.com/user-attachments/assets/64e52a97-615b-44b8-a5f6-ede572a02a26)

### 4. Create a lambda with the code below
- name: demo-kinesisfirehose-lambda
- select python 3.12
![image](https://github.com/user-attachments/assets/044cc085-dc6b-43ce-b3a9-d0b5da5778ce)
- Add the Code below and deploy
```
import base64
import json
import logging
import datetime

logging.getLogger().setLevel(logging.INFO)


def lambda_handler(event, context):
    logging.info("Event from Kinesis: {}".format(event))
    output_records = []
    utc_now = datetime.datetime.utcnow()
    utc_formatted_current_time = utc_now.strftime('%Y-%m-%d %H:%M:%S')

    for record in event['records']:
        base64_payload = record['data']
        csv_row = f'INSERT,weather_log,{utc_formatted_current_time},{base64_payload}\n'
        logging.info("CSV ROW: {}".format(csv_row))
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(csv_row.encode('utf-8')).decode('utf-8')
        }
        logging.info("Output Records: {}".format(output_record))
        output_records.append(output_record)

    return {'records': output_records}
```
![image](https://github.com/user-attachments/assets/87466a77-6863-4289-be52-072da3ec9399)

### 5. Create a Firehose Stream
- Select Source: Direct PUT
- Select Destination: Amaon S3
- enter Firehose stream name: PUT-S3-demo-kinesisfirehose
- Check Turn on data transformation
- Select AWS Lambda function and enter the lambda arn
- Version or alias: select $LATEST
- select the S3 bucket for the Destination settings
- Check New line delimiter: Enabled
- Expand Buffer hints, compression, file extension and encryption and update Buffer interval to 30sec (for quicker testing)
- Click Create Firehose stream

![image](https://github.com/user-attachments/assets/0d628b20-53a0-45ad-a65c-a5f6a8d08bc6)
![image](https://github.com/user-attachments/assets/9fee2135-9592-42a3-b8cd-a78c0ff59a0b)

### 6. Create an IAM Role for API Gateway
- Ensure API Gateway has Kinesis Firehouse and Kinesis full Access permission
![image](https://github.com/user-attachments/assets/dc8b317f-7dc9-4122-9548-1770e2d0f967)

### 7. Create API Gateway
- Build Rest API
- name: demo-kinesisfirehose-apigateway
![image](https://github.com/user-attachments/assets/534c6c1e-dcdc-4072-8e3e-0752671152c7)

### 8. Add Models in Api Gateway
- Click on Models
- Click Create Models
- Enter Name: weathermodel
- Content type: application/json
- Copy paste the model below
```
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "coord": {
      "type": "object",
      "properties": {
        "lon": {
          "type": "number"
        },
        "lat": {
          "type": "number"
        }
      },
      "required": [
        "lon",
        "lat"
      ]
    },
    "weather": {
      "type": "array",
      "items": [
        {
          "type": "object",
          "properties": {
            "id": {
              "type": "integer"
            },
            "main": {
              "type": "string"
            },
            "description": {
              "type": "string"
            },
            "icon": {
              "type": "string"
            }
          },
          "required": [
            "id",
            "main",
            "description",
            "icon"
          ]
        }
      ]
    }
  },
  "required": [
    "coord",
    "weather"
  ],
  "additionalProperties": false
}
```
![image](https://github.com/user-attachments/assets/087e0160-ce86-4991-97b3-2d076458fd35)

### 9. Create and configure Custom domain names
- Navigte to Api Gateway
- Click Custom domain names
- Click Create
- Add Domain name: yoursubdomainname.yourdomainname.com
- API endpoint type: Regional
- Select the ACM certificate
- Click Create domain name
- Navigate to the custom domain
- Click Configure API mappings
![image](https://github.com/user-attachments/assets/e406d292-49e9-4899-ac66-bffef64e3893)
- Click Add new mapping
- Select the API Gateway in API
- Select the Stage
- Click Save
![image](https://github.com/user-attachments/assets/b61d9838-9186-4e45-9c02-31a2bb8a9a63)

### 10. Connect Custom domain names with the Route 53
- Naviagte to Route53
- Click Create A Record
- Enter a record name: weatherapi
- Select Record Type: A – Routes traffic to an IPv4 address and some AWS resources
- Turn on Alias
- Route traffic to: Alias to API Gateway API
- Select the AZ(the zone your apigateway lives)
- Enter the API Gateway domain name on the Custom domain names
- Click Create records
![image](https://github.com/user-attachments/assets/242ac3bf-9799-4ec7-ae66-f7fa80cf1acf)
![image](https://github.com/user-attachments/assets/0855c08a-d49c-4c28-b4b9-aa738a16c39f)

### 11. Configure the POST method in API Gateway
- Create a resource name: weather
![image](https://github.com/user-attachments/assets/184e4fcb-dbb8-4de2-92ec-72709383fe6a)
- While selecting the resource Click on Create Method
- Select Method Type: POST
- Select AWS Service
- Select AWS Region: us-east-1
- Select AWS service: Firehose
- Select HTTP method: POST
- Enter Action name: PutRecord
- Enter Execution role: the ARN of Apigateway role
- Configure Method request settings: Request validator: Validate body
- Configure Request body: Content type: application/json and Model: weathermodel
- Click Create Method
![image](https://github.com/user-attachments/assets/6cdd96ae-a54b-4cc3-8341-7923a25b875d)
![image](https://github.com/user-attachments/assets/a177a1c6-8397-4e74-a1a8-2c4bed1c12c0)

### 12. Configure Integration request
- Click Edit 
- Click Mapping templates
- Enter Content type: application/json
- Enter json below
```
{
"DeliveryStreamName": "your-stream-name",
 "Record": { "Data": "$util.base64Encode($input.json('$'))" }
}
```
- Save
![Image](https://github.com/user-attachments/assets/c2b6c01b-b38d-4c8e-9c04-d27d15e6bd51)

### 13. Configure Integration response
- Click Edit
- Click Mapping templates
- Enter Content type: application/json
- Enter json below
```
{"status":"Ok"}
```
- Click Save
![Image](https://github.com/user-attachments/assets/74fc1897-6a71-49ca-ba42-ee9491829386)

### 14. Add Cognito
- Select Email
![image](https://github.com/user-attachments/assets/e5a22365-dceb-40a9-99b6-cf89c5bd1abe)
-Select Custom and No MFA
![image](https://github.com/user-attachments/assets/a87e048c-3955-47fd-894e-9e1d3c7cfaea)
- Keep default
![image](https://github.com/user-attachments/assets/1fa9267e-6713-4556-9c27-9f9bef0efae0)
- Select Send email with Cognito and ensure the default email address displaying
![image](https://github.com/user-attachments/assets/944727ea-955b-49ae-a5b3-b6854cd2d7ec)
- Enter an User pool name: weatherapppool
- Check Use the Cognito Hosted UI
- Select Domain type: Use a custom domain
- Select Custom domain and enter: enter an unique name (example: myweatherapp)
- Enter App client name: weatherapp
- Enter Allowed callback URLs: https://example.com
- Select Client secret for Generate a client secret
![image](https://github.com/user-attachments/assets/33623da1-d6e4-49ca-8498-10b2b24f4fa8)
- Click Next and verify all details
![image](https://github.com/user-attachments/assets/03199395-5ee2-44c3-8a13-364786dfdaef)8. Configure Cognito
- Click Create
![image](https://github.com/user-attachments/assets/97acccb1-ec2c-4ea4-93ec-2ef45be11e87)
- Navigate inside the Cognito
- Navigate to App Integration
- Scroll down to Resource servers and click Create Create resource server
- Enter a Resource server name: myweatherapp
- Enter Resource server identifier: weather
- Add Custom scopes-> Scope name: myweather and Description: anything
![image](https://github.com/user-attachments/assets/c16a6b99-e28a-4b4d-9052-18591a47629b)
- Verify the scope is created. Note: the scope is weather/myweather
![image](https://github.com/user-attachments/assets/a263c349-cfa0-4821-be40-ea9f0fd42f8a)
- Copy the Cognito Domain url (we will need it to send request from postman)
![Image](https://github.com/user-attachments/assets/7b89fae2-40d0-47a6-9b46-7126c229cdaf)
- Navigate inside the App client under App client list
- Click Edit the Hosted UI
![Image](https://github.com/user-attachments/assets/7a66e706-655e-47bc-907d-cd3cc875bc8a)
- Update the oAuth 2.0 grant types to Client credentials
- Add the Custom scopes
![Image](https://github.com/user-attachments/assets/c745acf8-939d-4c39-b73b-b6be2d155fc3)
- Note down the Client ID, Client secret(we will need it to send request from postman)
![Image](https://github.com/user-attachments/assets/a45b85e8-1b68-45bc-b633-e1526e151396)

### 15. Create Authorizer
- Navigate inside the API Gateway
- Click on Authorizers
- Authorizer name: weatherapp
- Authorizer type: Cognito
- Configure the Cognito user pool: select the correct az and cognito
- Enter Token source: Authorization
![Image](https://github.com/user-attachments/assets/1d7f2ce5-bc10-49a1-96d6-7d84c1b8ceaa)

### 16. Update the Method request in API Gateway
- Navigate to API Gateway
- Click on Method request
- Click on Method request
- Click Edit
- Select Authorization: weather
- Add scope: weather/myweather
- Click Save
![Image](https://github.com/user-attachments/assets/5ede8c5b-fc38-4aab-b072-a7cd93592a3d)
- Deploy API

### 17. Test
- Naviagate to Postman
- Add a Post Request
- Update Param with scope: weather/myweather and grant_type: client_credentials
- Update Authorization Auth Type with Username as the client id and password as client secret. Addtionallty update headers with Content-Type: application/x-www-form-urlencoded
![Image](https://github.com/user-attachments/assets/be7b5f67-eabc-48cc-8c75-3282f482e9c9)
![Image](https://github.com/user-attachments/assets/f5459ec7-0e73-456d-9bb4-39a5a5967a65)
- Click Send to generate token
![Image](https://github.com/user-attachments/assets/9f4f8ae2-c9ad-449e-b7ab-54f6f2974e3a)
- Create another Post request with the customdomain/resourcename
- Select Auth Type: Bearer Token
- Enter the Token
- Enter the below json in the Body section
```
{
   "coord": {
      "lon": 7.367,
      "lat": 45.133
   },
   "weather": [
      {
         "id": 501,
         "main": "Rain",
         "description": "moderate rain",
         "icon": "10d"
      },
      {
         "id": 502,
         "main": "Rain",
         "description": "moderate rain",
         "icon": "10d"
      },
      {
         "id": 503,
         "main": "Rain",
         "description": "moderate rain",
         "icon": "10d"
      },
      {
         "id": 504,
         "main": "Rain",
         "description": "moderate rain",
         "icon": "10d"
      },
      {
         "id": 505,
         "main": "Rain",
         "description": "moderate rain",
         "icon": "10d"
      }
   ]
}
```
- Click Send
![Image](https://github.com/user-attachments/assets/03b6267c-a2bc-43fd-9af3-9efbee8485f6)

Verify result
- Naviagate to the Firehouse stream
- Scroll to Destination settings-> Transform and convert records-> Click the hyperlink in Lambda function
- Click Monitor
- View CloudWatch logs
![Image](https://github.com/user-attachments/assets/2a7371c3-b1cb-42a5-b977-2218a4609bd7)
- Naviagate back to Firehouse stream
- Scroll to Destination settings-> Open S3 bucket and naviagate to the correct folder
![Image](https://github.com/user-attachments/assets/b86cb32d-25ec-4ef9-a3a6-b79e2033bb7d)

### 18. Cleanup (optional)
- Cleanup the resources to avoid any cost 
- Be sure to delete your cognito to avoid charges.

Reference:
Refer to class [Class 36](https://github.com/IzaanSchool/B2401_CloudComputing_DevOps_Resources/issues/99#issuecomment-2389942408)
