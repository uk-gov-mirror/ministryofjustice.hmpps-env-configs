output "test_images" {
  value = {
    url  = aws_ecr_repository.ten10.repository_url
    name = aws_ecr_repository.ten10.name
  }
}

output "ten10" {
  value = {
    sg_id = aws_security_group.ten10.id
  }
}

