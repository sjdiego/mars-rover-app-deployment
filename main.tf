provider "aws" {
  region = "eu-south-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

data "template_file" "base_config" {
  template = file("${path.module}/templates/base_config.yml")

  vars = {
    env_name = "dev"
  }
}

data "template_file" "users" {
  template = file("${path.module}/templates/users.yml")

  vars = {
    username = "research"
  }
}

data "template_file" "rvm" {
  template = file("${path.module}/templates/rvm.sh")
}

data "template_file" "ruby" {
  template = file("${path.module}/templates/ruby.sh")

  vars = {
    username     = "research"
    ruby_version = "3.0.3"
  }
}

data "template_file" "setup_app" {
  template = file("${path.module}/templates/setup_app.sh")

  vars = {
    ruby_version = "3.0.3"
    username     = "sjdiego"
    app_repo     = "https://github.com/sjdiego/rails-mars-rover"
    app_path     = "/home/sjdiego/rails-mars-rover"
  }
}

data "template_file" "finished" {
  template = file("${path.module}/templates/finished.sh")

  vars = {
    env_name = "dev"
  }
}

data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "001_base_config.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.base_config.rendered
  }

  part {
    filename     = "002_rvm.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.rvm.rendered
  }

  part {
    filename     = "003_users.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.users.rendered
  }

  part {
    filename     = "004_ruby.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.ruby.rendered
  }

  part {
    filename     = "005_setup_app.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.setup_app.rendered
  }

  part {
    filename     = "006_finished.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.finished.rendered
  }
}

resource "aws_instance" "rails_mars_rover" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = data.cloudinit_config.user_data.rendered

  tags = {
    Name = "MarsRoverRailsApp"
  }
}
