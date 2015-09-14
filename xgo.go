// Go CGO cross compiler
// Copyright (c) 2014 Péter Szilágyi. All rights reserved.
//
// Released under the MIT license.

// Wrapper around the GCO cross compiler docker container.
package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Cross compilation docker containers
var dockerBase = "karalabe/xgo-base"
var dockerDist = "karalabe/xgo-"

// Command line arguments to fine tune the compilation
var goVersion = flag.String("go", "latest", "Go release to use for cross compilation")
var inPackage = flag.String("pkg", "", "Sub-package to build if not root import")
var outPrefix = flag.String("out", "", "Prefix to use for output naming (empty = package name)")
var srcRemote = flag.String("remote", "", "Version control remote repository to build")
var srcBranch = flag.String("branch", "", "Version control branch to build")
var crossDeps = flag.String("deps", "", "CGO dependencies (configure/make based archives)")
var targets = flag.String("targets", "*/*", "Comma separated targets to build for")
var dockerImage = flag.String("image", "", "Use a custom docker image instead of official distribution")
var beforeBuildScript = flag.String("before-build", "", "Script to run before the build step")

// Command line arguments to pass to go build
var buildVerbose = flag.Bool("v", false, "Print the names of packages as they are compiled")
var buildSteps = flag.Bool("x", false, "Print the command as executing the builds")
var buildRace = flag.Bool("race", false, "Enable data race detection (supported only on amd64)")

func main() {
	flag.Parse()

	// Ensure docker is available
	if err := checkDocker(); err != nil {
		log.Fatalf("Failed to check docker installation: %v.", err)
	}
	// Validate the command line arguments
	if len(flag.Args()) != 1 {
		log.Fatalf("Usage: %s [options] <go import path>", os.Args[0])
	}

	image := dockerDist + *goVersion
	if dockerImage != nil {
		image = *dockerImage
	}

	// Check that all required images are available
	found, err := checkDockerImage(image)
	switch {
	case err != nil:
		log.Fatalf("Failed to check docker image availability: %v.", err)
	case !found:
		fmt.Println("not found!")
		if err := pullDockerImage(image); err != nil {
			log.Fatalf("Failed to pull docker image from the registry: %v.", err)
		}
	default:
		fmt.Println("found.")
	}
	// Cross compile the requested package into the local folder
	if err := compile(flag.Args()[0], image, *srcRemote, *srcBranch, *inPackage, *crossDeps, *outPrefix, *buildVerbose, *buildSteps, *buildRace, *beforeBuildScript, strings.Split(*targets, ",")); err != nil {
		log.Fatalf("Failed to cross compile package: %v.", err)
	}
}

// Checks whether a docker installation can be found and is functional.
func checkDocker() error {
	fmt.Println("Checking docker installation...")
	if err := run(exec.Command("docker", "version")); err != nil {
		return err
	}
	fmt.Println()
	return nil
}

// Checks whether a required docker image is available locally.
func checkDockerImage(image string) (bool, error) {
	fmt.Printf("Checking for required docker image %s... ", image)
	out, err := exec.Command("docker", "images", "--no-trunc").Output()
	if err != nil {
		return false, err
	}
	return bytes.Contains(out, []byte(image)), nil
}

// Pulls an image from the docker registry.
func pullDockerImage(image string) error {
	fmt.Printf("Pulling %s from docker registry...\n", image)
	return run(exec.Command("docker", "pull", image))
}

// Cross compiles a requested package into the current working directory.
func compile(repo string, image string, remote string, branch string, pack string, deps string, prefix string, verbose bool, steps bool, race bool, beforeBuild string, targets []string) error {
	folder, err := os.Getwd()
	if err != nil {
		log.Fatalf("Failed to retrieve the working directory: %v.", err)
	}

	tmpDir, err := ioutil.TempDir(folder, "")
	if err != nil {
		log.Fatalf("Failed to create temporary directory: %v.", err)
	}
	defer func() {
		err := os.RemoveAll(tmpDir)
		if err != nil {
			log.Fatalf("Error removing temporary directory: %v.", err)
		}
	}()

	if len(beforeBuild) > 0 {
		err = os.Link(beforeBuild, filepath.Join(tmpDir, filepath.Base(beforeBuild)))
		if err != nil {
			log.Fatalf("Error linking script to temporary dir: %v.", err)
		}
	}
	fmt.Printf("Cross compiling %s...\n", repo)
	return run(exec.Command("docker", "run",
		"-v", folder+":/build",
		"-v", tmpDir+":/scripts",
		"-e", "REPO_REMOTE="+remote,
		"-e", "REPO_BRANCH="+branch,
		"-e", "PACK="+pack,
		"-e", "DEPS="+deps,
		"-e", "OUT="+prefix,
		"-e", fmt.Sprintf("FLAG_V=%v", verbose),
		"-e", fmt.Sprintf("FLAG_X=%v", steps),
		"-e", fmt.Sprintf("FLAG_RACE=%v", race),
		"-e", fmt.Sprintf("BEFORE_BUILD=%v", filepath.Base(beforeBuild)),
		"-e", "TARGETS="+strings.Replace(strings.Join(targets, " "), "*", ".", -1),
		image, repo))
}

// Executes a command synchronously, redirecting its output to stdout.
func run(cmd *exec.Cmd) error {
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
