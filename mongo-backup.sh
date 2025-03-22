#!/bin/bash
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_\$TIMESTAMP"
BUCKET_NAME="eks-db-stack-public-mongodb-backups"

# Perform MongoDB backup
mongodump --archive=\$BACKUP_NAME.gz --gzip

# Upload to S3
aws s3 cp \$BACKUP_NAME.gz s3://\$BUCKET_NAME/

# Clean up local backup
rm \$BACKUP_NAME.gz