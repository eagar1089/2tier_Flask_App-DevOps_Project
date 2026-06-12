FROM python:3.11-slim-bookworm AS builder

WORKDIR /app

ENV VENV_PATH=/opt/venv
RUN python -m venv ${VENV_PATH}
ENV PATH="${VENV_PATH}/bin:${PATH}"

COPY backend/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt


FROM python:3.11-slim-bookworm AS runtime

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

ENV VENV_PATH=/opt/venv
COPY --from=builder ${VENV_PATH} ${VENV_PATH}
ENV PATH="${VENV_PATH}/bin:${PATH}"

ENV PYTHONPATH=/app

COPY backend/ ./backend/

RUN useradd -m -u 1000 -s /usr/sbin/nologin appuser && chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "5000"]