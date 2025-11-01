# Based on python:3.13-alpine3.22
# checkov:skip=CKV_DOCKER_3: User already set in the base image
FROM ghcr.io/netcracker/qubership-docker-integration-tests:0.3.4

# Env ${ROBOT_HOME} is set in the base image as /opt/robot
ENV SERVICE_CHECKER_SCRIPT=${ROBOT_HOME}/jaeger_pods_checker.py

# Copy tests source code
COPY robot/ ${ROBOT_HOME}/
