terraform {
  backend "s3" {
    bucket       = "tfstatebucket-663264486938"
    key          = "awsconfig/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}