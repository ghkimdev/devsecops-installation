resource "aws_s3_bucket" "jenkins" {
  bucket        = "my-aws-jenkins-s3-bucket"
  force_destroy = true

  tags = {
    Name        = "My Jenkins Bucket"
  }
}
