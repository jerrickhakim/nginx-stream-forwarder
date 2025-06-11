FROM tiangolo/nginx-rtmp:latest

# Install Bun, envsubst, and ffmpeg
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"
RUN apt-get update && apt-get install -y gettext-base ffmpeg && rm -rf /var/lib/apt/lists/*

# Copy nginx configuration template
COPY nginx.conf.template.conf /nginx.conf.template

# Copy auth server files
COPY package.json auth-server.js ./

# Install dependencies
RUN bun install

# Create log directory (permissions are handled by the base image)
RUN mkdir -p /var/log/nginx

# Expose HTTP, RTMP, and auth service ports
EXPOSE 80 1935 8080

# Start script to inject env vars into nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Start both services
CMD ["/start.sh"] 