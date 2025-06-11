# NGINX Stream Forwarder

A secure Docker-based NGINX stream forwarder that forwards RTMP streams to YouTube Live and Twitch, with stream key authentication, deployable on fly.io.

## 🔐 Stream Authentication

With this forwarder only streams with the correct key can publish!

**Stream URL format:** `rtmp://<app_name>.fly.dev/live/<your-secret-key>`

## Features

- ✅ RTMP stream forwarding to YouTube Live and Twitch
- ✅ Stream key authentication for security
- ✅ Docker containerized with Hono-based auth service
- ✅ Ready for fly.io deployment
- ✅ Health checks and monitoring
- ✅ Multiple stream endpoints
- ✅ Automatic failover and scaling
- ✅ Real-time auth logging

## Prerequisites

Before starting, ensure you have:

- A [fly.io account](https://fly.io/signup)
- YouTube Live streaming enabled on your YouTube channel
- Your YouTube Live stream key ready
- A computer with internet access

## Setup Guide

### Step 1: Install flyctl CLI

Install the fly.io command line tool to deploy.
**Windows (PowerShell):**

```powershell
pwsh -c "iwr https://fly.io/install.ps1 -useb | iex"
```

**Alternative (using package managers):**

```bash
# macOS with Homebrew
brew install flyctl

# Linux with snap
sudo snap install flyctl
```

### Step 2: Login to fly.io

Authenticate with your fly.io account:

```bash
flyctl auth login
```

This will open your browser for authentication. Complete the login process.

### Step 3: Get the Code

Clone or download this repository:

```bash
git clone <repository-url>
cd nginx-stream-forwarding
```

Or download and extract the ZIP file, then navigate to the folder.

### Step 4: Configure Your App

1. **Set a unique app name** in `fly.toml`:

   ```toml
   app = "your-unique-stream-forwarder"  # Choose a unique name
   ```

2. **Choose your deployment region** (optional):
   ```toml
   primary_region = "iad"  # US East (default)
   # Other options: lax (US West), fra (Europe), nrt (Asia), etc.
   ```

### Step 5: Set Stream Keys

Set your streaming platform keys and authentication key as secrets:

```bash
# Required: YouTube stream key
flyctl secrets set YOUTUBE_STREAM_KEY="your-youtube-stream-key-here"

# Optional: Twitch stream key (if you want multi-platform streaming)
flyctl secrets set TWITCH_STREAM_KEY="your-twitch-stream-key-here"

# Optional: X (Twitter) stream key
flyctl secrets set X_STREAM_KEY="your-x-stream-key-here"

# Required: Your secure stream authentication key
flyctl secrets set STREAM_KEY="your-secure-stream-key-here"
```

### Step 6: Deploy Your App

Deploy your stream forwarder:

```bash
flyctl launch --no-deploy
flyctl deploy
```

The `--no-deploy` flag creates the app without deploying, then `flyctl deploy` does the actual deployment.

### Step 7: Verify Deployment

1. **Check app status:**

   ```bash
   flyctl status
   ```

2. **View your app info:**

   ```bash
   flyctl info
   ```

3. **Test the health endpoint:**
   ```bash
   curl https://your-app-name.fly.dev/health
   ```

## Usage

### Streaming to Your Forwarder

Once deployed, use this URL in your streaming software:

```
rtmp://your-app-name.fly.dev/live/your-stream-key
```

**Important:** Replace `your-stream-key` with the STREAM_KEY secret you set in Step 5. Only streams with the correct key will be accepted!

### Streaming Software Configuration

#### OBS Studio

1. Go to Settings → Stream
2. Set Service to "Custom..."
3. Set Server to: `rtmp://your-app.fly.dev/live/`
4. Set Stream Key to: `your-stream-key`

#### FFmpeg

```bash
ffmpeg -i input.mp4 -c copy -f flv rtmp://your-app.fly.dev/live/your-stream-key
```

## Architecture

```
[Your Streaming Software]
        ↓ RTMP
[nginx-stream-forwarder on fly.io]
        ↓ RTMP Forward
[YouTube Live & Twitch Servers]
```

## Configuration

### NGINX Configuration

The `nginx.conf` file contains:

- HTTP server for health checks (port 80)
- Stream forwarding servers (ports 1935, 1936)
- Upstream YouTube and Twitch RTMP servers
- Logging and monitoring

### Fly.io Configuration

The `fly.toml` file defines:

- App settings and region
- Service ports (80, 1935, 1936)
- Resource allocation
- Health checks

## Monitoring

- **Health Check**: `https://your-app.fly.dev/health`
- **Status**: `https://your-app.fly.dev/`
- **Logs**: `flyctl logs`

## Troubleshooting

### Common Issues

1. **Stream not connecting**:

   - Verify your YouTube stream key is correct
   - Check if YouTube Live is enabled on your account
   - Ensure ports 1935/1936 are not blocked
   - Verify your STREAM_KEY matches what you set in secrets

2. **Deployment fails**:

   - Check flyctl is installed and up to date
   - Verify you're logged into fly.io
   - Ensure the app name in fly.toml is unique

3. **Stream drops**:
   - Check fly.io app logs: `flyctl logs`
   - Monitor network connectivity
   - Consider increasing VM resources in fly.toml

### Viewing Logs

View real-time logs:

```bash
flyctl logs
```

View nginx access logs:

```bash
flyctl ssh console
tail -f /var/log/nginx/stream.log
```

## Customization

### Add More Streaming Platforms

Edit `nginx.conf` to add more upstream servers:

```nginx
if [[ -n "$X_STREAM_KEY" ]]; then
  echo "            push rtmp://va.pscp.tv:80/x/$X_STREAM_KEY;" >> /etc/nginx/nginx.conf
fi
```

### Change Regions

Edit `fly.toml` to change deployment region:

```toml
primary_region = "fra"  # Frankfurt
# Other options: lax, ord, lhr, nrt, syd, etc.
```

### Update Resources

Modify VM resources in `fly.toml`:

```bash
flyctl machines update <machine-id> --cpus 1 --memory 1024
```

## License

MIT License - feel free to modify and use for your streaming needs!
