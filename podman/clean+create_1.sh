podman stop container_flask_application_1
podman rm container_flask_application_1
podman rmi flask_application_1

subuidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.UIDMap }}+{{.Size }}{{end }}" ) - 1 ))
subgidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.GIDMap }}+{{.Size }}{{end }}" ) - 1 ))

podman rmi flask_application_stage_1:latest

## application image

cd /opt/dmtools/code/dmtools/basecode/flask_application

podman stop container_flask_application_1
podman rm container_flask_application_1

podman rmi flask_application_stage_1:latest

podman build \
--build-arg=BUILD_ENV_UID=${ENV_UID} \
--build-arg=BUILD_ENV_USERNAME=${ENV_USERNAME} \
--build-arg=BUILD_ENV_GID=${ENV_GID} \
--build-arg=BUILD_ENV_GROUPNAME=${ENV_GROUPNAME} \
-f Dockerfile_1 -t flask_application_stage_1 .
