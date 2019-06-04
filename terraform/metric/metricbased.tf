######  ######## ##    ##     ######   ######     ###    ##       ######## ########  
##    ## ##       ###   ##    ##    ## ##    ##   ## ##   ##       ##       ##     ## 
##       ##       ####  ##    ##       ##        ##   ##  ##       ##       ##     ## 
##       ######   ## ## ##     ######  ##       ##     ## ##       ######   ########  
##       ##       ##  ####          ## ##       ######### ##       ##       ##   ##   
##    ## ##       ##   ###    ##    ## ##    ## ##     ## ##       ##       ##    ##  
 ######  ######## ##    ##     ######   ######  ##     ## ######## ######## ##     ##


# ADAPT TO YOUR NEEDS AND REQUIREMENTS
# See https://github.com/arafato/CEN-Scaler#example for explanation of this example event trigger configuration.

locals {
  webhook = "https://${data.alicloud_account.current.id}.${data.alicloud_regions.current_region.regions.0.id}.fc.aliyuncs.com/${var.fc_version}/proxy/${var.service_name}/${var.function_name}/?ss=${var.shared_secret}"
	env = {
		CEN_ID = "${var.cen_id}"
		scale_strategy_censcaler_region_up = <<EOF
		{
			"sourceRegion": "cn-beijing",
			"targetRegion": "eu-central-1",
			"step": 1
		}
	EOF
		scale_strategy_censcaler_region_down = <<EOF
		{
			"sourceRegion": "cn-beijing",
			"targetRegion": "eu-central-1",
			"step": -1
		}
	EOF
	}
}

  resource "alicloud_cms_alarm" "region_up_eu-central-1_cn-hangzhou" {
	  name = "censcaler_region_up"
	  project = "acs_cen"
	  metric = "InternetOutRatePercentByConnectionRegion"
	  dimensions = {
	    CenId = "${var.cen_id}"
      geographicSpanId = "china_europe"
      localRegionId = "cn-hangzhou"
      oppositeRegionId = "eu-central-1"
	  }
	  statistics ="Average"
	  period = 60
	  operator = ">"
	  threshold = 90
	  triggered_count = 2
	  contact_groups = ["%s"]
	  end_time = 23
	  start_time = 0
	  notify_type = 1
    webhook = "${local.webhook}"
	}

resource "alicloud_cms_alarm" "region_down_eu-central-1_cn-hangzhou" {
	  name = "censcaler_region_down"
	  project = "acs_cen"
	  metric = "InternetOutRatePercentByConnectionRegion"
	  dimensions = {
	    CenId = "${var.cen_id}"
      geographicSpanId = "china_europe"
      localRegionId = "cn-hangzhou"
      oppositeRegionId = "eu-central-1"
	  }
	  statistics ="Average"
	  period = 60
	  operator = "<="
	  threshold = 60
	  triggered_count = 3
	  contact_groups = ["%s"]
	  end_time = 23
	  start_time = 0
	  notify_type = 1
    webhook = "${local.webhook}"
	}

#############################################################
## DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU ARE DOING! ##
#############################################################

data "alicloud_regions" "current_region" {
  current = true
}

data "alicloud_account" "current" {
}

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
  source_dir = "${path.cwd}/../../src/metric/"
  output_path = "${path.cwd}/${var.function_zip}"
}

resource "alicloud_fc_service" "censcalerservice" {
  name            = "${var.service_name}"
  description     = "${var.service_description}"
  internet_access = "true"
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
  environment_variables = "${local.env}"
}