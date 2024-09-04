podman stop container_env_1
podman rm container_env_1
podman rmi env_stage_1:latest
podman pod rm pod_env

uid=${ENV_USER_UID} ##1001
gid=${ENV_USER_GID} ##1002

subuidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.UIDMap }}+{{.Size }}{{end }}" ) - 1 ))
subgidSize=$(( $(podman info --format "{{ range \
   .Host.IDMappings.GIDMap }}+{{.Size }}{{end }}" ) - 1 ))


podman build \
--build-arg=BUILD_ENV_USER_UID=${ENV_USER_UID} \
--build-arg=BUILD_ENV_USER_USERNAME=${ENV_USER_USERNAME} \
--build-arg=BUILD_ENV_USER_GID=${ENV_USER_GID} \
--build-arg=BUILD_ENV_USER_GROUPNAME=${ENV_USER_GROUPNAME} \
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
localhost/env_stage_1:latest

#-v /home/home_user/Code/Env:/workdir:Z \
#-v /opt/dmtools/code/dmtools/basecode:/workdir:Z \
#-v /opt/dmtools/code/env:/workdir:Z \
