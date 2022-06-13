Task 9.1: Lambda is a fully-managed compute resource
Principle 9.1
As a fully managed compute resource, Lambda can reduce all the time and effort to configure and maintain virtual servers.

Lambda gives you a fully-managed compute resource running in AWS that allows you to run your code on demand with very little configuration needed and no maintenance required. AWS also provides robust testing tools via Cloud9, and methods of packaging and deploying your code easily. Lambda can be paired with API gateway to quickly create microservices.

API Gateway is a fully managed service that makes it easy to create, publish, maintain, monitor, and secure APIs at any scale. You can create an API that acts as a "front door" for applications to access data or functionality from your back-end services, such as workloads running on EC2, code running on AWS Lambda, or any web application.

Practice 9.1
Lab 9.1.1: Simple Lambda function
Create and test a simple AWS Lambda function using the Lambda console.

Use the wizard to create a new Lambda using your choice of language.

Update the lambda to return "Hello AWS!" and use the "Test" tool to run a test.

Review the options you have for testing and running Lambdas.

When you're done, delete the Lambda.

Lab 9.1.2: Lambda behind API Gateway
Using API gateway to run a Lambda function.

Use CloudFormation to create the same lambda as you did in lab 1. Use the in-line code feature to write the same "Hello AWS!" function.

Add an AWS API gateway to your template. Configure the gateway so that it will call the lambda function. You will need to implement:

AWS::ApiGateway::Method
AWS::ApiGateway::RestApi
AWS::ApiGateway::Deployment
Lambda execution role (AWS::IAM::Role) with an AssumeRole policy
Appropriate Lambda invoke permissions (AWS::Lambda::Permission)
Use the AWS CLI to call the API gateway which will call your Lambda function.

Lambdas can take a payload like JSON as input. Rewrite the function to take a JSON payload and simply return the payload, or an item from the payload.

Lab 9.1.3: Lambda & CloudFormation with awscli
Use the AWS CLI to create Lambda functions:

Using the template you created in lab 2, move the in-line code to a separate file and update the Lambda resource to reference the handler.

Use the "aws cloudformation package" and "... deploy" commands to create the CloudFormation stack. Note: The "package" command will need an S3 bucket to temporarily store the deployment package.

Use the API gateway to make a test call to the lambda to confirm it's working.

Retrospective 9.1
Task
Review other methods of creating microservices using API Gateway and Lambda such as Chalice (Python), Claudia.js (Node) and Aegis (Go). Understand how you can use AWS SAM to test and deploy Lambdas.

Lesson 9.2: Lambda and other AWS resources
Principle 9.2
Lambda can interact with other AWS services when using the appropriate execution policies.

Coupling Lambda with native AWS services allows you to create powerful code very quickly. Lambda can even be used with CloudWatch events to perform complex log analysis or react with automated mitigation functionality.

Practice 9.2
Lab 9.2.1: Lambda with DynamoDB
As a simple example, let's extend your Lambda function to write data to a table in DynamoDB:

Start with the template and code you created in lab 2

Add a DynamoDB table with several attributes of your choice

Update the Lambda code to take input based on the attributes and insert new items into the DynamoDB table.

Test the code using an API call as you've done before. Confirm that the call is inserting the item in the table.

Lab 9.2.2: Lambda via CloudWatch Rules
CloudWatch rules can be used to call Lambda functions based on events.

Add a CloudWatch rule to the template which targets your Lambda function when the S3 PutObject operation is called. If a trail doesn't exist for this, you may need to create one.

Modify your Lambda handler to log some of the event data to the DynamoDB.

Create an S3 bucket and test that the Lambda logs event data to the DB.

Lab 9.2.3: Query data with Lambda and API Gateway
Write another Lambda function that will query the DynamoDB table:

The function should take a pattern (for instance, a bucket name) and return all events for that pattern.

Add an API gateway that calls the Lambda to query the data.

Retrospective 9.2
Question
Can you think of practical ways an organization can use Lambda in reaction to AWS resource changes?