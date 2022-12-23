#####
# Variables for administrative connection to the ADC
#####

variable adc-base{
}
#####
# Variables for configuring the private key
#####

variable private_key_algorithm_letsencrypt {
}

variable private_key_ecdsa_curve_letsencrypt {
}

variable private_key_rsa_bits_letsencrypt {
}

#####
# Variables for the LetsEncrypt registration
#####

variable le_registration_email_address {
}

#####
# Variables for configuring the certificate
#####

variable le_certificate_common_name {
}

variable le_certificate_subject_alternative_names {
}

variable le_certificate_subject_alternative_name {
}


#####
# Variables for certificate file upload
#####

variable le_upload_cert_filelocation {
}

variable le_issuer_name {
}

#####
# Variable for certificate installation on ADC
#####

variable le_certkey_name {
}