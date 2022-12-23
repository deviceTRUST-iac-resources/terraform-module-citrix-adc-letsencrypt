#####
# Create Private Key
#####

resource "tls_private_key" "le_private_key" {
  algorithm   = var.private_key_algorithm_letsencrypt
  ecdsa_curve = var.private_key_ecdsa_curve_letsencrypt
  rsa_bits    = var.private_key_rsa_bits_letsencrypt
}

#####
# Register with ACME
#####

resource "acme_registration" "le_registration" {
  account_key_pem = tls_private_key.le_private_key.private_key_pem
  email_address   = var.le_registration_email_address

  depends_on = [
    tls_private_key.le_private_key
  ]
}

#####
# Create Certificate
#####

resource "acme_certificate" "le_certificate" {
  account_key_pem           = acme_registration.le_registration.account_key_pem
  common_name               = var.le_certificate_common_name
  subject_alternative_names = var.le_certificate_subject_alternative_names

  http_challenge {
  }

  depends_on = [
    acme_registration.le_registration
  ]
}

#####
# Upload files to /ssl at ADC
#####

resource "citrixadc_systemfile" "le_upload_cert" {
  filename = "democloud_certificate.cer"
  filelocation = var.le_upload_cert_filelocation
  filecontent = lookup(acme_certificate.le_certificate,"certificate_pem")

  depends_on = [
    acme_certificate.le_certificate
  ]
}

resource "citrixadc_systemfile" "le_upload_key" {
  filename = "democloud_privatekey.cer"
  filelocation = var.le_upload_cert_filelocation
  filecontent = nonsensitive(lookup(acme_certificate.le_certificate,"private_key_pem"))

  depends_on = [
    acme_certificate.le_certificate
  ]
}

resource "citrixadc_systemfile" "le_upload_root" {
  filename = var.le_issuer_name
  filelocation = var.le_upload_cert_filelocation
  filecontent = lookup(acme_certificate.le_certificate,"issuer_pem")

  depends_on = [
    acme_certificate.le_certificate
  ]
}


#####
# Implement root certificate
#####

resource "citrixadc_sslcertkey" "le_implement_rootca" {
  certkey = var.le_issuer_name
  cert = "/nsconfig/ssl/LE_RootCA"
  expirymonitor = "DISABLED"

depends_on = [
    citrixadc_systemfile.le_upload_cert,
    citrixadc_systemfile.le_upload_key
  ]
}

#####
# Implement server certificate
#####

resource "citrixadc_sslcertkey" "le_implement_certkeypair" {
  certkey = var.le_certkey_name
  cert = "/nsconfig/ssl/democloud_certificate.cer"
  key = "/nsconfig/ssl/democloud_privatekey.cer"
  expirymonitor = "DISABLED"
  linkcertkeyname = "LE_RootCA"

  depends_on = [
    citrixadc_sslcertkey.le_implement_rootca
  ]
}

#####
# Save config
#####

resource "citrixadc_nsconfig_save" "le_save" {  
    all        = true
    timestamp  = timestamp()

    depends_on = [
        citrixadc_sslcertkey.le_implement_certkeypair,
        citrixadc_sslcertkey.le_implement_rootca
    ]
}