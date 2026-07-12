#!/bin/bash

set -e

apt-get update -y

apt-get install -y apache2 unzip curl

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

# Download website from S3
aws s3 cp s3://musthaqecluaseterraform/Server2/ /var/www/html/ --recursive

systemctl enable apache2
systemctl restart apache2