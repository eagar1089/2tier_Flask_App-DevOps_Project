FROM python:3.11-slim-bookworm AS builder
WORKDIR /app

ENV VENV_PATH=/opt/venv
RUN python -m venv ${VENV_PATH}
ENV PATH="${VENV_PATH}/bin:${PATH}"

COPY backend/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools "wheel>=0.46.2" && pip install --no-cache-dir -r requirements.txt


FROM python:3.11-slim-bookworm AS runtime
WORKDIR /app

ENV VENV_PATH=/opt/venv
ENV PATH="${VENV_PATH}/bin:${PATH}"
ENV PYTHONPATH=/app

RUN ls -R /app

RUN rm -rf /var/lib/apt/lists/*

COPY --from=builder ${VENV_PATH} ${VENV_PATH}
COPY . .

RUN useradd -m -s /usr/sbin/nologin appuser
USER appuser
EXPOSE 8000

CMD ["python", "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
