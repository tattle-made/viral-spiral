#!/bin/bash
set -e

echo "Creating S3 bucket: viral-spiral-cards"
awslocal s3 mb s3://viral-spiral-cards
awslocal s3api put-bucket-acl --bucket viral-spiral-cards --acl public-read
echo "Bucket ready."
