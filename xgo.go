// Go CGO cross compiler
// Copyright (c) 2014 Péter Szilágyi. All rights reserved.
//
// Released under the MIT license.

// Wrapper around the GCO cross compiler docker container.
package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
)

// Docker container configured for cross compilation.
var container = "karalabe/xgo"

func main() {
	// Make sure docker is actually available on the system
	fmt.Println("Checking docker installation...")
	if err := run(exec.Command("docker", "version")); err != nil {
		log.Fatalf("Failed to check docker installation: %v.", err)
	}
	fmt.Println()

	// Fetch and configure the compilation settings
	if len(os.Args) != 2 {
		log.Fatalf("Usage: %s <go import path>", os.Args[0])
	}
	path := os.Args[1]
	pwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("Failed to retrieve the working directory: %v.", err)
	}
	// Cross compile the requested package into the local folder
	fmt.Printf("Cross compiling %s...", path)
	if err := run(exec.Command("docker", "run", "-v", pwd+":/build", container, path)); err != nil {
		log.Fatalf("Failed to cross compile package: %v.", err)
	}
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
