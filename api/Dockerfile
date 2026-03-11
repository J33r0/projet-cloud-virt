FROM python:3.13

WORKDIR /app

# Install uv
RUN pip install uv

# Copy application code (needed for building the local package)
COPY . .

# Install production dependencies
RUN uv sync --no-dev --locked

# Install gunicorn for production web server
RUN uv pip install gunicorn

# Expose the port the app runs on
EXPOSE 8080

# Start the application using gunicorn
CMD ["uv", "run", "--no-dev", "gunicorn", "--workers", "4", "--bind", "0.0.0.0:8080", "image_api.web:app"]
