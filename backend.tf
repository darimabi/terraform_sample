terraform {
  backend "s3" {
    bucket = "enchanted-backend"
    key    = "sample.state"
    region = "us-east-1"
  }
}