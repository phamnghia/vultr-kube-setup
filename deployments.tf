variable "master_ip" {}

variable "node_ip" {}

variable "private_key_file" {}

# Installing master node
resource "null_resource" "kube_master" {
  provisioner "remote-exec" {
    scripts = [
      "./bash/kube-base.sh",
      "./bash/kube-master.sh",
    ]

    connection {
      host        = "${var.master_ip}"
      user        = "root"
      private_key = "${file("${var.private_key_file}")}"
    }
  }

  provisioner "local-exec" {
    command     = "scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/dev_rsa root@${var.master_ip}:kube_terraform/ .kubeadm"
    interpreter = ["bash", "-c"]
  }
}

# Installing node
resource "null_resource" "kube_node" {
  provisioner "remote-exec" {
    scripts = [
      "./bash/kube-base.sh",
    ]

    connection {
      host        = "${var.node_ip}"
      user        = "root"
      private_key = "${file("${var.private_key_file}")}"
    }
  }
}

resource "null_resource" "kube_node_join_cluster" {
  depends_on = [
    "null_resource.kube_node",
    "null_resource.kube_master",
  ]

  provisioner "local-exec" {
    command     = "scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key_file} .kubeadm root@${var.node_ip}:kube_terraform/"
    interpreter = ["bash", "-c"]
  }

  provisioner "remote-exec" {
    inline = [
      "kubeadm join $(cat /root/kube_terraform/api-address):$(cat /root/kube_terraform/api-port) --token $(cat /root/kube_terraform/token) --discovery-token-ca-cert-hash $(cat /root/kube_terraform/discovery-token-ca-cert-hash)",
    ]

    connection {
      host        = "${var.node_ip}"
      user        = "root"
      private_key = "${file("${var.private_key_file}")}"
    }
  }
}
