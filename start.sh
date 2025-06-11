#!/bin/bash
set -e

# Generate nginx.conf dynamically with conditional RTMP push lines and exec commands
cat > /etc/nginx/nginx.conf <<EOF
events {}

rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        allow publish all;

        application live {
            live on;
            record off;
            on_publish http://localhost:8080/auth;
EOF



# Add push commands for services that support RTMP directly
if [[ -n "$YOUTUBE_STREAM_KEY" ]]; then
  echo "            push rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY;" >> /etc/nginx/nginx.conf
fi

if [[ -n "$TWITCH_STREAM_KEY" ]]; then
  echo "            push rtmp://live.twitch.tv/app/$TWITCH_STREAM_KEY;" >> /etc/nginx/nginx.conf
fi

if [[ -n "$X_STREAM_KEY" ]]; then
  echo "            push rtmp://va.pscp.tv:80/x/$X_STREAM_KEY;" >> /etc/nginx/nginx.conf
fi

# Complete the nginx configuration
cat >> /etc/nginx/nginx.conf <<EOF
        }
    }
}

http {
    server {
        listen 80;
        listen [::]:80;
        server_name _;

        location / {
            default_type text/plain;
            return 200 "RTMP Stream Forwarder - Send streams to rtmp://your-domain:1935/live/streamkey\n";
        }

        location /health {
            default_type text/plain;
            return 200 "OK\n";
        }
    }
}
EOF

# Test nginx configuration
nginx -t

# Start auth server in background
bun run auth-server.js &

# Start nginx in foreground
nginx -g "daemon off;" 