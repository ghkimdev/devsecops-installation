terraform {
  backend "s3" {
    bucket = "my-aws-terraform-s3-bucket"
    key = "terraform.tfstate"
    region = "ap-northeast-2"
  }
}
