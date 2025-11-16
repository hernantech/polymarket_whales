FROM nginx:alpine

# Copy static files
COPY index.html /usr/share/nginx/html/
COPY *.js /usr/share/nginx/html/ 2>/dev/null || true
COPY *.css /usr/share/nginx/html/ 2>/dev/null || true
COPY assets /usr/share/nginx/html/assets 2>/dev/null || true

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
