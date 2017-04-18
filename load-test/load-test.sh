#!/bin/bash

echo "Cleaning out the database"
cd /mattermost
./bin/platform reset --confirm

echo "Configuring system admin account needed for load test"
cd /mattermost
./bin/platform user create --email test@test.com --username loadtest_admin --password passwd --system_admin

echo "Running load test setup command"
cd /mattermost-load-test
echo '{"Users":[], "Teams":[], "Channels":[] }' >> state.json
cat state.json | mcreate users -n 20 | mcreate teams -n 1 | mcreate channels -n 10 | mmanage login | mmanage jointeam | mmanage joinchannel -n 2 > state.json
cat state.json | loadtest listenandpost