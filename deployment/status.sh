#!/bin/bash
cd /opt/finders-keepers
echo "📊 Finders Keepers Server Status:"
echo "=================================="
docker-compose ps
echo ""
echo "📋 Container logs (last 20 lines):"
echo "=================================="
docker-compose logs --tail=20
