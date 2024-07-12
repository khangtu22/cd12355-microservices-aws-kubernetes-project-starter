# Use Python 3.10-alpine as the base image
FROM python:3.10-alpine

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV POETRY_VERSION=1.5.1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev

# Install Poetry
RUN pip install --no-cache-dir "poetry==$POETRY_VERSION"

# Copy only the dependency files first
COPY pyproject.toml poetry.lock* ./

# Install project dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

# Copy the rest of the application code
COPY ./analytics .

# Create a non-root user and switch to it
RUN adduser -D appuser
USER appuser

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]