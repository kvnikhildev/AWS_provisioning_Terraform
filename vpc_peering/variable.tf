variable "ami" {
  description = "ami id of server 1"
  type        = string

}
variable "key_name" {
  description = "security key"
  type        = string

}

variable "instance_type" {
  description = "type of server"
  type        = string

}
variable "peer_owner_id" {
  description = "owner id of the account"
  type = number
  
}


