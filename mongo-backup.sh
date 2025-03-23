#!/bin/bash
export AWS_DEFAULT_REGION=ap-southeast-1

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_${TIMESTAMP}"
BUCKET_NAME="eks-db-stack-public-mongodb-backups"
LOG_FILE="/home/ubuntu/mongo-backup.log"

# Retrieve MongoDB credentials from Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${SECRET_ARN} --query SecretString --output text)
DB_USERNAME=$(echo $SECRET_JSON | jq -r .username)
DB_PASSWORD=$(echo $SECRET_JSON | jq -r .password)

# Perform MongoDB backup
echo "$(date): Backup started" >> "$LOG_FILE"
mongodump --uri="mongodb://${DB_USERNAME}:${DB_PASSWORD}@localhost:27017" --archive="$BACKUP_NAME.gz" --gzip

# Upload to S3
aws s3 cp "$BACKUP_NAME.gz" "s3://$BUCKET_NAME/"
echo "$(date): Backup completed" >> "$LOG_FILE"

# Clean up local backup
rm "$BACKUP_NAME.gz"