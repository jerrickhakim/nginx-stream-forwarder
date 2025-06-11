import { Hono } from "hono";
import crypto from "crypto";

const app = new Hono();

// Get the allowed stream key from environment variable
const ALLOWED_KEY = process.env.APP_STREAM_KEY;

function safeCompare(a, b) {
  const aBuf = Buffer.from(a);
  const bBuf = Buffer.from(b);

  // Early length check (constant-time comparison requires equal length)
  if (aBuf.length !== bBuf.length) {
    return false;
  }

  return crypto.timingSafeEqual(aBuf, bBuf);
}

console.log("Auth server starting...");
console.log(`Stream key configured: ${ALLOWED_KEY ? "Yes" : "No"}`);

// Auth endpoint for NGINX RTMP on_publish
app.post("/auth", async (c) => {
  try {
    // Get form data from NGINX RTMP
    const body = await c.req.parseBody();
    const streamKey = body.name; // This is the stream key from /live/<name>

    console.log(`Auth request for stream key`);

    if (!ALLOWED_KEY) {
      console.log("No STREAM_KEY environment variable set");
      return c.text("Server configuration error", 500);
    }

    // Use constant-time comparison to prevent timing attacks
    const isValid = safeCompare(streamKey, ALLOWED_KEY);

    if (isValid) {
      console.log("Stream key authorized");
      return c.text("OK", 200);
    } else {
      console.log("Stream key rejected");
      return c.text("Forbidden", 403);
    }
  } catch (error) {
    console.error("Auth error:", error);
    return c.text("Internal server error", 500);
  }
});

// Health check endpoint
app.get("/health", (c) => {
  return c.text("Auth service OK");
});

// Default route
app.get("/", (c) => {
  return c.text("RTMP Auth Service - Use POST /auth for stream authentication");
});

export default {
  port: 8080,
  fetch: app.fetch,
};
