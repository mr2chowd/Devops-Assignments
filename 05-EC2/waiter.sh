#!/bin/bash

#aws cloudformation update-stack --stack-name e --template-body file://5.2.1.yaml

aws cloudformation create-stack --stack-name e --template-body file://5.2.1.yaml

#aws cloudformation wait stack-create-complete --stack-name e
#
#aws ec2 create-key-pair \
#    --key-name my-key-pair \
#    --key-type rsa \
#    --output text > my-key-pair.pem