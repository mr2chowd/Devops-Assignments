# Topic 4: Virtual Private Clouds (VPCs)

<!-- TOC -->

- [Topic 4: Virtual Private Clouds (VPCs)](#topic-4-virtual-private-clouds-vpcs)
    - [Lesson 4.1: Creating Your Own VPC](#lesson-41-creating-your-own-vpc)
        - [Principle 4.1](#principle-41)
        - [Practice 4.1](#practice-41)
            - [Lab 4.1.1: New VPC with "Private" Subnet](#lab-411-new-vpc-with-private-subnet)
            - [Lab 4.1.2: Internet Gateway](#lab-412-internet-gateway)
            - [Lab 4.1.3: EC2 Key Pair](#lab-413-ec2-key-pair)
            - [Lab 4.1.4: Test Instance](#lab-414-test-instance)
                - [Question: Post Launch](#question-post-launch)
                - [Question: Verify Connectivity](#question-verify-connectivity)
            - [Lab 4.1.5: Security Group](#lab-415-security-group)
                - [Question: Connectivity](#question-connectivity)
            - [Lab 4.1.6: Elastic IP](#lab-416-elastic-ip)
                - [Question: Ping](#question-ping)
                - [Question: SSH](#question-ssh)
                - [Question: Traffic](#question-traffic)
            - [Lab 4.1.7: NAT Gateway](#lab-417-nat-gateway)
                - [Question: Access](#question-access)
                - [Question: Egress](#question-egress)
                - [Question: Deleting the Gateway](#question-deleting-the-gateway)
                - [Question: Recreating the Gateway](#question-recreating-the-gateway)
            - [Lab 4.1.8: Network ACL](#lab-418-network-acl)
                - [Question: EC2 Connection](#question-ec2-connection)
        - [Retrospective 4.1](#retrospective-41)
    - [Lesson 4.2: Integration with VPCs](#lesson-42-integration-with-vpcs)
        - [Principle 4.2](#principle-42)
        - [Practice 4.2](#practice-42)
            - [Lab 4.2.1: VPC Peering](#lab-421-vpc-peering)
            - [Lab 4.2.2: EC2 across VPCs](#lab-422-ec2-across-vpcs)
                - [Question: Public to Private](#question-public-to-private)
                - [Question: Private to Public](#question-private-to-public)
            - [Lab 4.2.3: VPC Endpoint Gateway to S3](#lab-423-vpc-endpoint-gateway-to-s3)
        - [Retrospective 4.2](#retrospective-42)
            - [Question: Corporate Networks](#question-corporate-networks)
    - [Further Reading](#further-reading)

<!-- /TOC -->

## Lesson 4.1: Creating Your Own VPC

### Principle 4.1

*VPCs provide isolated environments for running all of your AWS
services. Non-default VPCs are a critical component of any safe
architecture.*

### Practice 4.1

This section walks you through the steps to create a new VPC. On every
engagement, you'll be working in VPCs created by us or the client. Never
use EC2 Classic or the default VPC.

This is a complicated set of labs. If you get stuck, take a look at the
example template in the
[AWS::EC2::VPCPeering](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpcpeeringconnection.html)
doc. It gives you a lot of info, but you can use it to see how resources
are tied together. The AWS docs also provide a
[VPC template sample](https://s3.amazonaws.com/cloudformation-templates-us-east-1/vpc_single_instance_in_subnet.template)
that may be useful.

#### Lab 4.1.1: New VPC with "Private" Subnet

Launch a new VPC via your AWS account, specifying a region that will be
used throughout these lessons.

- Use a [CloudFormation YAML template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html).

- Assign it a /16 CIDR block in [private IP space](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html#VPC_Sizing),
  and provide that block as a stack parameter in a [[separate parameters.json
  file]](https://aws.amazon.com/blogs/devops/passing-parameters-to-cloudformation-stacks-with-the-aws-cli-and-powershell).

- Create an EC2 subnet resource within your CIDR block that has a /24
  netmask.

- Provide the VPC ID and subnet ID as stack outputs.

- Tag all your new resources with:

    - the key "user" and your AWS user name;

- Don't use dedicated tenancy (it's needlessly expensive).

```yaml
Description:  This template deploys a VPC, with a pair of public and private subnets spread
  across two Availability Zones. It deploys an internet gateway, with a default
  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
  and default routes for them in the private subnets.

Parameters:
  EnvironmentName:
    Description: Assignment 4 VPC
    Type: String
    Default: Assignment-4

  VpcCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String

  PrivateSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the private subnet in the first Availability Zone
    Type: String

Resources:
  VPC1:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PrivateSubnet1CIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1
```

#### Lab 4.1.2: Internet Gateway

Update your template to allow traffic [to and from instances](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
on your "private" subnet.

- Add an Internet gateway
  [resource](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-internetgateway.html).

- Attach the gateway to your VPC.

- Create a route table for the VPC, add the gateway to it, attach it
  to your subnet.

We can't call your subnet "private" any more. Now that it has an
Internet Gateway, it can get traffic directly from the public Internet.

```yaml
Description:  This template deploys a VPC, with a pair of public and private subnets spread
  across two Availability Zones. It deploys an internet gateway, with a default
  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
  and default routes for them in the private subnets.

Parameters:
  EnvironmentName:
    Description: Assignment 4 VPC
    Type: String
    Default: Assignment-4

  VpcCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String

  PrivateSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the private subnet in the first Availability Zone
    Type: String

Resources:
  VPC1:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PrivateSubnet1CIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1
  InternetGateway1:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.2
  InternetGatewayVPCAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC1
      InternetGatewayId: !GetAtt InternetGateway1.InternetGatewayId

  RouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable1
      SubnetId: !Ref PrivateSubnet1

  InternetGatewayRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref RouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !GetAtt InternetGateway1.InternetGatewayId

```

#### Lab 4.1.3: EC2 Key Pair

[Create an EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)
that you'll use to ssh to a test instance created in later labs. Use the
AWS CLI.

- Save the output as a .pem file in your project directory.

- Be sure to create it in the same region you'll be doing your labs.

```
$ aws ec2 create-key-pair --key-name vpclab-key-pair --query 'KeyMaterial' --output text > vpclab-key-pair.pem

```

#### Lab 4.1.4: Test Instance

Launch an EC2 instance into your VPC.

- Create another CFN template that specifies an EC2 instance.

- For the subnet and VPC, reference the outputs from your VPC stack.

- Use the latest Amazon Linux AMI.

- Create a new parameter file for this template. Include the EC2 AMI
  ID, a T2 instance type, and the name of your key pair.

- Provide the instance ID and private IP address as stack outputs.

- Use the same tags you put on your VPC.

```yaml
Description:  Creates an EC2 instance with the output from 4.1.3 subnet and VPC

Parameters:
  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'

  Instancetype:
    Description: Free Instance type for EC2
    Type: String

Resources:
  EC2Server:
    Type: AWS::EC2::Instance
    Properties:
      KeyName: fouronekey
      SubnetId: !ImportValue four-publicsubnetid
      ImageId: !Ref LatestAmiId
      InstanceType:  !Ref Instancetype
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1
Outputs:
  EC2ServerIDOutput:
    Description: A reference to the created EC2 INSTANCE ID
    Value: !Ref EC2Server
    Export:
      Name: Ec2ServerId
  PublicIpOutput:
    Description: Server Public IP
    Value: !GetAtt EC2Server.PrivateIp
    Export:
      Name: !Sub "${AWS::StackName}-PublicIp"



```

##### Question: Post Launch

_After you launch your new stack, can you ssh to the instance?_

> Ans: No, I cannot SSH to the instance.

##### Question: Verify Connectivity

_Is there a way that you can verify Internet connectivity from the instance
without ssh'ing to it?_

> Ans: Yes, by sending ping.

#### Lab 4.1.5: Security Group

Add a security group to your EC2 stack:

- Allow ICMP (for ping) and ssh traffic into your instance.

```yaml
Description:  Creates an EC2 instance with the output from 4.1.3 subnet and VPC

Parameters:
  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'

  Instancetype:
    Description: Free Instance type for EC2
    Type: String

Resources:
  EC2Server:
    Type: AWS::EC2::Instance
    Properties:
      KeyName: fouronekey
      SubnetId: !ImportValue four-publicsubnetid
      ImageId: !Ref LatestAmiId
      InstanceType:  !Ref Instancetype
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1
  SecurityGroup1:
    Type: AWS::EC2::SecurityGroup
    Description: Public Server Security Group
    Properties:
      GroupDescription: Allow ICMP and Tcp
      VpcId: !ImportValue four-vpc-id
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 10.192.0.0/24
        - IpProtocol: icmp
          FromPort: 8
          ToPort: -1
          CidrIp: 0.0.0.0/0
Outputs:
  EC2ServerIDOutput:
    Description: A reference to the created EC2 INSTANCE ID
    Value: !Ref EC2Server
    Export:
      Name: Ec2ServerId
  PublicIpOutput:
    Description: Server Public IP
    Value: !GetAtt EC2Server.PrivateIp
    Export:
      Name: !Sub "${AWS::StackName}-PublicIp"



```

##### Question: Connectivity

_Can you ssh to your instance yet?_

> Ans: No, I cannot.

#### Lab 4.1.6: Elastic IP

Add an Elastic IP to your EC2 stack:

- Attach it to your EC2 resource.

- Provide the public IP as a stack output.

```yaml
Description:  Creates an EC2 instance with the output from 4.1.3 subnet and VPC

Parameters:
  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'

  Instancetype:
    Description: Free Instance type for EC2
    Type: String
Resources:
  EC2Server:
    Type: AWS::EC2::Instance
    Properties:
      KeyName: fouronekey
      SubnetId: !ImportValue four-publicsubnetid
      ImageId: !Ref LatestAmiId
      InstanceType:  !Ref Instancetype
      SecurityGroupIds:
        - Ref: SecurityGroup1
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1
  SecurityGroup1:
    Type: AWS::EC2::SecurityGroup
    Description: Public Server Security Group
    Properties:
      GroupDescription: Allow ICMP and Tcp
      VpcId: !ImportValue four-vpc-id
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 184.146.8.52/24
        - IpProtocol: icmp
          FromPort: 8
          ToPort: -1
          CidrIp: 0.0.0.0/0
  PublicServerElasticIp:
    Type: AWS::EC2::EIP
    Properties:
      InstanceId: !Ref EC2Server
      Tags:
        - Key: Name
          Value: PublicServerElasticIp
Outputs:
  EC2ServerIDOutput:
    Description: A reference to the created EC2 INSTANCE ID
    Value: !Ref EC2Server
    Export:
      Name: Ec2ServerId
  PublicIpOutput:
    Description: Server Public IP
    Value: !GetAtt EC2Server.PrivateIp
    Export:
      Name: !Sub "${AWS::StackName}-PrivateIp"
  EC2ServerPublicIp:
    Description: Public IP of EC2 Server
    Value: !GetAtt EC2Server.PublicIp
    Export:
      Name: !Sub
        - "${AWS::StackName}-PublicIp"



```

Your EC2 was already on a network with an IGW, and now we've fully
exposed it to the Internet by giving it a public IP address that's
reachable from anywhere outside your VPC.

##### Question: Ping

_Can you ping your instance now?_

> Ans: Yes, I can.
> >

##### Question: SSH

_Can you ssh into your instance now?_

> Ans: Yes, I can.
>


##### Question: Traffic

_If you can ssh, can you send any traffic (e.g. curl) out to the Internet?_

> Ans: Yes, I can send traffic outside.
>
> $ curl www.google.ca

At this point, you've made your public EC2 instance an [ssh bastion](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html).
We'll make use of that to explore your network below.

#### Lab 4.1.7: NAT Gateway

Update your VPC template/stack by adding a [NAT gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html).

- Attach your NAT GW to the subnet you created earlier.

- Provision and attach a new Elastic IP for the NAT gateway.

We need a private instance to explore some of the concepts below. Let's
add a new subnet and put a new EC2 instance on it. Add them to your
existing instance stack.

- The new subnet must have a unique netblock.

- The NAT gateway should be the default route for the new subnet.

```yaml
Description:  This template deploys a VPC, with a pair of public and private subnets spread
  across two Availability Zones. It deploys an internet gateway, with a default
  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
  and default routes for them in the private subnets.

Parameters:
  EnvironmentName:
    Description: Assignment 4 VPC
    Type: String
    Default: Assignment-4

  VpcCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String

  PublicSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

  PrivateSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

Resources:
  VPC1:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PublicSubnet1CIDR
      Tags:
        - Key: Name
          Value: PublicSubnet1

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PrivateSubnet1CIDR
      Tags:
        - Key: Name
          Value: PrivateSubnet1

  InternetGateway1:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.2
  InternetGatewayVPCAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC1
      InternetGatewayId: !GetAtt InternetGateway1.InternetGatewayId

  RouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable1
      SubnetId: !Ref PublicSubnet1

  InternetGatewayRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref RouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !GetAtt InternetGateway1.InternetGatewayId

  NatGatewayEIP1:
    Type: AWS::EC2::EIP
    Properties:
      Domain: !Ref VPC1

  NateGateWay1:
    Type: AWS::EC2::NatGateway
    Properties:
      SubnetId: !Ref PublicSubnet1
      AllocationId: !GetAtt NatGatewayEIP1.AllocationId

  PrivateRouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PrivateSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet1

  DefaultPrivateRoute1:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NateGateWay1

Outputs:
  VPCID:
    Description: A reference to the created VPC ID
    Value: !Ref VPC1
    Export:
      Name: four-vpc-id

  PublicSubnetId1:
    Description: Reference to the public subnet id
    Value: !Ref PublicSubnet1
    Export:
      Name: four-publicsubnetid

  PrivateSubnet1:
    Description: A reference to the PRIVATE subnet in the 1st Availability Zone
    Value: !Ref PrivateSubnet1
    Export:
      Name: four-privatesubnetid
```

- Aside from the subnet association, configure this instance just like
  the first one.

- This instance will not have an Elastic IP.

```yaml
Description:  Creates an EC2 instance with the output from 4.1.3 subnet and VPC

Parameters:
  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'

  Instancetype:
    Description: Free Instance type for EC2
    Type: String
Resources:
  EC2Server:
    Type: AWS::EC2::Instance
    Properties:
      KeyName: fouronekey2
      SubnetId: !ImportValue four-publicsubnetid
      ImageId: !Ref LatestAmiId
      InstanceType:  !Ref Instancetype
      SecurityGroupIds:
        - Ref: SecurityGroup1
      Tags:
        - Key: "Name"
          Value: "EC2PublicServer"
  SecurityGroup1:
    Type: AWS::EC2::SecurityGroup
    Description: Public Server Security Group
    Properties:
      GroupDescription: Allow ICMP and Tcp
      VpcId: !ImportValue four-vpc-id
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 142.188.2.24/24
        - IpProtocol: icmp
          FromPort: 8
          ToPort: -1
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
  PublicServerElasticIp:
    Type: AWS::EC2::EIP
    Properties:
      InstanceId: !Ref EC2Server
      Tags:
        - Key: "Name"
          Value: "PublicServerElasticIp"

  EC2PrivateServer:
    Type: AWS::EC2::Instance
    Properties:
      KeyName: fouronekey2
      SubnetId: !ImportValue four-privatesubnetid
      ImageId: !Ref LatestAmiId
      InstanceType: !Ref Instancetype
      SecurityGroupIds:
        - Ref: SecurityGroupPrivate
      Tags:
        - Key: "Name"
          Value: "EC2PrivateServer"


  SecurityGroupPrivate:
    Type: AWS::EC2::SecurityGroup
    Description: Private Server Security Group
    Properties:
      GroupDescription: Allow ICMP and Tcp
      VpcId: !ImportValue four-vpc-id
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: icmp
          FromPort: 8
          ToPort: -1
          CidrIp: 0.0.0.0/0

Outputs:
  EC2ServerIDOutput:
    Description: A reference to the created EC2 INSTANCE ID
    Value: !Ref EC2Server
    Export:
      Name: Ec2ServerId
  PublicIpOutput:
    Description: Server Private IP
    Value: !GetAtt EC2Server.PrivateIp
    Export:
      Name: !Sub "${AWS::StackName}-PublicServerPrivateIp"

  EC2ServerPublicIp:
    Description: Public IP of EC2 Server
    Value: !GetAtt EC2Server.PublicIp
    Export:
      Name: !Sub "${AWS::StackName}-EC2ServerPublicIp"
  EC2PrivateServerIp:
    Description: Public IP of EC2 Server
    Value: !GetAtt EC2PrivateServer.PrivateIp
    Export:
      Name: !Sub "${AWS::StackName}-EC2PrivateServerIp"



```

##### Question: Access

_Can you find a way to ssh to this instance?_

> Ans: Yes, I can SSH this private instance after following these steps:

##### Question: Egress

_If you can ssh to it, can you send traffic out?_

> Ans: Yes, I can send traffic out
>
> $ curl www.google.ca

##### Question: Deleting the Gateway

_If you delete the NAT gateway, what happens to the ssh session on your private
instance?_

> Ans: After deleting the Nat Gateway, still I can SSH the private instance

##### Question: Recreating the Gateway

_If you recreate the NAT gateway and detach the Elastic IP from the public EC2
instance, can you still reach the instance from the outside?_

> Ans: After detaching EIP from public e2, I can not reach the public instance from outside.

Test it out with the AWS console.

#### Lab 4.1.8: Network ACL

Add Network ACLs to your VPC stack.

First, add one on the public subnet:

- It applies to all traffic (0.0.0.0/0).

- Only allows ssh traffic from your IP address.

- Allows egress traffic to anything.

```yaml
Description:  This template deploys a VPC, with a pair of public and private subnets spread
  across two Availability Zones. It deploys an internet gateway, with a default
  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
  and default routes for them in the private subnets.

Parameters:
  EnvironmentName:
    Description: Assignment 4 VPC
    Type: String
    Default: Assignment-4

  VpcCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String

  PublicSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

  PrivateSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

Resources:
  VPC1:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PublicSubnet1CIDR
      Tags:
        - Key: Name
          Value: PublicSubnet1

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PrivateSubnet1CIDR
      Tags:
        - Key: Name
          Value: PrivateSubnet1

  InternetGateway1:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.2
  InternetGatewayVPCAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC1
      InternetGatewayId: !GetAtt InternetGateway1.InternetGatewayId

  RouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable1
      SubnetId: !Ref PublicSubnet1

  InternetGatewayRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref RouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !GetAtt InternetGateway1.InternetGatewayId

  NatGatewayEIP1:
    Type: AWS::EC2::EIP
    Properties:
      Domain: !Ref VPC1

  NateGateWay1:
    Type: AWS::EC2::NatGateway
    Properties:
      SubnetId: !Ref PublicSubnet1
      AllocationId: !GetAtt NatGatewayEIP1.AllocationId

  PrivateRouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PrivateSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet1

  DefaultPrivateRoute1:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NateGateWay1

  PublicNetworkAcl:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId:
        Ref: VPC1

  PublicNACLAssociation:
    Type: AWS::EC2::SubnetNetworkAclAssociation
    Properties:
      NetworkAclId: !Ref PublicNetworkAcl
      SubnetId: !Ref PublicSubnet1
  PublicNACLInboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: 184.146.8.52/32
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: 6
      Egress: false
      PortRange:
        From: 22
        To: 22
  PublicNACLInboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 200
      RuleAction: allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: -1
      Egress: False

  PublicNACLOutboundboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: -1
      Egress: True

  PrivateNetworkAcl:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId: !Ref VPC1

  PrivateNACLAssociation:
    Type: AWS::EC2::SubnetNetworkAclAssociation
    Properties:
      NetworkAclId: !Ref PrivateNetworkAcl
      SubnetId: !Ref PrivateSubnet1

  PrivateNACLInboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: !Ref PublicSubnet1CIDR
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 6
      Egress: false
      PortRange:
        From: 22
        To: 22
  PrivateNACLOutboundboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 110
      RuleAction: Allow
      CidrBlock: !Ref PublicSubnet1CIDR
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 6
      Egress: True
      PortRange:
        From: 1024
        To: 65535

  PrivateNACLInboundICMP:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 200
      RuleAction: Allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 1
      Egress: False
      Icmp:
        Code: "-1"
        Type: "-1"
  PrivateNACLOutboundICMP:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 210
      RuleAction: Allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 1
      Egress: True
      Icmp:
        Code: "-1"
        Type: "-1"

Outputs:
  VPCID:
    Description: A reference to the created VPC ID
    Value: !Ref VPC1
    Export:
      Name: four-vpc-id

  PublicSubnetId1:
    Description: Reference to the public subnet id
    Value: !Ref PublicSubnet1
    Export:
      Name: four-publicsubnetid

  PrivateSubnet1:
    Description: A reference to the PRIVATE subnet in the 1st Availability Zone
    Value: !Ref PrivateSubnet1
    Export:
      Name: four-privatesubnetid
```

##### Question: EC2 Connection

_Can you still reach your EC2 instances?_

> Ans: Yes, I can reach my all instances.

Add another ACL to your private subnet:

- Only allow traffic from the public subnet.

- Allow only ssh, ping, and HTTP.

- Allow all ports for egress traffic, but restrict replies to the
  public subnet.

```yaml
Description:  This template deploys a VPC, with a pair of public and private subnets spread
  across two Availability Zones. It deploys an internet gateway, with a default
  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
  and default routes for them in the private subnets.

Parameters:
  EnvironmentName:
    Description: Assignment 4 VPC
    Type: String
    Default: Assignment-4

  VpcCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String

  PublicSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

  PrivateSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

Resources:
  VPC1:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PublicSubnet1CIDR
      Tags:
        - Key: Name
          Value: PublicSubnet1

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PrivateSubnet1CIDR
      Tags:
        - Key: Name
          Value: PrivateSubnet1

  InternetGateway1:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.2
  InternetGatewayVPCAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC1
      InternetGatewayId: !GetAtt InternetGateway1.InternetGatewayId

  RouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable1
      SubnetId: !Ref PublicSubnet1

  InternetGatewayRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref RouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !GetAtt InternetGateway1.InternetGatewayId

  NatGatewayEIP1:
    Type: AWS::EC2::EIP
    Properties:
      Domain: !Ref VPC1

  NateGateWay1:
    Type: AWS::EC2::NatGateway
    Properties:
      SubnetId: !Ref PublicSubnet1
      AllocationId: !GetAtt NatGatewayEIP1.AllocationId

  PrivateRouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PrivateSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet1

  DefaultPrivateRoute1:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NateGateWay1

  PublicNetworkAcl:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId:
        Ref: VPC1

  PublicNACLAssociation:
    Type: AWS::EC2::SubnetNetworkAclAssociation
    Properties:
      NetworkAclId: !Ref PublicNetworkAcl
      SubnetId: !Ref PublicSubnet1
  PublicNACLInboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: 184.146.8.52/32
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: 6
      Egress: false
      PortRange:
        From: 22
        To: 22
  PublicNACLInboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 200
      RuleAction: allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: -1
      Egress: False

  PublicNACLOutboundboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: -1
      Egress: True

  PrivateNetworkAcl:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId: !Ref VPC1

  PrivateNACLAssociation:
    Type: AWS::EC2::SubnetNetworkAclAssociation
    Properties:
      NetworkAclId: !Ref PrivateNetworkAcl
      SubnetId: !Ref PrivateSubnet1

  PrivateNACLInboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: !Ref PublicSubnet1CIDR
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 6
      Egress: false
      PortRange:
        From: 22
        To: 22
  PrivateNACLOutboundboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 110
      RuleAction: Allow
      CidrBlock: !Ref PublicSubnet1CIDR
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 6
      Egress: True
      PortRange:
        From: 1024
        To: 65535

  PrivateNACLInboundICMP:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 200
      RuleAction: Allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 1
      Egress: False
      Icmp:
        Code: "-1"
        Type: "-1"
  PrivateNACLOutboundICMP:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 210
      RuleAction: Allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 1
      Egress: True
      Icmp:
        Code: "-1"
        Type: "-1"

Outputs:
  VPCID:
    Description: A reference to the created VPC ID
    Value: !Ref VPC1
    Export:
      Name: four-vpc-id

  PublicSubnetId1:
    Description: Reference to the public subnet id
    Value: !Ref PublicSubnet1
    Export:
      Name: four-publicsubnetid

  PrivateSubnet1:
    Description: A reference to the PRIVATE subnet in the 1st Availability Zone
    Value: !Ref PrivateSubnet1
    Export:
      Name: four-privatesubnetid
```
_Verify again that you can reach your instance._

> Ans:
>
> SSH:
>   - Yes, I can SSH to both of the instances.

>
> ICMP:
>   - Yes
>
> HTTP:
- To check the http request from private instance, Install httpd service in private instance. 
- Applying the above ACL on private subnet, It does not allow aws ec2 repositories to install httpd.
- Furthermore, it requires vpc endpoint setup for getting the aws repositories from specific aws defined s3 bucket.
- httpd installation was done before applying the NACL to the private subnet.
- A html file was created inside /var/www/html named "index.html" with some content "Hello... This is Mos World."
- Execute following two commands to active and enable httpd service in private instance:
    >     - $ systemctl start httpd
    >     - $ systemctl enable httpd
    >     - $ curl localhost
- Allowing http in the security group of private instance
> Note: Yum repo for ec2 without internet:
> 
> https://aws.amazon.com/premiumsupport/knowledge-center/ec2-al1-al2-update-yum-without-internet/

### Retrospective 4.1

For more information, read the [AWS Documentation on VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)

## Lesson 4.2: Integration with VPCs

### Principle 4.2

*VPCs are most useful when connected to external resources: other VPCs,
other AWS services, and corporate networks.*

### Practice 4.2

VPCs provide important isolation for your resources. Often, though, they
need to be connected to other services to poke holes through those walls
of isolation.

#### Lab 4.2.1: VPC Peering

Copy the VPC template you created earlier and modify it to launch a
private VPC in another region.

- Add a new [CIDR block](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html#VPC_Sizing)
  for this VPC that doesn't overlap with the original one.

- Don't attach an Internet gateway or NAT gateway to the new VPC. The
  new VPC will be private-only.

- Update both VPC stacks to accept the netblock of the peering VPC as
  a parameter, so that you can...

- add network ACLs in each VPC that allow all traffic in from the
  other VPC, and allow all traffic out from the source VPC.

Create a separate stack that will create a
[peering](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html)
link between the 2 VPCs.

- Create a [VPC Peering Connection](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpcpeeringconnection.html)
  from one to the other.

- Add a route in each VPC that sends traffic for the other VPC's CIDR
  to that VPC.

- The VPC IDs should be passed as stack parameters.

```yaml
Resources:
  VpcPeeringConnection:
    Type: AWS::EC2::VPCPeeringConnection
    Properties:
      VpcId:
        Fn::ImportValue: VPCPeerid1
      PeerVpcId: !ImportValue four-vpc-id
      PeerRegion: us-east-1

  PeerGatewayRoute1:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !ImportValue RouteTable1id
      DestinationCidrBlock: 11.192.0.0/16
      VpcPeeringConnectionId: !Ref VpcPeeringConnection

  RouteTableForPeering1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !ImportValue VPCPeerid1


  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTableForPeering1
      SubnetId: !ImportValue peerpublicsubnetid

  RoutetoVPC1:
    Type: AWS::EC2::Route
    Properties:
      VpcPeeringConnectionId: !Ref VpcPeeringConnection
      DestinationCidrBlock: 10.192.0.0/16
      RouteTableId: !Ref RouteTableForPeering1

```
```yaml
Description:  This template deploys a VPC, with a pair of public and private subnets spread
  across two Availability Zones. It deploys an internet gateway, with a default
  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
  and default routes for them in the private subnets.

Parameters:
  EnvironmentName:
    Description: Assignment 4 VPC
    Type: String
    Default: Assignment-4

  VpcCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String

  PublicSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

  PrivateSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

Resources:
  VPC1:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.1

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PublicSubnet1CIDR
      Tags:
        - Key: Name
          Value: PublicSubnet1

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC1
      CidrBlock: !Ref PrivateSubnet1CIDR
      Tags:
        - Key: Name
          Value: PrivateSubnet1

  InternetGateway1:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: User
          Value: mr2chowd
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.1.2
  InternetGatewayVPCAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC1
      InternetGatewayId: !GetAtt InternetGateway1.InternetGatewayId

  RouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable1
      SubnetId: !Ref PublicSubnet1

  InternetGatewayRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref RouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !GetAtt InternetGateway1.InternetGatewayId

  NatGatewayEIP1:
    Type: AWS::EC2::EIP
    Properties:
      Domain: !Ref VPC1

  NateGateWay1:
    Type: AWS::EC2::NatGateway
    Properties:
      SubnetId: !Ref PublicSubnet1
      AllocationId: !GetAtt NatGatewayEIP1.AllocationId

  PrivateRouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC1

  PrivateSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet1

  DefaultPrivateRoute1:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NateGateWay1

  PublicNetworkAcl:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId:
        Ref: VPC1

  PublicNACLAssociation:
    Type: AWS::EC2::SubnetNetworkAclAssociation
    Properties:
      NetworkAclId: !Ref PublicNetworkAcl
      SubnetId: !Ref PublicSubnet1
  PublicNACLInboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: 184.146.8.52/32
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: 6
      Egress: false
      PortRange:
        From: 22
        To: 22
  PublicNACLInboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 200
      RuleAction: allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: -1
      Egress: False

  PublicNACLOutboundboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PublicNetworkAcl
      Protocol: -1
      Egress: True

  PrivateNetworkAcl:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId: !Ref VPC1

  PrivateNACLAssociation:
    Type: AWS::EC2::SubnetNetworkAclAssociation
    Properties:
      NetworkAclId: !Ref PrivateNetworkAcl
      SubnetId: !Ref PrivateSubnet1

  PrivateNACLInboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: !Ref PublicSubnet1CIDR
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 6
      Egress: false
      PortRange:
        From: 22
        To: 22
  PrivateNACLOutboundboundSSH:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 110
      RuleAction: Allow
      CidrBlock: !Ref PublicSubnet1CIDR
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 6
      Egress: True
      PortRange:
        From: 1024
        To: 65535

  PrivateNACLInboundICMP:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 200
      RuleAction: Allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 1
      Egress: False
      Icmp:
        Code: "-1"
        Type: "-1"
  PrivateNACLOutboundICMP:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 210
      RuleAction: Allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !Ref PrivateNetworkAcl
      Protocol: 1
      Egress: True
      Icmp:
        Code: "-1"
        Type: "-1"


Outputs:
  VPCID:
    Description: A reference to the created VPC ID
    Value: !Ref VPC1
    Export:
      Name: four-vpc-id

  PublicSubnetId1:
    Description: Reference to the public subnet id
    Value: !Ref PublicSubnet1
    Export:
      Name: four-publicsubnetid

  PrivateSubnet1:
    Description: A reference to the PRIVATE subnet in the 1st Availability Zone
    Value: !Ref PrivateSubnet1
    Export:
      Name: four-privatesubnetid

  VPCCIDR:
    Description: A reference to the created VPC CIDR BLOCK for VPC 1
    Value: !GetAtt VPC1.CidrBlock
    Export:
      Name: VPC1DCIDR-Block

  RouteTablePublicid:
    Description: A reference to the created VPC CIDR BLOCK for VPC 1
    Value: !Ref RouteTable1
    Export:
      Name: RouteTable1id

```

```yaml
Description:  Another Vpc2 for testing VPC peering connections

Parameters:
  EnvironmentName:
    Description: Assignment 4.2 VPC Peering
    Type: String
    Default: Assignment-4 part 2 Peering

  VpcPeerCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String

  PublicSubnet1CIDRPeer:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

  PrivateSubnet1CIDRPeer:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String

  VpcCIDR:
    Description: To import the CIDR block of first VPC
    Type: String

  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'

  Instancetype:
    Description: Free Instance type for EC2
    Type: String
Resources:
  VPCPeer:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcPeerCIDR
      Tags:
        - Key: User
          Value: Peer1
        - Key: project
          Value: VPC-4
        - Key: lab
          Value: 4.2.1
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPCPeer
      CidrBlock: !Ref PublicSubnet1CIDRPeer
      Tags:
        - Key: Name
          Value: PublicSubnet1CIDRPeer

  PublicNetworkAcl:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId:
        Ref: VPCPeer

  PublicNACLAssociation:
    Type: AWS::EC2::SubnetNetworkAclAssociation
    Properties:
      NetworkAclId: !Ref PublicNetworkAcl
      SubnetId: !Ref PublicSubnet1

  PublicNACLInboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: !Ref VpcCIDR
      NetworkAclId: !GetAtt PublicNetworkAcl.Id
      Protocol: -1
      Egress: False

  PublicNACLOutboundboundAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      RuleNumber: 100
      RuleAction: allow
      CidrBlock: 0.0.0.0/0
      NetworkAclId: !GetAtt PublicNetworkAcl.Id
      Protocol: -1
      Egress: True

  EC2PeerServer:
    Type: AWS::EC2::Instance
    Properties:
      KeyName: fouronekey2
      SubnetId: !Ref PublicSubnet1
      ImageId: !Ref LatestAmiId
      InstanceType: !Ref Instancetype
      SecurityGroupIds:
        - Ref: SecurityGroupPrivate
      Tags:
        - Key: "Name"
          Value: "EC2PeerServer"


  SecurityGroupPrivate:
    Type: AWS::EC2::SecurityGroup
    Description: Private Server Security Group
    Properties:
      GroupDescription: Allow ICMP and Tcp
      VpcId: !Ref VPCPeer
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: icmp
          FromPort: 8
          ToPort: -1
          CidrIp: 0.0.0.0/0

Outputs:
  VPCID:
    Description: A reference to the created VPC ID
    Value: !Ref VPCPeer
    Export:
      Name: VPCPeerid1

  PublicSubnetId1:
    Description: Reference to the public subnet id
    Value: !Ref PublicSubnet1
    Export:
      Name: peerpublicsubnetid
```
#### Lab 4.2.2: EC2 across VPCs

Create a new EC2 template similar to your original one, but without an
Elastic IP.

- Launch it in your new private VPC.

##### Question: Public to Private

_Can you ping this instance from the public instance you created earlier?_

##### Question: Private to Public

_Can you ping your public instance from this private instance? Which IPs are
reachable, the public instance's private IP or its public IP, or both?_

Use traceroute to see where traffic flows to both the public and private IPs.

#### Lab 4.2.3: VPC Endpoint Gateway to S3

VPC endpoints are something you'll see in practically all of our client
engagements. It's really useful to know about them, but we realize the
entire VPC topic is more time-consuming than most.

Create a [VPC endpoint](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpcendpoint.html)
connection from your private VPC to S3.

- Add the VPC endpoint gateway to your private VPC's CFN template.
  Pass the S3 bucket name as a parameter so it can be included in
  the policy.

- Rework your access controls a bit to accommodate using a VPC
  endpoint:

    - Change the egress NACL rules on the subnet where the endpoint is
      attached so that they allow all traffic (see "Network ACL rules" in
      [Troubleshoot Issues Connecting to S3 from VPC Endpoints](https://aws.amazon.com/premiumsupport/knowledge-center/connect-s3-vpc-endpoint/).

    - In the bucket's [policy document](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints-s3.html#vpc-endpoints-policies-s3),
      grant access from your VPC and endpoint.

    - In the endpoint policy, grant access to the bucket you created in the S3 lesson.

After you update the stack, make sure you can reach the bucket from the
instance in your private VPC.

_Note: Try this out, but don't get stalled out here.If you're not
making good progress after a few hours, even with the help of others,
document where you're at and what's not working for you, then move on.
Even though this is a valuable foundation, we have more important things for
you to learn._

### Retrospective 4.2

#### Question: Corporate Networks

_How would you integrate your VPC with a corporate network?_

## Further Reading

- [VPN](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpn-connections.html)
  connections provide a way to connect to customer-premise networks.

- [VPC Endpoints](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-endpoints.html)
  provide a way to connect VPC privately to many more Amazon
  services, protecting any of that service traffic from traversing
  the open Internet.

- [Amazon VPC-to-Amazon VPC Connectivity Options](https://docs.aws.amazon.com/aws-technical-content/latest/aws-vpc-connectivity-options/amazon-vpc-to-amazon-vpc-connectivity-options.html)
  describes many more options and design patterns for using VPCs.
  