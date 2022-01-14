variable "sg_list" {
  description = "List of Security groups"
  type = list(string)
}

variable "ssh_key" {
  type = string
}
