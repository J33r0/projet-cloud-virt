FROM python:3.13

WORKDIR /app

# Install uv and add to PATH
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install production dependencies
RUN uv sync --no-dev --locked

# Install gunicorn for production web server
RUN uv pip install gunicorn

# Copy application code
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Run the web server by default (can be overridden for worker)
# CMD ["uv", "run", "--no-dev", "gunicorn", "--workers", "4", "--bind", "0.0.0.0:8080", "image_api.web:app"]

