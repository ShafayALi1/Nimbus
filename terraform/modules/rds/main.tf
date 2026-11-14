# PostgreSQL in private subnets. Only the VPC can reach it; it is never public.
resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "db" {
  name   = "${var.name}-db"
  vpc_id = var.vpc_id
  ingress {
    description = "PostgreSQL from inside the VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.instance_class
  allocated_storage       = 20
  storage_encrypted       = true
  db_name                 = "nimbus"
  username                = "nimbus"
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  multi_az                = var.multi_az # standby in the second AZ; doubles the cost
  backup_retention_period = 1
  skip_final_snapshot     = true # lab setting
  deletion_protection     = false
}
