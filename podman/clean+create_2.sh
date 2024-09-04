podman stop container_flask_application_1
podman rm container_flask_application_1

subuidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.UIDMap }}+{{.Size }}{{end }}" ) - 1 ))
subgidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.GIDMap }}+{{.Size }}{{end }}" ) - 1 ))

uid=${ENV_UID} ##1001
gid=${ENV_GID} ##1002

podman rmi flask_application_stage_2:latest

## application image

cd /opt/dmtools/code/dmtools/basecode/flask_application

podman rmi flask_application_stage_2:latest

## application image

podman build \
--build-arg=BUILD_ENV_UID=${ENV_UID} \
--build-arg=BUILD_ENV_USERNAME=${ENV_USERNAME} \
--build-arg=BUILD_ENV_GID=${ENV_GID} \
--build-arg=BUILD_ENV_GROUPNAME=${ENV_GROUPNAME} \
-f Dockerfile_2 -t flask_application_stage_2 .


podman create \
--name container_flask_application_1 \
--pod pod_main_backend \
--user $uid:$gid \
--log-opt max-size=10mb \
-v /opt/dmtools/code/dmtools/basecode:/workdir:Z \
localhost/flask_application_stage_2:latest

