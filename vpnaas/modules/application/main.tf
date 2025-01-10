# Prvider Configuration
provider "openstack" {
  region = var.region
}

data "openstack_networking_network_v2" "ext_net" {
  name = "ext-net"
}

# Select latest Openstack Ubuntu Image
data "openstack_images_image_v2" "image" {
  most_recent = true

  visibility = "public"
  properties = {
    os_distro  = "ubuntu"
    os_version = "24.04"
  }
}

# Create SSH Key
resource "openstack_compute_keypair_v2" "application" {
  name       = var.name
  public_key = var.public_key
}

# Create Security Group and Rules for SSH access and ICMP (ping)
resource "openstack_networking_secgroup_v2" "application_secgroup" {
  name        = "unicorn_secgroup"
  description = "Security group for ssh and icmp access"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.application_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.application_secgroup.id
}

# Create VM instance with a floating IP
resource "openstack_compute_instance_v2" "application" {
  depends_on  = [var.app_depends_on]
  name        = var.name
  image_name  = var.image_name != null ? var.image_name : data.openstack_images_image_v2.image.name
  flavor_name = var.flavor
  key_pair    = openstack_compute_keypair_v2.application.name
  security_groups = ["unicorn_secgroup","default"]

  network {
    name = var.network
  }
}

resource "openstack_networking_floatingip_v2" "application" {
  pool = data.openstack_networking_network_v2.ext_net.name
}

resource "openstack_networking_floatingip_associate_v2" "application" {
  floating_ip = openstack_networking_floatingip_v2.application.address
  port_id     = var.port_id
}
