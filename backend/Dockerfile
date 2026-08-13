FROM node:18-alpine

WORKDIR /app

# Copy package configurations
COPY package*.json ./

# Install dependencies (including sqlite3 which compiles on Alpine, or uses prebuilt binary)
# Note: npm ci --only=production is clean and fast
RUN npm ci --only=production

# Copy the server files
COPY . .

# Expose port (Cloud Run sets PORT environment variable, usually 8080)
ENV PORT=8080
EXPOSE 8080

CMD ["node", "server.js"]
