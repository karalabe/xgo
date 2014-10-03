# xgo - Go CGO cross compiler

Although Go strives to be a cross platform language, cross compilation from one
platform to another is not as simple as it could be, as you need the Go sources
bootstrapped to each platform and architecture.

The first step towards cross compiling was Dave Cheney's [golang-crosscompile](https://github.com/davecheney/golang-crosscompile)
package, which automatically bootstrapped the necessary sources based on your
existing Go installation. Although this was enough for a lot of cases, certain
drawbacks became apparent where the official libraries used CGO internally: any
dependency to third party platform code is unavailable, hence those parts don't
cross compile nicely (native DNS resolution, system certificate access, etc).

A step forward in enabling cross compilation was Alan Shreve's [gonative](https://github.com/inconshreveable/gonative)
package, which instead of bootstrapping the different platforms based on the
existing Go installation, downloaded the official pre-compiled binaries from the
golang website and injected those into the local toolchain. Since the pre-built
binaries already contained the necessary platform specific code, the few missing
dependencies were resolved, and true cross compilation could commence... of pure
Go code.

However, there was still one feature missing: cross compiling Go code that used
CGO itself, which isn't trivial since you need access to OS specific headers and
libraries. This becomes very annoying when you need access only to some trivial
OS specific functionality (e.g. query the CPU load), but need to configure and
maintain separate build environments to do it.

## Enter xgo

My solution to the challenge of cross compiling Go code with embedded C snippets
(i.e. CGO_ENABLED=1) is based on the concept of [lightweight Linux containers](http://en.wikipedia.org/wiki/LXC).
All the necessary Go tool-chains, C cross compilers and platform headers/libraries
have been assembled into a single Docker container, which can then be called as if
a single command to compile a Go package to various platforms and architectures.

## Installation

Although you could build the container manually, it is available as an automatic
trusted build from Docker's container registry (~530MB):

    docker pull karalabe/xgo-latest

To prevent having to remember a potentially complex Docker command every time,
a lightweight Go wrapper was written on top of it.

    go get github.com/karalabe/xgo

## Usage

Simply specify the import path you want to build, and xgo will do the rest:

    $ xgo github.com/project-iris/iris
    ...

    $ ls -al
    -rwxr-xr-x  1 root     root  3086860 Aug  7 10:01 iris-darwin-386
    -rwxr-xr-x  1 root     root  3941068 Aug  7 10:01 iris-darwin-amd64
    -rwxr-xr-x  1 root     root  4185144 Aug  7 10:01 iris-linux-386
    -rwxr-xr-x  1 root     root  5196784 Aug  7 10:01 iris-linux-amd64
    -rwxr-xr-x  1 root     root  4151688 Aug  7 10:01 iris-linux-arm
    -rwxr-xr-x  1 root     root  4228608 Aug  7 10:01 iris-windows-386.exe
    -rwxr-xr-x  1 root     root  5243904 Aug  7 10:01 iris-windows-amd64.exe

### Go releases

As newer versions of the language runtime, libraries and tools get released,
these will get incorporated into xgo too as extensions layers to the base cross
compilation image (only Go 1.3 and above will be supported).

You can select which Go release to work with through the `-go` command line flag
to xgo and if the specific release was already integrated, it will automatically
be retrieved and installed.

    $ xgo -go 1.3.3 github.com/project-iris/iris

Since xgo depends on not only the official releases, but also on Dave Cheney's
ARM packages, there will be a slight delay between official Go updates and the
xgo updates.

Additionally, a few wildcard release strings are also supported:

  - `latest` will use the latest Go release
  - `1.3.x` will use the latest point release of a specific Go version

### Output prefixing

Xgo by default uses the name of the package being cross compiled as the output
file prefix. This can be overridden with the `-out` flag.

    $ xgo -out iris-v0.3.0 github.com/project-iris/iris
    ...

    $ ls -al
    -rwxr-xr-x 1 root     root  3090956 Aug 14 12:39 iris-v0.3.0-darwin-386
    -rwxr-xr-x 1 root     root  3941068 Aug 14 12:39 iris-v0.3.0-darwin-amd64
    -rwxr-xr-x 1 root     root  4185224 Aug 14 12:39 iris-v0.3.0-linux-386
    -rwxr-xr-x 1 root     root  5200960 Aug 14 12:39 iris-v0.3.0-linux-amd64
    -rwxr-xr-x 1 root     root  4155880 Aug 14 12:39 iris-v0.3.0-linux-arm
    -rwxr-xr-x 1 root     root  4230144 Aug 14 12:39 iris-v0.3.0-windows-386.exe
    -rwxr-xr-x 1 root     root  5245952 Aug 14 12:39 iris-v0.3.0-windows-amd64.exe

### Build flags

A handful of flags can be passed to `go build`. The currently supported ones are

  - `-v`: prints the names of packages as they are compiled
  - `-race`: enables data race detection (supported only on amd64, rest built without)
