variable "shared_secret" {
  description = "The shared secret between CMS and your HTTP-triggered Function Compute."
  default = "changethisvalue"
}

variable "scale_strategy_area_up_china_europe" {
  description = "Bandwidth in MBit/s to scale up CEN in case alarm is triggered."
  default = 1
}

variable "scale_strategy_area_down_china_europe" {
  description = "Bandwidth in MBit/s to scale down CEN in case alarm is triggered."
  default = -1
}

variable "scale_strategy_region_up_eu-central-1_cn-hangzhou" {
  description = "Bandwidth in MBit/s to scale up regional bandwidth in case alarm is triggered."
  default = 1
}

variable "scale_strategy_region_down_eu-central-1_cn-hangzhou" {
  description = "Bandwidth in MBit/s to scale down regional bandwidth in case alarm is triggered."
  default = -1
}

variable "fc_version" {
  default = "2016-08-15"
}

variable "cen_id" {
  description = "The ID of your Cloud Enterprise Netork (CEN) instance."
  default = "thisdoesnotexist"
}

variable "cen-scaler-policy" {
  default = "cen-scaler-policy"
}

variable "cen-scaler-role" {
  default = "cen-scaler-role"
}

variable "service_name" {
  default     = "CENScalerServiceMetric"
}

variable "service_description" {
  default     = "Created by CEN-Scaler"
}

variable "function_name" {
  default     = "scale-metric"
}

variable "function_description" {
  default     = "Created by CEN-Scaler"
}

variable "function_zip" {
  description = "The path to the function's deployment package within the local filesystem. It is conflict with the oss_-prefixed options.."
  default     = "fc.zip"
}

variable "function_memory_size" {
  description = "Amount of memory in MB your Function can use at runtime. Defaults to 128. Limits to [128, 3072]."
  default     = "128"
}

variable "function_runtime" {
  description = "The Function Compute function runtime type."
  default     = "nodejs8"
}

variable "function_handler" {
  description = "The function entry point in your code."
  default     = "index.handler"
}