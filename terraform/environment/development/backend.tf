terraform {
  backend "s3" {
    bucket         = "iron-sky-tfstate-<your-unique-id>"
    key            = "development/aws/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
