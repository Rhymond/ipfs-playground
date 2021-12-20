package swarmkey

import (
	"crypto/rand"
	"encoding/hex"
	"log"
)

func Generate() string {
	key := make([]byte, 32)
	_, err := rand.Read(key)
	if err != nil {
		log.Fatalln("unable to read random source:", err)
	}

	return "/key/swarm/psk/1.0.0/\n/base16/\n" + hex.EncodeToString(key)
}
