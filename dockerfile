# Use official Python image
FROM python:3.10-slim

# Set working directory inside container
WORKDIR /app

# Copy only requirements first (optional if no requirements.txt)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt || true

# Copy application code
COPY . .

# Expose Flask port
EXPOSE 8080

# Run the Flask app
CMD ["python", "code.py"]
