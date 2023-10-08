#!/bin/bash

docker compose down --remove-orphans --volumes

docker volume rm leader-follower_mysql-follower-1
docker volume rm leader-follower_mysql-follower-2

cat /dev/null > ./follower-1/follower-1-setup.sql
cat /dev/null > ./follower-2/follower-2-setup.sql
