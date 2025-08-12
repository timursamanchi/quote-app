# Use an official Python image
FROM python:3.11-slim

# Upgrade pip and system packages to address vulnerabilities, then clean up
RUN apt-get update && apt-get upgrade -y && pip install --upgrade pip && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip && pip install flask redis 

# Set the working directory
WORKDIR /app

# Copy the Python script into the container
COPY quote.py .
COPY quotes.csv .

EXPOSE 8080

# Set the command to run your script
CMD ["python", "quote.py"]