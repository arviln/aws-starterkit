resource "aws_iam_user_group_membership" "user_quickstart-user_group_aws-quickstart-test" {
  user = "quickstart-user"
  groups = ["aws-quickstart-test"]
}
