**-Important commands**
find the assignement folder:
  

  Validate a template:
  aws cloudformation validate-template --template-body file://lambdawithcf.yaml

  create a stack :
  aws cloudformation create-stack --stack-name cac --template-body file://1.1_Create_S3.yaml

  aws cloudformation deploy \
  --stack-name demo \
  --template-file 1.2.yaml --parameter-overrides file://test.json  \

  create a ec2-key-pair:
  aws ec2 create-key-pair --key-name vpc-key-pair --query 'KeyMaterial' --output text > vpc-key-pair.pem

**Important Links:**
- https://nickolaskraus.io/articles/creating-an-amazon-api-gateway-with-a-lambda-integration-using-cloudformation/
