Docker Alias for Relative Build Path
=======================================

Allows 'docker build' command to use symbolic path (i.e., '../..' instead of '.') when referring to the root directory for the build.

Install:
-------------
```
cd <dir>
git clone https://github.com/nathansherburne/docker_alias.git
echo "source <dir>/docker_alias/docker_alias.sh" >> ~/.bashrc
source ~/.bashrc
```

Example Use:
-------------
```
docker build -t name -f Dockerfile --build-arg ENV_FILE=.env ../..
```
instead of:
```
docker build -t name -f containers/my_container/Dockerfile --build-arg ENV_FILE=containers/my_container/.env .
```
