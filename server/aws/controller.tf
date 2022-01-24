### Controller Instance

resource "aws_instance" "controllers" {
  count         = ( var.is_runtime ? ( var.is_ha ? 3 : 1) : 0)
  ami           = data.aws_ami.ec2_centos7_ami.image_id
  instance_type = var.ctr_instance_type
  key_name      = aws_key_pair.main.key_name
  vpc_security_group_ids = flatten([
    aws_default_security_group.main.id,
    aws_security_group.main.id
  ])
  subnet_id = aws_subnet.main.id
  user_data = data.template_file.cloud_data.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = 400
    tags = {
      Name            = "${var.project_id}-controller-${count.index + 1}-root-ebs"
      Project         = var.project_id
      user            = var.user
      deployment_uuid = random_uuid.deployment_uuid.result
    }
  }

  tags = {
    Name            = "${var.project_id}-controller-${count.index + 1}"
    Project         = var.project_id
    user            = var.user
    deployment_uuid = random_uuid.deployment_uuid.result
  }
}

# /dev/sdb
resource "aws_ebs_volume" "controller-ebs-volumes-sdb" {
  count = ( var.is_runtime ? ( var.is_ha ? 3 : 1) : 0)
  availability_zone = var.az
  size              = 500
  type              = "gp2"

  tags = {
    Name            = "${var.project_id}-controller${count.index + 1}-ebs-sdb"
    Project         = var.project_id
    user            = var.user
    deployment_uuid = random_uuid.deployment_uuid.result
  }
}

resource "aws_volume_attachment" "controller-volume-attachment-sdb" {
  count = ( var.is_runtime ? ( var.is_ha ? 3 : 1) : 0)
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.controller-ebs-volumes-sdb.*.id[count.index]
  instance_id = aws_instance.controllers.*.id[count.index]

  # hack to allow `terraform destroy ...` to work: https://github.com/hashicorp/terraform/issues/2957
  force_detach = true
}

### OUTPUTS
output "controller_private_ips" {
  value = [aws_instance.controllers.*.private_ip]
}
output "controller_private_dns" {
  value = [aws_instance.controllers.*.private_dns]
}
