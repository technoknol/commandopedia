# 1. Remove the broken script
```
rm get-ssm-frankfurt.sh
```

# 2. Recreate it with PROPER Unix line endings using 'cat << EOF'
```
cat > get-ssm-frankfurt.sh << 'EOF'
#!/bin/bash
# Export ALL SSM Parameters to TXT (Frankfurt only) – CloudShell safe

OUTPUT_FILE="ssm-parameters-export-$(date +%Y%m%d-%H%M%S).txt"
REGION="eu-central-1"

echo "Exporting SSM parameters from region: $REGION"
echo "Output file: $OUTPUT_FILE"
echo "---------------------------------------------------------------" | tee "$OUTPUT_FILE"

TOTAL=0
NEXT_TOKEN=""

while :; do
    if [ -n "$NEXT_TOKEN" ] && [ "$NEXT_TOKEN" != "null" ]; then
        RESULT=$(aws ssm get-parameters-by-path \
            --path / --recursive --with-decryption \
            --region "$REGION" \
            --next-token "$NEXT_TOKEN" \
            --query 'Parameters[*].[Name,Type,Value,Description]' \
            --output json 2>/dev/null)
    else
        RESULT=$(aws ssm get-parameters-by-path \
            --path / --recursive --with-decryption \
            --region "$REGION" \
            --query 'Parameters[*].[Name,Type,Value,Description]' \
            --output json 2>/dev/null)
    fi

    # Check for API errors
    if [ $? -ne 0 ] || [ -z "$RESULT" ] || [ "$RESULT" = "null" ] || [ "$RESULT" = "[]" ]; then
        [ "$RESULT" != "[]" ] && echo "API Error or empty response. Stopping." >&2
        break
    fi

    # Write parameters cleanly
    echo "$RESULT" | jq -r '.[] |
        "Name: " + .[0] + "\n" +
        "Type: " + .[1] + "\n" +
        "Value: " + .[2] + "\n" +
        "Description: " + (.[3] // "N/A") + "\n" +
        "---"' >> "$OUTPUT_FILE"

    COUNT=$(echo "$RESULT" | jq '. | length')
    TOTAL=$((TOTAL + COUNT))

    # Get next page
    NEXT_TOKEN=$(aws ssm get-parameters-by-path \
        --path / --recursive --with-decryption \
        --region "$REGION" \
        --query 'NextToken' --output text 2>/dev/null)

    [ -z "$NEXT_TOKEN" ] || [ "$NEXT_TOKEN" = "null" ] && break
    echo "Fetched $TOTAL parameters so far... continuing"
done

echo "---------------------------------------------------------------" >> "$OUTPUT_FILE"
echo "TOTAL PARAMETERS EXPORTED: $TOTAL" | tee -a "$OUTPUT_FILE"
echo "Export complete: $OUTPUT_FILE"
EOF

```

# 3. Make executable
```
chmod +x get-ssm-frankfurt.sh
```

# 4. Run
```
./get-ssm-frankfurt.sh
```

# 5. Upload to S3. 

Step 1: Choose Your S3 Bucket (Create if needed)
```
S3_BUCKET="my-ssm-backups-frankfurt"
```

```
S3_BUCKET="my-ssm-backups-frankfurt" && \
LATEST=$(ls -t ssm-parameters-export-*.txt | head -1) && \
aws s3 cp "$LATEST" s3://$S3_BUCKET/ssm-backups/ && \
echo "Uploaded: s3://$$ S3_BUCKET/ssm-backups/ $$(basename $LATEST)"
```
