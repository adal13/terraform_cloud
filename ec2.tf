# ami-0c20d88b0021158c6
# Utilizando el foreach sin toset(var.instances)
# variable "instancias" {
#   description = "Nombre de las instancias"
#   type        = set(string)
#   default     = ["mysql", "jumpserver"]

# }

#Utilizando tu set para que el foreach haga un map
variable "instancias" {
  description = "Nombre de las instancias"
  type        = list(string)
  default     = ["apache"]

}

# Despliegue de instancias
resource "aws_instance" "public_instance" {
  # for_each               = var.instancias
  for_each               = toset(var.instancias)
  ami                    = var.ec2_specs.ami
  instance_type          = var.ec2_specs.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  user_data              = file("scripts/userdata.sh")

  tags = {
    "Name" = "${each.value}-${local.sufix}"
  }
}

resource "aws_instance" "monitoring_instance" {
  # Estructura condicional
  count = var.enable_monitoring == 1 ? 1 : 0

  ami                    = var.ec2_specs.ami
  instance_type          = var.ec2_specs.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  user_data              = file("scripts/userdata.sh")

  tags = {
    "Name" = "Monitoreo-${local.sufix}"
  }
}
