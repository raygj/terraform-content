policy "enforce-mandatory-tags" {
    enforcement_level = "soft-mandatory"
}
policy "restrict-ec2-instance-type" {
    enforcement_level = "soft-mandatory"
}

module "tfplan-functions" {
    source = "./common-functions/tfplan-functions/tfplan-functions.sentinel"
}
