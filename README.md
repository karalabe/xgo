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
trusted build from Docker's container registry (not insignificant in size):

    docker pull karalabe/xgo-latest

To prevent having to remember a potentially complex Docker command every time,
a lightweight Go wrapper was written on top of it.

    go get github.com/karalabe/xgo

## Usage

Simply specify the import path you want to build, and xgo will do the rest:

    $ xgo github.com/project-iris/iris
    ...

    $ ls -al
    -rwxr-xr-x  1 root  root  10899488 Sep 14 18:05 iris-android-21-arm
    -rwxr-xr-x  1 root  root   6442188 Sep 14 18:05 iris-darwin-386
    -rwxr-xr-x  1 root  root   8228756 Sep 14 18:05 iris-darwin-amd64
    -rwxr-xr-x  1 root  root   9532568 Sep 14 18:05 iris-linux-386
    -rwxr-xr-x  1 root  root  11776368 Sep 14 18:05 iris-linux-amd64
    -rwxr-xr-x  1 root  root   9408928 Sep 14 18:05 iris-linux-arm
    -rwxr-xr-x  1 root  root   7131477 Sep 14 18:05 iris-windows-386.exe
    -rwxr-xr-x  1 root  root   8963900 Sep 14 18:05 iris-windows-amd64.exe


### Build flags

A handful of flags can be passed to `go build`. The currently supported ones are

  - `-v`: prints the names of packages as they are compiled
  - `-x`: prints the build commands as compilation progresses
  - `-race`: enables data race detection (supported only on amd64, rest built without)


### Go releases

As newer versions of the language runtime, libraries and tools get released,
these will get incorporated into xgo too as extensions layers to the base cross
compilation image (only Go 1.3 and above will be supported).

You can select which Go release to work with through the `-go` command line flag
to xgo and if the specific release was already integrated, it will automatically
be retrieved and installed.

    $ xgo -go 1.5.1 github.com/project-iris/iris

Additionally, a few wildcard release strings are also supported:

  - `latest` will use the latest Go release
  - `1.5.x` will use the latest point release of a specific Go version

### Output prefixing

xgo by default uses the name of the package being cross compiled as the output
file prefix. This can be overridden with the `-out` flag.

    $ xgo -out iris-v0.3.2 github.com/project-iris/iris
    ...

    $ ls -al
    -rwxr-xr-x  1 root  root  10899488 Sep 14 18:08 iris-v0.3.2-android-21-arm
    -rwxr-xr-x  1 root  root   6442188 Sep 14 18:08 iris-v0.3.2-darwin-386
    -rwxr-xr-x  1 root  root   8228756 Sep 14 18:08 iris-v0.3.2-darwin-amd64
    -rwxr-xr-x  1 root  root   9532568 Sep 14 18:08 iris-v0.3.2-linux-386
    -rwxr-xr-x  1 root  root  11776368 Sep 14 18:08 iris-v0.3.2-linux-amd64
    -rwxr-xr-x  1 root  root   9408928 Sep 14 18:08 iris-v0.3.2-linux-arm
    -rwxr-xr-x  1 root  root   7131477 Sep 14 18:08 iris-v0.3.2-windows-386.exe
    -rwxr-xr-x  1 root  root   8963900 Sep 14 18:08 iris-v0.3.2-windows-amd64.exe

### Package selection

If the project you are cross compiling is not a single executable, but rather a
larger project containing multiple commands, you can select the specific sub-
package to build via the `--pkg` flag.

    $ xgo --pkg cmd/goimports golang.org/x/tools
    ...

    $ ls -al
    -rwxr-xr-x  1 root  root   4924036 Sep 14 18:09 goimports-android-21-arm
    -rwxr-xr-x  1 root  root   4135776 Sep 14 18:09 goimports-darwin-386
    -rwxr-xr-x  1 root  root   5182624 Sep 14 18:09 goimports-darwin-amd64
    -rwxr-xr-x  1 root  root   4184416 Sep 14 18:09 goimports-linux-386
    -rwxr-xr-x  1 root  root   5254800 Sep 14 18:09 goimports-linux-amd64
    -rwxr-xr-x  1 root  root   4204440 Sep 14 18:09 goimports-linux-arm
    -rwxr-xr-x  1 root  root   4343296 Sep 14 18:09 goimports-windows-386.exe
    -rwxr-xr-x  1 root  root   5409280 Sep 14 18:09 goimports-windows-amd64.exe

