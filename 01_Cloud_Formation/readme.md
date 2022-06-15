Lesson 1.1: Introduction to CloudFormation
Principle 1.1
AWS CloudFormation (CFN) is the preferred way we create AWS resources

Practice 1.1
A CFN Template is essentially a set of instructions for creating AWS resources, which includes practically everything that can be created in AWS. At its simplest, the service accepts a Template (a YAML-based blueprint describing the resources you want to create or update) and creates a Stack (a set of resources created using a single template). The resulting Stacks represent groups of resources whose life-cycles are inherently linked.

Read through Template Anatomy and get familiar with the basic parts of a CloudFormation template.

Lab 1.1.1: CloudFormation Template Requirements
Create the most minimal CFN template possible that can be used to create an AWS Simple Storage Service (S3) Bucket.

Always write your CloudFormation templates in YAML.
> Answer:
```yaml
Description: Creating an S3 bucket with minimal inputs
Resources:
  S3Bucket:
    Type: AWS::S3::Bucket

```

Launch a Stack by using the AWS CLI tool to run the template. Use your preferred region.

Note the output provided by creating the Stack.

Though functionally unnecessary, the Description (i.e. its purpose) element documents your code's intent, so provide one. The Description key-value pair should be at the root level of your template. If you place it under the definition of a resource, AWS will allow the template's creation but your description will not populate anything. See here for a useful guide to the anatomy of a template as well as YAML terminology.

Commit the template to your Github repository under the 01-cloudformation folder.

Lab 1.1.2: Stack Parameters
Update the same template by adding a CloudFormation Parameter to the stack and use the parameter's value as the name of the S3 bucket.

Put your parameter into a separate JSON file and pass that file to the CLI.

Update your stack.

Add the template changes and new parameter file to your Github repo.

Lab 1.1.3: Pseudo-Parameters
Update the same template by prefixing the name of the bucket with the Account ID in which it is being created, no matter which account you're running the template from (i.e., using pseudo-parameters).

Use built-in CFN string functions to combine the two strings for the Bucket name.

Do not hard code the Account ID. Do not use an additional parameter to provide the Account ID value.

Update the stack.

Commit the changes to your Github repo.

Lab 1.1.4: Using Conditions
Update the same template one final time. This time, use a CloudFormation Condition to add a prefix to the name of the bucket. When the current execution region is your preferred region, prefix the bucket name with the Account ID. When executing in all other regions, use the region name.

Update the stack that you originally deployed.

Create a new stack with the same stack name, but this time deploying to some region other than your preferred region.

Commit the changes to your Github repo.

>Answer:

```yaml

Parameters:
  BucketName:
    Type: String
    Description: Bucket name
  MyPreferredRegion:
    Type: String
    Description: dynamic region

Conditions:
  myRegion : !Equals
    - !Ref MyPreferredRegion
    - !Ref AWS::Region

Description: Creating an S3 bucket with minimal inputs
Resources:
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !If
        - myRegion
        - !Join
          - '-'
          - - !Ref AWS::AccountId
            - !Ref BucketName
        - !Join
          - '-'
          - - !Ref AWS::Region
            - !Ref BucketName



```

Lab 1.1.5: Termination Protection; Clean up
Before deleting this lesson's Stacks, apply Termination Protection to one of them.

>Answer: 
"""
aws cloudformation update-termination-protection \
--stack-name demo2312 \
--enable-termination-protection
 """

Try to delete the Stack using the AWS CLI. What happens?
``` 

An error occurred (ValidationError) when calling the DeleteStack operation: Stack [demo2312] cannot be deleted while Termination
Protection is enabled 
```


Remove termination protection and try again.

```
aws cloudformation update-termination-protection \
--stack-name demo2312 \
--no-enable-termination-protection
```

List the S3 buckets in both regions once this lesson's Stacks have been deleted to ensure their removal.

Retrospective 1.1
Question: Why YAML
Why do we prefer the YAML format for CFN templates?

Question: Protecting Resources
What else can you do to prevent resources in a stack from being deleted?

See DeletionPolicy.

How is that different from applying Termination Protection?

Task: String Substitution
Demonstrate 2 ways to code string combination/substitution using built-in CFN functions.

Lesson 1.2: Integration with Other AWS Resources
Principle 1.2
CloudFormation integrates well with the rest of the AWS ecosystem

Practice 1.2
A CFN template's resources can reference: each other's attributes, resource attributes exported from other Stacks in the same region, and Systems Manager Parameter Store values in the same region. This provides a way to have resources build on each other to create your AWS ecosystem.

Lab 1.2.1: Cross-Referencing Resources within a Template
Create a CFN template that describes two resources: an IAM User, and an IAM Managed Policy that controls that user.

The policy should allow access solely to 'Read' actions against all S3 Buckets (including listing buckets and downloading individual bucket contents)

Attach the policy to the user via the template.

Use a CFN Parameter to set the user's name

Create the Stack.
>Answer:
```yaml

Description: Creating an IAM user and assigned a managed policy
Resources:
  Managedpolicy1:
    Type: 'AWS::IAM::ManagedPolicy'
    Properties:
      Description: Policy for creating for read action against all s3 buckets
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Action:
              - s3:Get*
              - s3:List*
              - s3-object-lambda:Get*
              - s3-object-lambda:List*
            Resource: "*"

  Createiamuser:
    Type: AWS::IAM::User
    Properties:
      UserName: Cactus
      LoginProfile:
        Password: Cactusinlove2022!
        PasswordResetRequired: False
      ManagedPolicyArns:
        - !Ref Managedpolicy1

```


