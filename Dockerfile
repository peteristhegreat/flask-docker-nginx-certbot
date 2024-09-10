# Use an official Python runtime as a parent image
FROM python:3.8.1-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory requirements.txt into the container at /app
ADD app/requirements.txt /app/

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Copy the rest of the current directory contents into the container at /app
ADD . /app

# Make port 443 available to the world outside this container
EXPOSE 443

# Define environment variable
ENV NAME=World

ENV PYTHONPATH=/app

# Run app.py when the container launches
#CMD ["python", "main.py"]
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app.main:app"]
