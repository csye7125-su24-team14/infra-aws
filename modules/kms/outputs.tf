output "eks_kms_arn" {
  value = aws_kms_key.eks_node_kms.arn
}
