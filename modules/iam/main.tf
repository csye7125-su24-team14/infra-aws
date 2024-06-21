# resource "aws_iam_role" "this" {
#   for_each = toset(["single", "multiple"])

#   name = "ex-${each.key}"

#   # Just using for this example
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = "Example"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }