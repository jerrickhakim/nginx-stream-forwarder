#!/bin/bash

# NGINX Stream Forwarder - Set Secrets Script
# This script sets fly.io secrets based on environment variables or .env file

set -e  # Exit on any error

echo "🔐 Setting up fly.io secrets for NGINX Stream Forwarder..."

# Load .env file if it exists
if [ -f ".env" ]; then
    echo "📄 Loading environment variables from .env file..."
    set -a  # Automatically export all variables
    source .env
    set +a  # Turn off automatic export
else
    echo "ℹ️  No .env file found, using system environment variables..."
fi

# Function to set secret if environment variable exists
set_secret_if_exists() {
    local env_var="$1"
    local secret_name="$2"
    local value="${!env_var}"
    
    if [ -n "$value" ]; then
        echo "✅ Setting $secret_name..."
        fly secrets set "$secret_name=$value"
    else
        echo "⚠️  $env_var not set, skipping $secret_name"
    fi
}

# Check if flyctl is installed
if ! command -v fly &> /dev/null; then
    echo "❌ flyctl is not installed. Please install it first:"
    echo "   curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if user is logged in
if ! fly auth whoami &> /dev/null; then
    echo "❌ Not logged in to fly.io. Please run: fly auth login"
    exit 1
fi

echo ""
echo "Setting streaming platform secrets..."

# Set secrets based on environment variables
set_secret_if_exists "YOUTUBE_STREAM_KEY" "YOUTUBE_STREAM_KEY"
set_secret_if_exists "TWITCH_STREAM_KEY" "TWITCH_STREAM_KEY"
set_secret_if_exists "X_STREAM_KEY" "X_STREAM_KEY"

# Set the authentication stream key
set_secret_if_exists "APP_STREAM_KEY" "APP_STREAM_KEY"
set_secret_if_exists "STREAM_KEY" "STREAM_KEY"

echo ""
echo "✅ Secret configuration complete!"
echo ""
echo "📋 To use this script:"
echo "   Option 1 - Use .env file (recommended):"
echo "      1. Create a .env file with your keys:"
echo "         YOUTUBE_STREAM_KEY=your-youtube-key"
echo "         TWITCH_STREAM_KEY=your-twitch-key"
echo "         STREAM_KEY=your-auth-key"
echo "      2. Run this script: ./set-secrets.sh"
echo ""
echo "   Option 2 - Use environment variables:"
echo "      1. Set environment variables:"
echo "         export YOUTUBE_STREAM_KEY='your-youtube-key'"
echo "         export STREAM_KEY='your-auth-key'"
echo "      2. Run this script: ./set-secrets.sh"
echo ""
echo "🔍 View current secrets: fly secrets list" 