# xgomobile - Go CGO cross compiler for gomobile

### Usage

```
docker run --rm \
    -v "$PWD"/build:/build \
    -v "$GOPATH"/.xgo-cache:/deps-cache:ro \
    -v "$PWD"/src:/ext-go/1/src:ro \
    -e OUT=Mysterium \
    -e FLAG_V=false \
    -e FLAG_X=false \
    -e FLAG_RACE=false \
    -e FLAG_BUILDMODE=default \
    -e TARGETS=android/. \
    -e EXT_GOPATH=/ext-go/1 \
    -e GO111MODULE=off \
    mysteriumnetwork/xgomobile:1.13.8 mobilepkg
```

Also see and run ./test.sh to build test examples.

### Building image

If you make changes in docker/base you need to rebuild base image.

```
docker build -t mysteriumnetwork/xgomobile:base -f ./docker/base/Dockerfile ./docker/base
docker push mysteriumnetwork/xgomobile:base
```

If you add new go version only when build and push.

Build new image.
```
docker build -t mysteriumnetwork/xgomobile:1.13.8 -f ./docker/go-1.13.8/Dockerfile .
```

Update and run tests.
```
./test.sh
```

Push image
```
docker push mysteriumnetwork/xgomobile:1.13.8
```
