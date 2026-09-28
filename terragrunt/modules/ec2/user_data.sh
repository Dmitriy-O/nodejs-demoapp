#!/bin/bash

set -Eeuo pipefail

exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

IMAGE="${docker_image}"
HOST_PORT="${app_port}"
HEALTH_PATH="${health_check_path}"
CONTAINER_NAME="nodejs-demoapp"

on_error() {
  exit_code=$?
  trap - ERR

  echo "User data failed with exit code: $exit_code"
  systemctl status docker --no-pager || true
  docker ps -a || true
  docker logs --tail 200 "$CONTAINER_NAME" || true

  exit "$exit_code"
}

trap on_error ERR

echo "Starting EC2 user data"
echo "Docker image: $IMAGE"

dnf install -y docker
command -v curl >/dev/null 2>&1 || dnf install -y curl-minimal

systemctl enable --now docker
systemctl enable --now amazon-ssm-agent || true

for attempt in $(seq 1 10); do
  if docker pull "$IMAGE"; then
    echo "Docker image downloaded"
    break
  fi

  if [ "$attempt" -eq 10 ]; then
    echo "Could not download Docker image"
    exit 1
  fi

  echo "Pull attempt $attempt failed; waiting 15 seconds"
  sleep 15
done

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  --env PORT=3000 \
  --publish "$HOST_PORT:3000" \
  "$IMAGE"

for attempt in $(seq 1 60); do
  if curl --fail --silent --show-error \
    "http://127.0.0.1:$HOST_PORT$HEALTH_PATH"; then
    echo
    echo "Application health check passed"
    exit 0
  fi

  echo "Application is not ready yet: attempt $attempt"
  sleep 5
done

echo "Application health check did not pass"
exit 1
