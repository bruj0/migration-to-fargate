terraform {
  backend "s3" {
    bucket         = "terraform-state-migration-285552317064-eu-north-1"
    key            = "eks-cluster/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-lock-migration"
    encrypt        = true
  }
}