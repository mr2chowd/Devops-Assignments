**-Important commands**
find the assignement folder:
  cd Assignments/Launching\ EC2\,VPC\,SG\ in\ Cloudformation/

  Validate a template:
  aws cloudformation validate-template --template-body file://lambdawithcf.yaml

  create a stack :
  aws cloudformation create-stack --stack-name cac --template-body file://lambdawithcf.yaml

  create a ec2-key-pair:
  aws ec2 create-key-pair --key-name vpc-key-pair --query 'KeyMaterial' --output text > vpc-key-pair.pem

**Important Links:**
- https://nickolaskraus.io/articles/creating-an-amazon-api-gateway-with-a-lambda-integration-using-cloudformation/
