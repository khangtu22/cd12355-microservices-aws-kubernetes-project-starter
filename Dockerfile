# Use a specific Python 3.10 Alpine image version for better reproducibility
FROM public.ecr.aws/docker/library/python:3.10.12-alpine3.18

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache gcc musl-dev linux-headers

# Copy only the requirements file first to leverage Docker cache
COPY /analytics/requirements.txt .

# Copy the .env file
COPY /analytics/.env .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY /analytics/ .

# Create a non-root user and switch to it
RUN adduser -D appuser
USER appuser

# Expose port 5000
EXPOSE 5000

# Set an environment variable
ENV NAME=World

# Run the application when the container starts
CMD ["python", "app.py"]
