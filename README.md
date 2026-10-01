# mrlrobot2

### Pull the image
```bash
docker pull ghcr.io/ncumathroboticslab/mrlrobot2-docker:latest
```

### DistroBox create command
```bash
distrobox create --name ros-jazzy --image <image>:latest --home ~/distrobox_homes/ros-jazzy --hostname ros-jazzy --nvidia --additional-flags "--privileged"
```
