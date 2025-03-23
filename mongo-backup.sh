#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
export AWS_DEFAULT_REGION=ap-southeast-1

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_${TIMESTAMP}"
BUCKET_NAME="eks-db-stack-public-mongodb-backups"
LOG_FILE="/home/ubuntu/mongo-backup.log"

# Function to log messages
log_message() {
    echo "$(date): $1" | tee -a "$LOG_FILE"
}

# Retrieve MongoDB credentials from Secrets Manager
log_message "Retrieving MongoDB credentials"
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${SECRET_ARN} --query SecretString --output text)
DB_USERNAME=$(echo $SECRET_JSON | jq -r .username)
DB_PASSWORD=$(echo $SECRET_JSON | jq -r .password)

# Perform MongoDB backup
log_message "Starting MongoDB backup"
mongodump --uri="mongodb://${DB_USERNAME}:${DB_PASSWORD}@localhost:27017" --archive="$BACKUP_NAME.gz" --gzip 2>&1 | tee -a "$LOG_FILE"

# Upload to S3
log_message "Uploading backup to S3"
aws s3 cp "$BACKUP_NAME.gz" "s3://$BUCKET_NAME/" 2>&1 | tee -a "$LOG_FILE"

# Verify the upload
log_message "Verifying S3 upload"
if aws s3 ls "s3://$BUCKET_NAME/$BACKUP_NAME.gz" > /dev/null 2>&1; then
    log_message "Backup successfully uploaded to S3"
else
    log_message "ERROR: Backup upload to S3 failed"
    exit 1
fi

# Clean up local backup
log_message "Cleaning up local backup file"
rm "$BACKUP_NAME.gz"

log_message "Backup process completed successfully"

# Output the log content
echo "Backup Log:"
cat "$LOG_FILE"