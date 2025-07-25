#!/bin/bash
echo "🔄 Updating Finders Keepers Server..."
cd /opt/finders-keepers
docker-compose pull
docker-compose up -d
echo "✅ Server updated to latest version!"
