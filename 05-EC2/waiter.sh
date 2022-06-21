#!/bin/bash

aws cloudformation create-stack --stack-name ec2test --template-body file://5.1.2.yaml

aws cloudformation wait stack-create-complete --stack-name ec2test