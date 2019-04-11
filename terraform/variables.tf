variable "cen_id" {
  description = "The ID of your Cloud Enterprise Netork (CEN) instance."
}

variable "cen-scaler-policy" {
  value = "cen-scaler-policy"
}

variable "cen-scaler-role" {
  value = "cen-scaler-role"
}

variable "service_name" {
  default     = "CENScalerService"
}

variable "service_description" {
  default     = "Created by CEN-Scaler"
}

variable "function_name" {
  default     = "scale"
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

variable "trigger_name" {
  description = "The name of the time-based trigger"
  default = "timetrigger"
}