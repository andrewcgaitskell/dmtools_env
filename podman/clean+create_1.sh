podman stop container_env_1
podman rm container_env_1
podman rmi env_stage_1:latest

subuidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.UIDMap }}+{{.Size }}{{end }}" ) - 1 ))
subgidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.GIDMap }}+{{.Size }}{{end }}" ) - 1 ))

#podman build \
#--build-arg=BUILD_ENV_UID=${ENV_UID} \
#--build-arg=BUILD_ENV_USERNAME=${ENV_USERNAME} \
#--build-arg=BUILD_ENV_GID=${ENV_GID} \
#--build-arg=BUILD_ENV_GROUPNAME=${ENV_GROUPNAME} \
#-f Dockerfile_1 -t flask_application_stage_1 .

podman build \
--build-arg=BUILD_ENV_UID=${ENV_UID} \
--build-arg=BUILD_ENV_USERNAME=${ENV_USERNAME} \
--build-arg=BUILD_ENV_GID=${ENV_GID} \
--build-arg=BUILD_ENV_GROUPNAME=${ENV_GROUPNAME} \
--build-arg=BUILD_ENV_REPO_URL=${ENV_REPO_URL} \
--build-arg=BUILD_ENV_RUNNER_TOKEN=${ENV_RUNNER_TOKEN} \
-f Dockerfile_1 -t env_stage_1 .


podman pod create \
--name pod_env \
--infra-name infra_env \
--network bridge \
--uidmap 0:1:$uid \
--uidmap $uid:0:1 \
--uidmap $(($uid+1)):$(($uid+1)):$(($subuidSize-$uid)) \
--gidmap 0:1:$gid \
--gidmap $gid:0:1 \
--gidmap $(($gid+1)):$(($gid+1)):$(($subgidSize-$gid))

# podman run -d --name github-runner \
#  -e REPO_URL="https://github.com/your-user/your-repo" \
#  -e RUNNER_TOKEN="YOUR_TOKEN_HERE" \
#  -v ${HOME}/runner/_work:/home/runner/_work \
#  github-runner:latest

podman create \
--name container_env_1 \
--pod pod_env \
--user $uid:$gid \
--log-opt max-size=10mb \
#-v /opt/dmtools/code/dmtools/basecode:/workdir:Z \
-v /opt/dmtools/code/env:/workdir:Z \
localhost/env_stage_1:latest
