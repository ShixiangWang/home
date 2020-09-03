package main

import (
	"flag"
	"log"
)

func main() {
	var name string
	flag.Parse()
	goCmd := flag.NewFlagSet("go", flag.ExitOnError)
	goCmd.StringVar(&name, "name", "Golang", "Help info")
	phpCmd := flag.NewFlagSet("php", flag.ExitOnError)
	phpCmd.StringVar(&name, "n", "Php", "Help info")

	args := flag.Args()
	switch args[0] {
	case "go":
		_ = goCmd.Parse(args[1:])
	case "php":
		_ = phpCmd.Parse(args[1:])
	}

	log.Printf("name: %s", name)
}
