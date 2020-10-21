# Create a vpc
resource "aws_vpc" "aws_vpc" {
  // Range of IPv4 addresses for the VPC in the form of a Classless Inter-Domain Routing (CIDR) block
  // In this case, it means that your VPC will have 2 ^ 16 (65536) IPs addresses
  // 10.0.0.0 = 00001010.00000000.00000000.00000000
  // 16 bits for the network address and 16 bits for hosts addresses
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "vpc_internet_gateway" {
  vpc_id = "${aws_vpc.aws_vpc.id}"

  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

// Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.aws_vpc.id}"

  // CIDR block for the subnet, which is a subset of the VPC CIDR block
  // In this case, it means that your subnet will have 2 ^ 8 (256) IPs addresses
  // 10.0.1.0 = 00001010.00000000.00000001.00000000
  // 24 bits for the network address and 8 bits for hosts addresses
  cidr_block = "10.0.1.0/24"

  // Each subnet must reside entirely within one Availability Zone and cannot span zones. 
  availability_zone = "${data.aws_availability_zones.aws_az.names[0]}"

  // Indicate if instances launched into the subnet should be assigned a public IP address. 
  // In this case, only the first subnet will have public IPs assigned 
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet}"
    Environment = "${var.environment}"
  }
}

// Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.aws_vpc.id}"

  // CIDR block for the subnet, which is a subset of the VPC CIDR block
  // In this case, it means that your subnet will have 2 ^ 8 (256) IPs addresses
  // 10.0.1.0 = 00001010.00000000.00000001.00000000
  // 24 bits for the network address and 8 bits for hosts addresses
  cidr_block = "10.0.2.0/24"

  // Each subnet must reside entirely within one Availability Zone and cannot span zones. 
  availability_zone = "${data.aws_availability_zones.aws_az.names[1]}"

  tags = {
    Name        = "${var.environment}-private-subnet"
    Environment = "${var.environment}"
  }
}

# create a route table for the public subnet
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = "${aws_vpc.aws_vpc.id}"

  // Maps internet traffic to the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc_internet_gateway.id}"
  }

  tags = {
    Name        = "${var.environment}-public-subnet-route-table"
    Environment = "${var.environment}"
  }
}

# create a route table for the private subnet
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = "${aws_vpc.aws_vpc.id}"

  tags = {
    Name        = "${var.environment}-private-subnet-route-table"
    Environment = "${var.environment}"
  }
}

// Associate the public subnet to its route table
resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_subnet_route_table.id}"
}

// Associate the private subnet to its route table
resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_subnet_route_table.id}"
}
