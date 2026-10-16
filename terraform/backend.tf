terraform {
  backend "s3" {
    bucket       = "blog-lab05-terraform-state"
    key          = "medium-blog/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}