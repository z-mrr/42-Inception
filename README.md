## 42-Inception
### Installing Docker on Ubuntu
#### Remove conflitcts
```
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
```
```
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
```
```
sudo rm -rf /var/lib/docker
```
```
sudo rm -rf /var/lib/containerd
```
#### Install using Apt repository
Add Docker's official GPG key:
```
sudo apt-get update
```
```
sudo apt-get install ca-certificates curl gnupg
```
```
sudo install -m 0755 -d /etc/apt/keyrings
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
Add the repository to Apt sources:
```
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```
sudo apt-get update
```
Install the Docker packages
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Verify that the Docker Engine installation is successful by running the hello-world image
```
sudo docker run hello-world
```
#### Manage Docker as non-root user
Check if docker group exists and if the user is on it
```
cat /etc/group | grep docker
```
Add user to ```docker``` group if it exists
```
usermod -aG docker $USER
```
If it doesn't exist, create the ```docker``` group
```
sudo groupadd docker
```
Add user to the ```docker``` group
```
sudo usermod -aG docker $USER
```
Reboot or 
```
newgrp docker
```
Verify that you can run ```docker``` commands without ```sudo```
```
docker run hello-world
```


