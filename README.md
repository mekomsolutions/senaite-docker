# SENAITE Docker
<p align="left">
  <img src="senaite-without-sso/readme/senaite_logo.png" width="200" title="SENAITE">
  <img src="senaite-without-sso/readme/plus.png" width="50" title="Docker">
  <img src="senaite-without-sso/readme/docker_logo.png" width="100" title="Docker">
</p>

Resources to build custom Docker image for SENAITE

Image is available on Docker Hub at
[mekomsolutions/senaite](https://hub.docker.com/r/mekomsolutions/openmrs/tags)

## Run the project

```
docker-compose up
```

### Environment variables

Additionally, the image will accept the following environment variable when run:

| Variable name                  | Default |                                    Description                                   |
|--------------------------------|---------|:--------------------------------------------------------------------------------:|
| `ADMIN_USER`                       |         | Name of the administrator user   
| `ADMIN_PASSWORD`                      |  | Password of the administrator  user name                        
| `SITE` |         | The 'site' name, eg, 'clinic1' |

### Volumes

#### Config volume
`/data/importdata/senaite`: Place where to drop a initial data.tar.gz file to import data on first start.

#### Data volumes
`/data`: SENAITE data storage path
