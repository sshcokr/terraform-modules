resource "aws_iam_user" "admin_user"{
  count = length(var.iam_user_name)
  name = element(var.iam_user_name, count.index)
}

resource "aws_iam_group" "admin_user" {
  name = "admin_user"
}

resource "aws_iam_group_policy" "admin_user" {
  name   = "all_aws_policy_for_admin_user"
  group  = aws_iam_group.admin_user.id
  policy = data.aws_iam_policy_document.admin_policy.json
}

resource "aws_iam_group_membership" "admin" {
  count = length(var.iam_user_name)

  name  = "admin_group_membership"
  users = element([aws_iam_user.admin_user.*.name], count.index)
  group = aws_iam_group.admin_user.name
}

data "aws_iam_policy_document" "admin_policy" {
  statement {
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}
