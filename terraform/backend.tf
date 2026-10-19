terraform {
  backend "s3" {
    bucket       = "terraform-tfstate-blog-lab05"
    key          = "medium-blog/lab05/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}