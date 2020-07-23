resource "aws_ecr_repository" "ten10" {
  name                 = local.ecr_images["test"]
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(
    local.tags,
    {
      "Name" = local.ecr_images["test"]
    },
  )
}

