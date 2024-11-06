# Step 1: Use Ubuntu as the base image
FROM ubuntu:latest

# Step 2: Update and install Apache and other necessary tools
RUN apt-get update && \
    apt-get install -y apache2

# Step 3: Copy the static website files into the container's Apache web directory
COPY ./ /var/www/html/

# Step 4: Expose port 80 (default HTTP port)
EXPOSE 80

# Step 5: Start Apache in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
