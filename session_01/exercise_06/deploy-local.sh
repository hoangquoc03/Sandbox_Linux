
#!/bin/bash

set -e

# ==========================
# ANSI COLORS
# ==========================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==========================
# CONFIG
# ==========================

PROJECT_DIR="$HOME/user-service"
BUILD_DIR="$PROJECT_DIR/build/libs"
JAR_NAME="user-service-0.0.1.jar"

APP_DIR="/opt/quickbite"
SERVICE_DIR="$APP_DIR/user-service"
TARGET_JAR="$SERVICE_DIR/user-service-0.0.1.jar"
LOG_FILE="$SERVICE_DIR/app.log"

echo -e "${BLUE}==============================${NC}"
echo -e "${BLUE} QuickBite Local Deployment${NC}"
echo -e "${BLUE}==============================${NC}"

# ===================================================
# STEP 1 - BUILD & TEST (FAIL FAST)
# ===================================================

echo -e "${YELLOW}[STEP 1] Building project...${NC}"

cd "$PROJECT_DIR"

if ./gradlew clean bootJar; then
    echo -e "${GREEN}Build successful.${NC}"
else
    echo -e "${RED}Build failed! Deployment stopped.${NC}"
    exit 1
fi

# ===================================================
# STEP 2 - PREPARE DIRECTORY
# ===================================================

echo -e "${YELLOW}[STEP 2] Preparing deployment directory...${NC}"

sudo mkdir -p "$SERVICE_DIR"

sudo chown -R quickbite:quickbite "$APP_DIR"

sudo chmod 750 "$APP_DIR"

echo -e "${GREEN}Directory ready.${NC}"

# ===================================================
# STEP 3 - STOP OLD SERVICE & COPY NEW JAR
# ===================================================

echo -e "${YELLOW}[STEP 3] Stopping old service...${NC}"

PID=$(sudo ss -tulpn | grep ':8080' | grep -o 'pid=[0-9]*' | cut -d= -f2 || true)

if [ ! -z "$PID" ]; then
    echo "Stopping PID $PID"
    sudo kill -9 "$PID"
    sleep 2
fi

echo "Copying new JAR..."

sudo cp "$BUILD_DIR/$JAR_NAME" "$TARGET_JAR"

sudo chown quickbite:quickbite "$TARGET_JAR"

echo -e "${GREEN}Application copied.${NC}"

# ===================================================
# STEP 4 - START SERVICE
# ===================================================

echo -e "${YELLOW}[STEP 4] Starting service...${NC}"

sudo -u quickbite nohup java -jar "$TARGET_JAR" > "$LOG_FILE" 2>&1 &

echo -e "${GREEN}Service started.${NC}"

# ===================================================
# STEP 5 - SMOKE TEST
# ===================================================

echo -e "${YELLOW}[STEP 5] Smoke testing...${NC}"

sleep 5

if sudo ss -tulpn | grep -q ':8080'; then
    echo -e "${GREEN}"
    echo "======================================="
    echo " DEPLOY DỊCH VỤ THÀNH CÔNG!"
    echo " Port 8080 đang lắng nghe."
    echo "======================================="
    echo -e "${NC}"
else
    echo -e "${RED}"
    echo "======================================="
    echo " DEPLOY THẤT BẠI!"
    echo " Port 8080 chưa mở."
    echo "======================================="
    echo -e "${NC}"

    echo "30 dòng log cuối:"

    sudo tail -n 30 "$LOG_FILE" || echo "Không tìm thấy log."

    exit 1
fi
