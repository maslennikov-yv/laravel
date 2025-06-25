FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy custom nginx configuration
COPY docker/k8s/nginx.conf /etc/nginx/nginx.conf
COPY docker/k8s/default.conf /etc/nginx/conf.d/default.conf

# Create necessary directories
RUN mkdir -p /tmp/nginx /var/cache/nginx

# Create non-root user
RUN addgroup -g 1000 -S nginx-user && \
    adduser -u 1000 -D -S -G nginx-user nginx-user

# Set proper permissions
RUN chown -R nginx-user:nginx-user /var/cache/nginx /tmp/nginx

# Switch to non-root user
USER nginx-user

# Expose port
EXPOSE 8000

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 