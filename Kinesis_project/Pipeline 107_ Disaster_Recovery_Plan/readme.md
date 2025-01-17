- [ ] Canary Deployment with two identical pipelines, where Target DB is same.
- [ ] Build a product description for your domain based on the data pipeline. Journal of building, deploying, troubleshooting
- [ ] Build SAM for entire project, for all components.
- [ ] Build CI/CD Pipeline
- [ ] Learn Disaster Recovery (DR) process. 
- [ ] Build run book to trouble shoot the problem
- [ ] Make RDS inaccessible by public network
- [ ] Understand Different Critical component of the system

# DR 

![Image](https://github.com/user-attachments/assets/6a199ec8-9f1a-487b-9ae2-c9bf5f46e770)

![Image](https://github.com/user-attachments/assets/2e3d87d0-9aef-4756-95d5-d611158d5503)

1. Enable Custom Domain for `us-east-1 `Cognito User Pool. Your domain must be `auth.yourdomain.com`
2. Add an A Record for `auth.yourdomain.com`and point to the cloudfront url of your cognito custom domain.
![image](https://github.com/user-attachments/assets/eecbd81b-d3d5-4ab5-adbb-8e8cc70e66e3)
3. Test your Cognito custom domain by getting a token using custom domain.
4. Add A
