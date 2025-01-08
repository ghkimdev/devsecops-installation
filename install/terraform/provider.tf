# Configure the AWS Provider
provider "aws" {
  shared_config_files      = ["/home/ubuntu/.aws/config"]
  shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
}
