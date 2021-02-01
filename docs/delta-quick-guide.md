# Skopeo delta quick guide

### 1. Installation (Ubuntu 20.04)
More installation guides are available [here](../install.md).
```bash
# Install skopeo-binary dependencies
sudo apt install libgpgme-dev libassuan-dev libbtrfs-dev libdevmapper-dev

# Install golang
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt update
sudo apt install golang-go -y

# Cross compile skopeo
sudo apt-get install git make -y
git clone --branch wip/deltas https://github.com/Foundato/skopeo.git && \
     cd ./skopeo && \
     make local-cross && \
     cd ./bin
```

### 2. Place configuration files
```bash
# Create policy.json
sudo mkdir /etc/containers
sudo bash -c 'cat << EOF > /etc/containers/policy.json
{
    "default": [{"type": "insecureAcceptAnything"}],
    "transports": {"docker-daemon":{"": [{"type":"insecureAcceptAnything"}]}}
}
EOF'

# Create config for storage target 'containers-storage' 
sudo bash -c 'cat << EOF > /etc/containers/storage.conf
[storage]
driver = "vfs"
graphroot = "$HOME/containers/storage"
rootless_storage_path = "$HOME/containers/storage"
runroot = "$HOME/containers/storage"
EOF'
```

### 3. Generate delta layer
```bash
mkdir $HOME/.skopeo
./skopeo.linux.amd64 login --authfile $HOME/.skopeo/auth.json docker.io
./skopeo.linux.amd64 generate-delta docker://dseifert/go-echo:0.2.0 docker://dseifert/go-echo:0.1.0 --authfile $HOME/.skopeo/auth.json
```

### 4. Copy initial image followed by following version with delta
All copy tasks need to be run with sudo privileges. Otherwise the command will fail silently without exiting!
```bash
# Initial image (no deltas yet)
sudo ./skopeo.linux.amd64 copy docker://dseifert/go-echo:0.2.0 containers-storage:go-echo:0.2.0

# Upgrade (v1 -> v2) where delta will be used
sudo ./skopeo.linux.amd64 copy docker://dseifert/go-echo:0.2.0 containers-storage:go-echo:0.2.0
```

### 5. Inspect delta layer
```bash
./skopeo.linux.amd64 inspect docker://dseifert/go-echo:_deltaindex --raw
```