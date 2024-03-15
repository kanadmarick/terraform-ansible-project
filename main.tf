#main.tf


resource "aws_key_pair" "km-key" {
    key_name = "km-key"
    public_key = file("km-key.pub")
}

# Creating Slave instance
resource "aws_instance" "slave" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name      = aws_key_pair.km-key.key_name
  # Installing Ansible in the slave node
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y ansible",
    ]
  }
  tags = {
    Name = "km-slavenode"
  }

# Sending YAML script to slave node
  provisioner "file" {
      source      = "wordpress.yml"
      destination = "/tmp/wordpress.yml"
  }
# Configuring WordPress Environment in Slave Node
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/wordpress.yml",
      "sudo ansible-playbook /tmp/wordpress.yml",
      "ansible-galaxy install geerlingguy.apache",
      "ansible-galaxy install geerlingguy.mysql",
      "ansible-galaxy install geerlingguy.php",
      "ansible-galaxy install inmotionhosting.wordpress"
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("km-key")
  }
}
