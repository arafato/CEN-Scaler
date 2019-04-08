######  ######## ##    ##     ######   ######     ###    ##       ######## ########  
##    ## ##       ###   ##    ##    ## ##    ##   ## ##   ##       ##       ##     ## 
##       ##       ####  ##    ##       ##        ##   ##  ##       ##       ##     ## 
##       ######   ## ## ##     ######  ##       ##     ## ##       ######   ########  
##       ##       ##  ####          ## ##       ######### ##       ##       ##   ##   
##    ## ##       ##   ###    ##    ## ##    ## ##     ## ##       ##       ##    ##  
 ######  ######## ##    ##     ######   ######  ##     ## ######## ######## ##     ##

######################################################
## RAM Setup
resource "alicloud_ram_role" "role" {
  name = "${var.cen-scaler-role}"

  services = [
    "fc.aliyuncs.com",
  ]

  description = "Service Role for FC to access CEN APIs"
  force       = true
}

resource "alicloud_ram_policy" "policy" {
  name = "${var.cen-scaler-policy}"

  statement = [
    {
      effect = "Allow"

      action = [
        "cen:ModifyCenBandwidthPackageSpec",
        "cen:SetCenInterRegionBandwidthLimit",
      ]

      resource = [
        "acs:cen:::${var.cen_id}",
      ]
    },
  ]

  description = "Policy for CEN Scaler service role."
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "attach" {
  policy_name = "${alicloud_ram_policy.policy.name}"
  role_name   = "${alicloud_ram_role.role.name}"
  policy_type = "${alicloud_ram_policy.policy.type}"
}

######################################################
## Function Compute
data "archive_file" "fc_zip" {
  type        = "zip"
  source_dir = "${path.cwd}/../src/"
  output_path = "${path.cwd}/fc.zip"
}

resource "alicloud_fc_service" "censcalerservice" {
  name            = "${var.service_name}"
  description     = "${var.service_description}"
  internet_access = "false"
}

resource "alicloud_fc_function" "foo" {
  service     = "${alicloud_fc_service.censcalerservice.name}"
  name        = "${var.function_name}"
  description = "${var.function_description}"
  filename    = "${var.function_filename}"
  memory_size = "${var.function_memory_size}"
  runtime     = "${var.function_runtime}"
  handler     = "${var.function_handler}"
}