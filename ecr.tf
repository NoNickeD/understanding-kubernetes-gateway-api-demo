resource "aws_ecr_repository" "ecr-repository" {
  name                 = "${var.cluster_name}-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, { kind = "ecr" })
}
