// Go cross compiler (xgo): Test implementation for embedded C++ snippets.
// Copyright (c) 2015 Péter Szilágyi. All rights reserved.
//
// Released under the MIT license.

#include <iostream>
#include "snippet.h"

void sayHi() {
  std::cout << "Hello, embedded C++!" << std::endl;
}
