/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the subnet is created."
}

variable "use_existing_subnet" {
  default = false
}

variable "existing_subnet_id" {
  default = ""
}

variable "vcn_id" {}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
}

variable "cidr_block" {}

variable "dhcp_options_id" {}

variable "route_table_id" {}

variable "create_private_subnet" {
  default = false
}
