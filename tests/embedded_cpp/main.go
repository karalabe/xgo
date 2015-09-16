// Go cross compiler (xgo): Test file for embedded C++ snippets.
// Copyright (c) 2015 Péter Szilágyi. All rights reserved.
//
// Released under the MIT license.

package main

// #include "snippet.h"
import "C"

func main() {
	C.sayHi()
}
