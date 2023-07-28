terraform {
  backend "http" {
    address        = "https://api.abbey.io/terraform-http-backend"
    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.4"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "abbey" {
  # Configuration options
  bearer_auth = var.abbey_token
}

provider "aws" {
  region = "us-east-1" #CHANGEME
}

resource "abbey_grant_kit" "IAM_membership" {
  name = "IAM_membership"
  description = <<-EOT
    Grants membership to an IAM Group.
    This Grant Kit uses a single-step Grant Workflow that requires only a single reviewer
    from a list of reviewers to approve access.
  EOT

  workflow = {
    steps = [
      {
        reviewers = {
          one_of = ["arvil+test1@abbey.io"]
        }
      }
    ]
  }

  output = {
    # Replace with your own path pointing to where you want your access changes to manifest.
    # Path is an RFC 3986 URI, such as `github://{organization}/{repo}/path/to/file.tf`.
    location = "github://arviln/aws-starterkit/access.tf" #CHANGEME
    append = <<-EOT
      resource "aws_iam_user_group_membership" "user_{{ .data.system.abbey.identities.aws_iam.name }}_group_${data.aws_iam_group.group1.group_name}" {
        user = "{{ .data.system.abbey.identities.aws_iam.name }}"
        groups = ["${data.aws_iam_group.group1.group_name}"]
      }
    EOT
  }
}

resource "abbey_identity" "user_1" {
  abbey_account = "arvil+test1@abbey.io"
  source = "aws_iam"
  metadata = jsonencode(
    {
      name = "quickstart-user" #CHANGEME
    }
  )
}

data "aws_iam_group" "group1" {
  group_name = "aws-quickstart-test"
}


