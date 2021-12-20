package main

import (
	"context"
	"log"

	"github.com/rhymond/ipfs/single/deployer"
)

func main() {
	ctx := context.Background()
	d := deployer.New()
	if err := d.Start(ctx); err != nil {
		log.Fatalf("unable to start ipfs go docker image: %s", err)
	}

	if _, err := d.Logs(ctx); err != nil {
		log.Fatalf("failed to get container logs: %s", err)
	}

}
