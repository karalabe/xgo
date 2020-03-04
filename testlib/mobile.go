package testlib

// #include <stdio.h>
//
// void sayHi() {
//   printf("Hello, embedded C!\n");
// }
import "C"

func HelloWorld() string {
	C.sayHi()
	return "Hello"
}
