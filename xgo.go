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
	"io"
	"log"
	"os"
	"os/exec"
)

// Cross compilation docker containers
var dockerBase = "karalabe/xgo-base"
var dockerDist = "karalabe/xgo-"

// Command line arguments to fine tune the compilation
var goVersion = flag.String("go", "latest", "Go release to use for cross compilation")

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
	// Check that all required images are available
	found, err := checkDockerImage(dockerDist + *goVersion)
	switch {
	case err != nil:
		log.Fatalf("Failed to check docker image availability: %v.", err)
	case !found:
		fmt.Println("not found!")
		if err := pullDockerImage(dockerDist + *goVersion); err != nil {
			log.Fatalf("Failed to pull docker image from the registry: %v.", err)
		}
	default:
		fmt.Println("found.")
	}
	// Cross compile the requested package into the local folder
	if err := compile(flag.Args()[0]); err != nil {
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
	fmt.Printf("Note, this may take some time, but due to a docker bug, progress cannot be displayed.\n")
	return run(exec.Command("docker", "pull", image))
}

// Cross compiles a requested package into the current working directory.
func compile(path string) error {
	folder, err := os.Getwd()
	if err != nil {
		log.Fatalf("Failed to retrieve the working directory: %v.", err)
	}
	fmt.Printf("Cross compiling %s...\n", path)
	if err := run(exec.Command("docker", "run", "-v", folder+":/build", dockerDist+*goVersion, path)); err != nil {
		return err
	}
	return nil
}

// Executes a command synchronously, redirecting its output to stdout.
func run(cmd *exec.Cmd) error {
	if out, err := cmd.StdoutPipe(); err != nil {
		return err
	} else {
		go io.Copy(os.Stdout, out)
	}
	if out, err := cmd.StderrPipe(); err != nil {
		return err
	} else {
		go io.Copy(os.Stderr, out)
	}
	return cmd.Run()
}
