######  ######## ##    ##     ######   ######     ###    ##       ######## ########  
##    ## ##       ###   ##    ##    ## ##    ##   ## ##   ##       ##       ##     ## 
##       ##       ####  ##    ##       ##        ##   ##  ##       ##       ##     ## 
##       ######   ## ## ##     ######  ##       ##     ## ##       ######   ########  
##       ##       ##  ####          ## ##       ######### ##       ##       ##   ##   
##    ## ##       ##   ###    ##    ## ##    ## ##     ## ##       ##       ##    ##  
 ######  ######## ##    ##     ######   ######  ##     ## ######## ######## ##     ##


# TODO: Add detailed explanation on how to configure a timing event
resource "alicloud_fc_trigger" "triggerscale_1" {
  service = "${alicloud_fc_service.censcalerservice.name}"
  function = "${alicloud_fc_function.scale.name}"
  name = "${var.trigger_name}"
  type = "timer"
  config = <<EOF
    {
      "cronExpression": "0 0 6 ? * MON",
      "enable": true,
      "payload": {
        "cenBandwidth": 20,
        "regionConnections": [
          {
            "sourceRegion": "eu-central-1",
            "targetRegion": "cn-bejing",
            "bandwidth": 10
          },
          {
            "sourceRegion": "eu-central-1",
            "targetRegion": "cn-shanghai",
            "bandwidth": 10
          }
        ] 
      }
    }
EOF
}

resource "alicloud_fc_trigger" "triggerscale_2" {
  service = "${alicloud_fc_service.censcalerservice.name}"
  function = "${alicloud_fc_function.scale.name}"
  name = "${var.trigger_name}"
  type = "timer"
  config = <<EOF
    {
      "cronExpression": "0 0 6 ? * SAT",
      "enable": true,
      "payload": {
        "cenBandwidth": 10,
        "regionConnections": [
          {
            "sourceRegion": "eu-central-1",
            "targetRegion": "cn-bejing",
            "bandwidth": 5
          },
          {
            "sourceRegion": "eu-central-1",
            "targetRegion": "cn-shanghai",
            "bandwidth": 5
          }
        ] 
      }
    }
EOF
}

#############################################################
## DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU ARE DOING! ##
#############################################################

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
  output_path = "${path.cwd}/${var.function_zip}"
}

resource "alicloud_fc_service" "censcalerservice" {
  name            = "${var.service_name}"
  description     = "${var.service_description}"
  internet_access = "false"
  role            = "${alicloud_ram_role.role.arn}"
}

resource "alicloud_fc_function" "scale" {
  service     = "${alicloud_fc_service.censcalerservice.name}"
  name        = "${var.function_name}"
  description = "${var.function_description}"
  filename    = "./${var.function_zip}"
  memory_size = "${var.function_memory_size}"
  runtime     = "${var.function_runtime}"
  handler     = "${var.function_handler}"
  environment_variables {
    CEN_ID = "${var.cen_id}"
  }
}