Lab 1.2.2: Exposing Resource Details via Exports
Update the template by adding a CFN Output that exports the Managed Policy's Amazon Resource Name (ARN).

Update the Stack.

> Answer:
```yaml
Description: Creating an IAM user and assigned a managed policy
Resources:
 Managedpolicy1:
  Type: 'AWS::IAM::ManagedPolicy'
  Properties:
   Description: Policy for creating for read action against all s3 buckets
   PolicyDocument:
    Version: '2012-10-17'
    Statement:
     - Effect: Allow
       Action:
        - s3:Get*
        - s3:List*
        - s3-object-lambda:Get*
        - s3-object-lambda:List*
       Resource: "*"

 Createiamuser:
  Type: AWS::IAM::User
  Properties:
   UserName: Cactus
   LoginProfile:
    Password: Cactusinlove2022!
    PasswordResetRequired: False
   ManagedPolicyArns:
    - !Ref Managedpolicy1

Outputs:
 ManagedPolicyARN:
  Description: Export of managed policy ARN
  Value: !Ref Managedpolicy1
  Export:
   Name: ManagedPolicyA
```

List all the Stack Exports in that Stack's region.
```aidl
aws cloudformation list-exports
```

Lab 1.2.3: Importing another Stack's Exports
Create a new CFN template that describes an IAM User and applies to it the Managed Policy ARN created by and exported from the previous Stack.

Create this new Stack.

> Answer: 
```yaml
Description: Creating an IAM user and assigned a managed policy
Resources:
  Createiamuser:
    Type: AWS::IAM::User
    Properties:
      UserName: Cactus2
      LoginProfile:
        Password: Cactusinlove2022!
        PasswordResetRequired: False
      ManagedPolicyArns:
        - Fn::ImportValue: ManagedPolicyA
- 
```

List all the Stack Imports in that stack's region.
```
 aws cloudformation list-imports \
     --export-name ManagedPolicyA

```

Lab 1.2.4: Import/Export Dependencies
Delete your CFN stacks in the same order you created them in. Did you succeed? If not, describe how you would identify the problem, and resolve it yourself.

``` You cannot delete in the same order since they are interconnected by export, remove in descending order```

Retrospective 1.2
Task: Policy Tester
Show how to use the IAM policy tester to demonstrate that the user cannot perform 'Put' actions on any S3 buckets.

Task: SSM Parameter Store
Using the AWS Console, create a Systems Manager Parameter Store parameter in the same region as the first Stack, and provide a value for that parameter. Modify the first Stack's template so that it utilizes this Parameter Store parameter value as the IAM User's name. Update the first stack. Finally, tear it down.

Lesson 1.3: Portability & Staying DRY
Principle 1.3
CloudFormation templates should be portable, supporting Don't Repeat Yourself (DRY) practices.

Practice 1.3
Portability refers to the ability of code (whether it's a script or an entire application) to work in multiple execution environments. This is achieved most often by removing hard coded configuration elements and providing an environment-specific configuration file. For CFN templates, portability is best provided by parameterizing the template (refer to AWS CloudFormation Best Practices for a more thorough list of recommendations for improving your use of CloudFormation). Some lab exercises have already demonstrated portability (can you point out where?) and this lesson will focus on it specifically.

Lab 1.3.1: Scripts and Configuration
Create a single script that re-uses one CloudFormation template to deploy a single S3 bucket.

Use shell scripting (bash or PowerShell) to create a Stack in each of the 4 American regions, using a looping construct to run the template the proper number of times.

Use an external JSON or YAML configuration file to maintain the target deployment region parameters. Consider using jq or yq to parse this file.

Each bucket name should be of the format "current-Region-current-Account-friendly-name" where the "friendly-name" value is parameterized in the CFN template but has a default value.

Lab 1.3.2: Coding with AWS SDKs
Repeat the exercise in the previous lab, with two modifications:

Use only a programming language (Python, Ruby or Javascript - i.e. NodeJS) and the corresponding SDK to repeat exactly what was done in that lab.

Extend the region targets (i.e. modify your configuration file) to include another US region.

Also adhere to these criteria:

The code must support updating existing stacks and creating new ones. This can be tricky as some SDKs require that you use a 'try/catch' construct to determine the existence of a stack. (Using rescue-oriented structures for decision logic is generally considered a programming anti-pattern.)

Use only a single shell command to execute your code script.

Lab 1.3.3: Enhancing the Code
Add code that provides for the deletion of your CFN stacks using the same configuration list, and then delete the stacks using that new functionality. Query S3 to ensure that the buckets have been deleted.

Commit your changes to your latest branch.
Retrospective 1.3
Question: Portability
Can you list 4 features of CloudFormation that help make a CFN template portable code?

Task: DRYer Code
How reusable is your SDK-orchestration code? Did you share a single method to load the configuration file for both stack creation/updating (Lab 1.3.2) and deletion (Lab 1.3.3)? Did you separate the methods for finding existing stacks from the methods that create or update those stacks?

If not, refactor your Python, Ruby or NodeJS scripts to work in the manner described.

Additional Reading
Related topics to extend your knowledge about CloudFormation:

Using Stack Policies to apply permissions to modify a stack

Using StackSets to deploy a CloudFormation stack simultaneously across an array of AWS Account and Regions