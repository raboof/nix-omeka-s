# nix-omeka-s

An attempt to build a particular [Omeka S](https://omeka.org/s/) installation using [Nix](https://nixos.org)

## Status

This is a WIP experiment

## Using

Not ready to be used from the docker image yet

## Building

Building a docker image that will serve providence,
but will connect to an 'outside' mariadb instance for the database.

You can start it with:

```
docker load < $(nix-build build.nix) && docker-compose up
```

and then visit https://localhost:8080

## Backups

```
docker exec -ti <container id> mysqldump omeka -u omeka -p > dump.sql
```
