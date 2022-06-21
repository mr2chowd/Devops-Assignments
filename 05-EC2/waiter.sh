#!/bin/bash

aws cloudformation update-stack --stack-name ec2test --template-body file://5.2.1.yaml

aws cloudformation wait stack-create-complete --stack-name ec2test