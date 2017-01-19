To start gitlab locally:

docker run --detach --hostname mike.gitlab --publish 443:443 --publish 80:80 --publish 22:22 --name gitlab --restart always --volume ~/docker_shares/srv/gitlab/config:/etc/gitlab --volume ~/docker_shares/srv/gitlab/logs:/var/log/gitlab --volume ~/docker_shares/srv/gitlab/data:/var/opt/gitlab gitlab/gitlab-ce:latest

Add shared submodule to system_track_accounts, system_track_machines and system_track_web:

git submodule add git@mike.gitlab:mike.moore/system_track_shared.git vendor/system_track_shared
git submodule init vendor/system_track_shared/
