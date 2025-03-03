# Build the manager binary
# Note: this uses host platform for the build, and we ask go build to target the needed platform, so we do not spend time on qemu emulation when running "go build"
FROM --platform=$BUILDPLATFORM golang:1.24.0-alpine3.21 AS builder
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG GOPROXY=""
ENV GOSUMDB=off \
    GO111MODULE=on

WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download -x

# Copy the go source
COPY main.go main.go

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -a -o probe .

# Main container
FROM alpine:3.21.3

ENV USER_UID=2001 \
    USER_NAME=probe \
    GROUP_NAME=probe

WORKDIR /app/

COPY --from=builder --chown=${USER_UID} /workspace/probe /app/

RUN addgroup ${GROUP_NAME} \
    && adduser -D -G ${GROUP_NAME} -u ${USER_UID} ${USER_NAME}

USER ${USER_UID}

CMD ["/app/probe"]