This argument may at some point be merged into the import path itself, but for
now it exists as an independent build parameter. Also, there is not possibility
for now to build mulitple commands in one go.

### Branch selection

Similarly to `go get`, xgo also uses the `master` branch of a repository during
source code retrieval. To switch to a different branch before compilation pass
the desired branch name through the `--branch` argument.

    $ xgo --pkg cmd/goimports --branch release-branch.go1.4 golang.org/x/tools
    ...

    $ ls -al
    -rwxr-xr-x  1 root  root   4928992 Sep 14 18:10 goimports-android-21-arm
    -rwxr-xr-x  1 root  root   4139868 Sep 14 18:10 goimports-darwin-386
    -rwxr-xr-x  1 root  root   5186720 Sep 14 18:10 goimports-darwin-amd64
    -rwxr-xr-x  1 root  root   4189448 Sep 14 18:10 goimports-linux-386
    -rwxr-xr-x  1 root  root   5264120 Sep 14 18:10 goimports-linux-amd64
    -rwxr-xr-x  1 root  root   4209400 Sep 14 18:10 goimports-linux-arm
    -rwxr-xr-x  1 root  root   4348416 Sep 14 18:10 goimports-windows-386.exe
    -rwxr-xr-x  1 root  root   5415424 Sep 14 18:10 goimports-windows-amd64.exe

### Remote selection

Yet again similarly to `go get`, xgo uses the repository remote corresponding to
the import path being built. To switch to a different remote while preserving the
original import path, use the `--remote` argument.

    $ xgo --pkg cmd/goimports --remote github.com/golang/tools golang.org/x/tools
    ...

### Limit build targets

By default `xgo` will try and build the specified package to all platforms and
architectures supported by the underlying Go runtime. If you wish to restrict
the build to only a few target systems, use the comma separated `--targets` CLI
argument:

  * `--targets=linux/arm`: builds only the ARMv5 Linux binaries
  * `--targets=windows/*,darwin/*`: builds all Windows and OSX binaries
  * `--targets=*/arm`: builds ARM binaries for all platforms
  * `--targets=*/*`: builds all suppoted targets (default)

The Android platform is handled a bit differently currently due to the multitude
of available platform versions (23 as of writing, some obsolted). As it is mostly
pointless to build for all possible versions, `xgo` by default builds only against
the latest release, controllable via a numerical argument after the platform:

  * `--targets=android-16/*`: build all supported architectures for Jelly Bean
  * `--targets=android-16/arm,android-21/arm`: build for Jelly Bean and Lollipop

Note, `xgo` honors the Android's position independent executables (PIE) security
requirement, builing all binaries equal and above to Jelly Bean with PIE enabled.

    $ readelf -h iris-android-15-arm | grep Type
      Type:                              EXEC (Executable file)
    $ readelf -h iris-android-21-arm | grep Type
      Type:                              DYN (Shared object file)


### CGO dependencies

The main differentiator of xgo versus other cross compilers is support for basic
embedded C code and target-platform specific OS SDK availability. The current xgo
release introduces an experimental CGO *dependency* cross compilation, enabling
building Go programs that require external C libraries.

It is assumed that the dependent C library is `configure/make` based, was properly
prepared for cross compilation and is available as a tarball download (`.tar`,
`.tar.gz` or `.tar.bz2`).

Such dependencies can be added via the `--deps` CLI argument. A complex sample
for such a scenario is building the Ethereum CLI node, which has the GNU Multiple
Precision Arithmetic Library as it's dependency.

    $ xgo --pkg=cmd/geth --branch=develop --deps=https://gmplib.org/download/gmp/gmp-6.0.0a.tar.bz2 github.com/ethereum/go-ethereum
    ...

    $ ls -al
    -rwxr-xr-x 1 root     root  12605252 May  4 11:32 geth-darwin-386
    -rwxr-xr-x 1 root     root  14989860 May  4 11:32 geth-darwin-amd64
    -rwxr-xr-x 1 root     root  17137020 May  4 11:32 geth-linux-386
    -rwxr-xr-x 1 root     root  20212335 May  4 11:32 geth-linux-amd64
    -rwxr-xr-x 1 root     root  16475468 May  4 11:32 geth-linux-arm
    -rwxr-xr-x 1 root     root  16928256 May  4 11:32 geth-windows-386.exe
    -rwxr-xr-x 1 root     root  19760640 May  4 11:32 geth-windows-amd64.exe

Note, that since xgo needs to cross compile the dependencies for each platform
and architecture separately, build time can increase significantly.
