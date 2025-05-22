# OCI Provider Configuration
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# VCN
resource "oci_core_vcn" "devsecops_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "DevSecOpsLabVCN"
  dns_label      = "devsecopslabvcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "devsecops_ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devsecops_vcn.id
  display_name   = "DevSecOpsLabIG"
  enabled        = true
}

# Route Table
resource "oci_core_route_table" "devsecops_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devsecops_vcn.id
  display_name   = "DevSecOpsLabRT"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.devsecops_ig.id
  }
}

# Security List for dsb-node-01
resource "oci_core_security_list" "dsb_node_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devsecops_vcn.id
  display_name   = "DSBNode01SL"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 3000
      max = 3000
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 8000
      max = 8000
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 9090
      max = 9090
    }
  }
}

# Security List for dsb-hub
resource "oci_core_security_list" "dsb_hub_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devsecops_vcn.id
  display_name   = "DSBHubSL"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 3000
      max = 3000
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 8080
      max = 8080
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 8081
      max = 8081
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 9000
      max = 9000
    }
  }
}

# Subnet for dsb-node-01
resource "oci_core_subnet" "dsb_node_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devsecops_vcn.id
  display_name   = "DSBNode01Subnet"
  cidr_block     = "10.0.1.0/24"
  route_table_id = oci_core_route_table.devsecops_rt.id
  security_list_ids = [oci_core_security_list.dsb_node_sl.id]
}

# Subnet for dsb-hub
resource "oci_core_subnet" "dsb_hub_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devsecops_vcn.id
  display_name   = "DSBHubSubnet"
  cidr_block     = "10.0.2.0/24"
  route_table_id = oci_core_route_table.devsecops_rt.id
  security_list_ids = [oci_core_security_list.dsb_hub_sl.id]
}

# Data source for Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Data source for Ubuntu Image (Arm64 - A1.Flex compatible)
data "oci_core_images" "ubuntu_image_arm" {
  compartment_id           = var.tenancy_ocid         # Or specific compartment if images are restricted
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"                  # Or your desired Ubuntu version
  shape                    = "VM.Standard.A1.Flex"    # Ensures compatibility with Arm instances
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"                   # Gets the latest image
}

# Compute Instance for dsb-node-01
resource "oci_core_instance" "dsb_node" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "dsb-node-01"
  shape              = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_image_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.dsb_node_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("../cloud-init/dsb-node-01.yaml")) # Path relative to this main.tf
  }
}

# Compute Instance for dsb-hub
resource "oci_core_instance" "dsb_hub" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "dsb-hub"
  shape              = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_image_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.dsb_hub_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("../cloud-init/dsb-hub.yaml")) # Path relative to this main.tf
  }
}