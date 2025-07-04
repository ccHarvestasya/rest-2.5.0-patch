# rest-2.5.0-patch1

## issue

- Missing `maxFee` in WebSocket transaction notification

## Application

### Install `jq`

```bash
sudo apt update
sudo apt install jq
```

### Clone the repository

```bash
git clone https://github.com/ccHarvestasya/rest-2.5.0-patch.git
```

### Apply the patch

Make sure your node is running.

```bash
cd rest-2.5.0-patch
cd patch1
./rest-2.5.0-patch1.sh
```

### Restart the node

```bash
docker compose stop
docker compose up -d
```
