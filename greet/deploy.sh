#!/bin/bash
set -e
cd /root/jenkins-test

if [ -f /root/jenkins-test/demo-app.pid ]; then
    OLD_PID=$(cat /root/jenkins-test/demo-app.pid)
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Stopping old process PID=$OLD_PID"
        kill "$OLD_PID"
        sleep 2
        kill -9 "$OLD_PID" 2>/dev/null || true
    fi
    rm -f /root/jenkins-test/demo-app.pid
fi

pkill -f "/root/jenkins-test/demo-app" 2>/dev/null || true

chmod +x demo-app

nohup /root/jenkins-test/demo-app > /root/jenkins-test/demo-app.log 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > /root/jenkins-test/demo-app.pid

sleep 2
if kill -0 "$NEW_PID" 2>/dev/null; then
    echo "✅ Started new process PID=$NEW_PID"
else
    echo "❌ Process died immediately, dumping logs:"
    tail -n 50 /root/jenkins-test/demo-app.log
    exit 1
fi