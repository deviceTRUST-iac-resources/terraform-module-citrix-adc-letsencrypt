terraform {
  required_version = ">= 1.0.0"
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
      version = ">= 1.31.0"
    }
    acme = {
      source = "vancluever/acme"
      version = ">= 2.10.0"
    }
  }
}