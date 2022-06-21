**Comands used in the CLI for creating stacks and validation:**
    find the assignement folder:
        cd awAssignments/Launching\ EC2\,VPC\,SG\ in\ Cloudformation/

    Validate a template: 
        aws cloudformation validate-template --template-body file://A4ec2.yaml

    create a stack :
        aws cloudformation create-stack --stack-name cac --template-body file://A4ec2.yaml
    
    create a ec2-key-pair: 
        aws ec2 create-key-pair --key-name vpc-key-pair --query 'KeyMaterial' --output text > vpc-key-pair.pem
    
    to ssh into a private instance using a bastion, we need to do ssh agent key forwarding 
        eval `ssh-agent -s`
        ssh-add -K cactus.pem
        ssh -a ec2-user@address    :::  ssh -a ec2-user@ec2-3-95-79-167.compute-1.amazonaws.com
        ssh ec2-user@10.192.1.240privateip4addres
        ping -c 3 8.8.8.8


**Resources used for completing this stack:**
    ip-address guide:
        https://www.ipaddressguide.com/cidr

    Create an elastic ip:
        https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html
    
    Complete cloudformation sample template-very good link:
        https://docs.aws.amazon.com/codebuild/latest/userguide/cloudformation-vpc-template.html
    
    Nategateway:
        https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-natgateway.html
    
    Intrinsic functions: 
        https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-getatt.html
**Knowledge and theoritical links:** 

    Difference between Natgateway and internet gateway:
    https://explainexample.com/computers/aws/aws-difference-between-nat-gateway-and-internet-gateway

