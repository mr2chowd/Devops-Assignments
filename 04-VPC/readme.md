Topic 4: Virtual Private Clouds (VPCs)
Topic 4: Virtual Private Clouds (VPCs)
Lesson 4.1: Creating Your Own VPC
Principle 4.1
Practice 4.1
Lab 4.1.1: New VPC with "Private" Subnet
Lab 4.1.2: Internet Gateway
Lab 4.1.3: EC2 Key Pair
Lab 4.1.4: Test Instance
Question: Post Launch
Question: Verify Connectivity
Lab 4.1.5: Security Group
Question: Connectivity
Lab 4.1.6: Elastic IP
Question: Ping
Question: SSH
Question: Traffic
Lab 4.1.7: NAT Gateway
Question: Access
Question: Egress
Question: Deleting the Gateway
Question: Recreating the Gateway
Lab 4.1.8: Network ACL
Question: EC2 Connection
Retrospective 4.1
Lesson 4.2: Integration with VPCs
Principle 4.2
Practice 4.2
Lab 4.2.1: VPC Peering
Lab 4.2.2: EC2 across VPCs
Question: Public to Private
Question: Private to Public
Lab 4.2.3: VPC Endpoint Gateway to S3
Retrospective 4.2
Question: Corporate Networks
Further Reading
Lesson 4.1: Creating Your Own VPC
Principle 4.1
VPCs provide isolated environments for running all of your AWS services. Non-default VPCs are a critical component of any safe architecture.

Practice 4.1
This section walks you through the steps to create a new VPC. On every engagement, you'll be working in VPCs created by us or the client. Never use EC2 Classic or the default VPC.

This is a complicated set of labs. If you get stuck, take a look at the example template in the AWS::EC2::VPCPeering doc. It gives you a lot of info, but you can use it to see how resources are tied together. The AWS docs also provide a VPC template sample that may be useful.

**Lab 4.1.1: New VPC with "Private" Subnet**
Launch a new VPC via your AWS account, specifying a region that will be used throughout these lessons.

Use a CloudFormation YAML template.

Assign it a /16 CIDR block in private IP space, and provide that block as a stack parameter in a [separate parameters.json file].

Create an EC2 subnet resource within your CIDR block that has a /24 netmask.

Provide the VPC ID and subnet ID as stack outputs.

Tag all your new resources with:

the key "user" and your AWS user name;
"izaan-lesson" and this lesson number;
"izaan-lab" and this lab number.
Don't use dedicated tenancy (it's needlessly expensive).

Lab 4.1.2: Internet Gateway
Update your template to allow traffic to and from instances on your "private" subnet.

Add an Internet gateway resource.

Attach the gateway to your VPC.

Create a route table for the VPC, add the gateway to it, attach it to your subnet.

We can't call your subnet "private" any more. Now that it has an Internet Gateway, it can get traffic directly from the public Internet.

Lab 4.1.3: EC2 Key Pair
Create an EC2 key pair that you'll use to ssh to a test instance created in later labs. Use the AWS CLI.

Save the output as a .pem file in your project directory.

Be sure to create it in the same region you'll be doing your labs.

> Answer: 

```
 aws ec2 create-key-pair \
  --key-name fouronekey \
  --key-type rsa \
  --query "KeyMaterial" \
  --output text > fouronekey.pem
  
  chmod 400 fouronekey.pem
```

Lab 4.1.4: Test Instance
Launch an EC2 instance into your VPC.

Create another CFN template that specifies an EC2 instance.

For the subnet and VPC, reference the outputs from your VPC stack.

Use the latest Amazon Linux AMI.

Create a new parameter file for this template. Include the EC2 AMI ID, a T2 instance type, and the name of your key pair.

Provide the instance ID and private IP address as stack outputs.

Use the same tags you put on your VPC.

Question: Post Launch
After you launch your new stack, can you ssh to the instance?

No you cannot , since there is no public ip

Question: Verify Connectivity
Is there a way that you can verify Internet connectivity from the instance without ssh'ing to it?
>Anwer: 
```
You can ping it
```
Lab 4.1.5: Security Group
Add a security group to your EC2 stack:

Allow ICMP (for ping) and ssh traffic into your instance.
Question: Connectivity
Can you ssh to your instance yet?

>Answer

```
No you cannot, since there is yet no public IP
```
Lab 4.1.6: Elastic IP
Add an Elastic IP to your EC2 stack:

Attach it to your EC2 resource.

Provide the public IP as a stack output.

Your EC2 was already on a network with an IGW, and now we've fully exposed it to the Internet by giving it a public IP address that's reachable from anywhere outside your VPC.

Question: Ping
Can you ping your instance now?
>Answer: 
```
yes
```


