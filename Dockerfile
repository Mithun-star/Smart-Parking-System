FROM node:18-alpine

WORKDIR /app

# Copy backend dependency declarations
COPY backend/package*.json ./backend/

# Install backend dependencies
WORKDIR /app/backend
RUN npm ci --only=production

# Copy whole backend, frontend, and database templates
WORKDIR /app
COPY backend/ ./backend/
COPY frontend/ ./frontend/
COPY database/ ./database/

# Expose port (Cloud Run will set PORT environment variable, usually 8080)
ENV PORT=8080
EXPOSE 8080

# Run Express server
WORKDIR /app/backend
CMD ["node", "server.js"]
