resource "aws_iam_role" "consul_instance" {
  name_prefix        = "${var.project}-role-"
  assume_role_policy = data.aws_iam_policy_document.instance_trust_policy.json
}

data "aws_iam_policy_document" "instance_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}


data "aws_iam_policy_document" "instance_permission_policy" {
  statement {
    sid    = "DescribeInstances"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "consul_instance_policy" {
  name_prefix = "${var.project}-instance-policy"
  role        = aws_iam_role.consul_instance.id
  policy      = data.aws_iam_policy_document.instance_permission_policy.json
}

resource "aws_iam_instance_profile" "consul_instance_profile" {
  name_prefix = "${var.project}-instance-profile-"
  role        = aws_iam_role.consul_instance.name
}