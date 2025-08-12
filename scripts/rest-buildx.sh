#!/bin/bash

set -e

# 🧼 Fix Docker Desktop environment issues
if [[ -n "$DOCKER_HOST" ]]; then
  echo "⚠️ DOCKER_HOST is set to '$DOCKER_HOST' — unsetting it to avoid buildx problems..."
  unset DOCKER_HOST
fi

echo "🔄 Cleaning up all existing Buildx builders..."

# Get builder names and remove them
builder_names=$(docker buildx ls | awk 'NR>1 {print $1}' | sort -u | grep -v '^$')

if [ -n "$builder_names" ]; then
  for builder in $builder_names; do
    echo "🗑 Removing builder: $builder"
    docker buildx rm "$builder" || echo "⚠️ Skipping: builder '$builder' not found or already removed."
  done
else
  echo "✅ No existing builders found."
fi

echo ""
echo "🛠 Creating new builder: mybuilder"
docker buildx create --use --name mybuilder --driver docker-container

echo ""
echo "🚀 Bootstrapping builder..."
docker buildx inspect --bootstrap

echo ""
echo "✅ Done. Current builders:"
docker buildx ls

