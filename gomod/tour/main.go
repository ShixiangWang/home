package main

import (
	"flag"
	"log"
)

func main() {
	var name string
	flag.StringVar(&name, "name", "Go tour", "help info")
	flag.Parse()

	log.Printf("name: %s", name)
}
