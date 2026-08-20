# WordPress + MySQL Migration to AWS

A hands-on cloud engineering project: rebuilding a legacy WordPress site and its MySQL database on AWS using Terraform for infrastructure and Ansible for configuration management.

## Architecture

- **VPC** with public and private subnets across 2 AZs
- **EC2** instance (WordPress/Apache/PHP) in a public subnet, behind an **Application Load Balancer**
- **RDS MySQL** in the private subnets, reachable only from the EC2 security group
- **NAT Gateway** for outbound internet access from private subnets
- **S3** bucket used as the transfer point for the database dump during migration
- **Secrets Manager** stores auto-generated DB credentials, nothing sensitive lives in tfvars
- **IAM role** on the EC2 instance, scoped to read the S3 dump and the Secrets Manager secret
- **GitHub Actions** runs terraform fmt, validate, and plan on every pull request, authenticating to AWS via OIDC

Security groups are chained: internet to ALB (80/443), ALB to EC2 (80 only), EC2 to RDS (3306 only). SSH is restricted to a single admin CIDR.

## Repo structure

terraform/modules/          - vpc, security-groups, s3, iam, rds, ec2, secrets
terraform/environments/dev/ - root config wiring the modules together
ansible/inventory/          - dynamic AWS EC2 inventory
ansible/roles/               - common, apache, php, mysql_client, wordpress
ansible/playbook.yml
migration/db-export.sh      - run on the legacy MySQL server, uploads dump to S3
migration/db-import.sh      - manual S3 to RDS import (Ansible does this automatically)
.github/workflows/terraform-plan.yml - CI: fmt/validate/plan on every PR touching terraform/

## Prerequisites

- Terraform >= 1.5
- AWS CLI v2, configured with credentials that can create VPC/EC2/RDS/IAM/S3/Secrets Manager resources
- Ansible + the amazon.aws collection + boto3/botocore
- An existing EC2 key pair in your target region

## Setup

1. Bootstrap remote state (one-time, manual): create an S3 bucket and DynamoDB table, then update terraform/environments/dev/backend.tf with your names.

2. Configure variables:
   cd terraform/environments/dev
   cp terraform.tfvars.example terraform.tfvars
   (fill in admin_cidr, migration_bucket_name, key_name)

3. Provision infrastructure:
   terraform init
   terraform plan
   terraform apply

4. Export the legacy database and push to S3:
   cd ../../../migration
   export DB_NAME=wordpress DB_USER=<user> MIGRATION_BUCKET=<bucket-from-output>
   ./db-export.sh

5. Deploy WordPress and migrate the database:
   cd ..
   ansible-playbook -i ansible/inventory/aws_ec2.yml ansible/playbook.yml --private-key ~/.ssh/<your-key>.pem -u ubuntu -e migration_bucket=<bucket> -e db_secret_id=<db_secret_id from terraform output>

6. Visit the ALB DNS name from the Terraform output to confirm the site is live.

## Cleanup

cd terraform/environments/dev
terraform destroy

This tears down the VPC/EC2/RDS/ALB stack. The state bucket and DynamoDB lock table are left in place for reuse.

## Notes

- Database credentials are generated with random_password and stored only in Secrets Manager, never in tfvars or version control.
- terraform.tfvars and any .sql dumps are gitignored; only .tfvars.example is tracked.
- CI authenticates via OIDC role assumption, not stored AWS access keys.
