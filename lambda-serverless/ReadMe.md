# Lambda Serverless Deployment on AWS using Terraform (IaC)

Seamlessly deploy an MySQL RDS instance, a Redis Elasticache instance and 
a Lambda function using this terraform configuration.
To deploy your services use the command:

```
terraform apply 
```

And to drop all the deployed services, run: 

```
terraform destroy
```

The configurations uses some variables and you'll have to enter them each time
the deployment is done. In other to avoid this, you could create a **.tfvars**
file were you store the values of the variables, a sample is the **var.tfvars.test**
file. When this is done, pass the variable file to the command when running the 
configuration:

```
terraform apply -var-file=var.tfvars
```

```
terraform apply -var-file=var.tfvars
```

Another way is to store the variables in your environment.