Question: SSH
Can you ssh into your instance now?
>Answer: 

```
yes you can 
```

Question: Traffic
If you can ssh, can you send any traffic (e.g. curl) out to the Internet?

At this point, you've made your public EC2 instance an ssh bastion. We'll make use of that to explore your network below.

Lab 4.1.7: NAT Gateway
Update your VPC template/stack by adding a NAT gateway.

Attach your NAT GW to the subnet you created earlier.

Provision and attach a new Elastic IP for the NAT gateway.

We need a private instance to explore some of the concepts below. Let's add a new subnet and put a new EC2 instance on it. Add them to your existing instance stack.

The new subnet must have a unique netblock.

The NAT gateway should be the default route for the new subnet.

Aside from the subnet association, configure this instance just like the first one.

This instance will not have an Elastic IP.

Question: Access
Can you find a way to ssh to this instance?

Question: Egress
If you can ssh to it, can you send traffic out?

Question: Deleting the Gateway
If you delete the NAT gateway, what happens to the ssh session on your private instance?

Question: Recreating the Gateway
If you recreate the NAT gateway and detach the Elastic IP from the public EC2 instance, can you still reach the instance from the outside?

Test it out with the AWS console.

Lab 4.1.8: Network ACL
Add Network ACLs to your VPC stack.

First, add one on the public subnet:

It applies to all traffic (0.0.0.0/0).

Only allows ssh traffic from your IP address.

Allows egress traffic to anything.

Question: EC2 Connection
Can you still reach your EC2 instances?

Add another ACL to your private subnet:

Only allow traffic from the public subnet.

Allow only ssh, ping, and HTTP.

Allow all ports for egress traffic, but restrict replies to the public subnet.

Verify again that you can reach your instance.

Retrospective 4.1
For more information, read the AWS Documentation on VPC

Lesson 4.2: Integration with VPCs
Principle 4.2
VPCs are most useful when connected to external resources: other VPCs, other AWS services, and corporate networks.

Practice 4.2
VPCs provide important isolation for your resources. Often, though, they need to be connected to other services to poke holes through those walls of isolation.

Lab 4.2.1: VPC Peering
Copy the VPC template you created earlier and modify it to launch a private VPC in another region.

Add a new CIDR block for this VPC that doesn't overlap with the original one.

Don't attach an Internet gateway or NAT gateway to the new VPC. The new VPC will be private-only.

Update both VPC stacks to accept the netblock of the peering VPC as a parameter, so that you can...

add network ACLs in each VPC that allow all traffic in from the other VPC, and allow all traffic out from the source VPC.

Create a separate stack that will create a peering link between the 2 VPCs.

Create a VPC Peering Connection from one to the other.

Add a route in each VPC that sends traffic for the other VPC's CIDR to that VPC.

The VPC IDs should be passed as stack parameters.

Lab 4.2.2: EC2 across VPCs
Create a new EC2 template similar to your original one, but without an Elastic IP.

Launch it in your new private VPC.
Question: Public to Private
Can you ping this instance from the public instance you created earlier?

Question: Private to Public
Can you ping your public instance from this private instance? Which IPs are reachable, the public instance's private IP or its public IP, or both?

Use traceroute to see where traffic flows to both the public and private IPs.

Lab 4.2.3: VPC Endpoint Gateway to S3
VPC endpoints are something you'll see in practically all of our client engagements. It's really useful to know about them, but we realize the entire VPC topic is more time-consuming than most.

Create a VPC endpoint connection from your private VPC to S3.

Add the VPC endpoint gateway to your private VPC's CFN template. Pass the S3 bucket name as a parameter so it can be included in the policy.

Rework your access controls a bit to accommodate using a VPC endpoint:

Change the egress NACL rules on the subnet where the endpoint is attached so that they allow all traffic (see "Network ACL rules" in Troubleshoot Issues Connecting to S3 from VPC Endpoints.

In the bucket's policy document, grant access from your VPC and endpoint.

In the endpoint policy, grant access to the bucket you created in the S3 lesson.

After you update the stack, make sure you can reach the bucket from the instance in your private VPC.

Note: Try this out, but don't get stalled out here.If you're not making good progress after a few hours, even with the help of others, document where you're at and what's not working for you, then move on. Even though this is a valuable foundation, we have more important things for you to learn.

Retrospective 4.2
Question: Corporate Networks
How would you integrate your VPC with a corporate network?

Further Reading
VPN connections provide a way to connect to customer-premise networks.

VPC Endpoints provide a way to connect VPC privately to many more Amazon services, protecting any of that service traffic from traversing the open Internet.

Amazon VPC-to-Amazon VPC Connectivity Options describes many more options and design patterns for using VPCs.