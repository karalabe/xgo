package testlib

import (
	"fmt"

	"github.com/mysteriumnetwork/go-openvpn/openvpn3"
)

func HelloWorld() string {
	config := openvpn3.NewConfig("test")
	fmt.Println(config)
	return "Hello"
}
