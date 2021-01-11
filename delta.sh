#!/bin/bash

docker rmi dseifert/go-echo:0.1.0
docker rmi dseifert/go-echo:0.2.0

#docker-daemon
#
./bin/skopeo.darwin.amd64 copy --override-os linux docker://dseifert/go-echo:0.1.0 docker-daemon:dseifert/go-echo:0.1.0

# Use _deltaindex if present
./bin/skopeo.darwin.amd64 copy --override-os linux docker://dseifert/go-echo:0.2.0 docker-daemon:dseifert/go-echo:0.2.0