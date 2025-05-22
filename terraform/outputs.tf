output "dsb_node_public_ip" {
  description = "Public IP address of dsb-node-01"
  value       = oci_core_instance.dsb_node.public_ip
}

output "dsb_hub_public_ip" {
  description = "Public IP address of dsb-hub"
  value       = oci_core_instance.dsb_hub.public_ip
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.devsecops_vcn.id
}

output "dsb_node_subnet_id" {
  description = "OCID of dsb-node-01 subnet"
  value       = oci_core_subnet.dsb_node_subnet.id
}

output "dsb_hub_subnet_id" {
  description = "OCID of dsb-hub subnet"
  value       = oci_core_subnet.dsb_hub_subnet.id
}