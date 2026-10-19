terraform {
  backend "s3" {
    bucket       = "medium-blog-terraform-state-files"
    key          = "medium-blog/lab05/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}