#!/bin/bash

function wait_for_mysql() {
    local container=$1

    while ! docker exec "$container" mysql -uroot -proot -e 'SELECT 1' > /dev/null 2>&1; do
        sleep 2
    done
}

function configure_follower() {
    local follower=$1
    local log_file=$2
    local log_position=$3

    echo "CHANGE MASTER TO MASTER_HOST='mysql-leader', MASTER_USER='repl', MASTER_PASSWORD='repl-password', MASTER_LOG_FILE='$log_file', MASTER_LOG_POS=$log_position; START SLAVE;" > ./$follower/$follower-setup.sql
}

# Start leader
docker-compose up -d mysql-leader
wait_for_mysql mysql-leader

# Get binlog file and position
MASTER_STATUS=$(docker exec mysql-leader mysql -uroot -proot -e "SHOW MASTER STATUS\G")
LOG_POSITION=$(echo "$MASTER_STATUS" | grep 'Position' | awk '{print $2}')
LOG_FILE=$(echo "$MASTER_STATUS" | grep 'File' | awk '{print $2}')

# Update or create SQL files for the followers
configure_follower "follower-1" "$LOG_FILE" "$LOG_POSITION"
configure_follower "follower-2" "$LOG_FILE" "$LOG_POSITION"

# Manually start the followers
docker-compose up -d mysql-follower-1
docker-compose up -d mysql-follower-2

wait_for_mysql mysql-follower-1
wait_for_mysql mysql-follower-2
