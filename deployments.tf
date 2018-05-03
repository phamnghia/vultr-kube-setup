variable "master_ip" {}

variable "node-ips" {
  type = "list"
}

variable "private_key_file" {}
variable "private_key_str" {}

# Installing master node
resource "null_resource" "master_node" {
  provisioner "remote-exec" {
    scripts = [
      "./bash/kube-base.sh",
      "./bash/kube-master.sh",
    ]

    connection {
      host        = "${var.master_ip}"
      user        = "root"
      private_key = "${file(var.private_key_file)}"
    }
  }
}
