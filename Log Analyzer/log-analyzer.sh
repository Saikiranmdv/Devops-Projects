if [ -z "$1" ]; then
 echo "Usage: $0 <log_directory>"
 exit 1
fi

LOG_DIR="$1"
ARCHIVE_DIR="$HOME/log_archives"

if [ ! -d "$LOG_DIR" ]; then 
    echo "Error: Directory $LOG_DIR not found"
    exit 1
fi 

mkdir -p "$ARCHIVE_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" .

if [ $? -eq 0 ]; then 
    echo "Logs Archived successfully : $ARCHIVE_PATH"
    echo "$TIMESTAMP archived $LOG_DIR -> $ARCHIVE_NAME" >> "$ARCHIVE_DIR/archive.log"
else 
    echo "Failed to Archive the logs"
exit 1
fi