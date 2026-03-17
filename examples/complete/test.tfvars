logical_product_family  = "lp"
logical_product_service = "lps"
class_env               = "dev"
instance_env            = 1
instance_resource       = 1

resource_names_map = {
  sqsqueue = {
    name       = "sqsqueue1"
    max_length = 80
  }
  iamrole = {
    name       = "iamrole1"
    max_length = 64
  }
  sched = {
    name       = "sched1"
    max_length = 80
  }
}
