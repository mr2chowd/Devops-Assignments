aws cloudformation create-stack --stack-name cac --template-body file://1.1_Create_S3.yaml
aws cloudformation create-stack --stack-name zero1 --template-body file://4.1.1.yaml --parameters parameters.json

aws ec2 create-key-pair \
--key-name fouronekey \
--key-type rsa \
--query "KeyMaterial" \
--output text > fouronekey.pem



chmod 400 fouronekey.pem


Links:
https://docs.aws.amazon.com/cli/latest/reference/cloudformation/create-stack.html
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpc.html
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-internetgateway.html
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-routetable.html

**IMPORTANT LINK:**
https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/