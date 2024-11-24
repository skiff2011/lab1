# Use the official Nginx image as the base image
FROM nginx:latest

# Copy the static site content to the Nginx HTML directory
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80
