.PHONY: test container-test clean

test:
	zunit

container-test:
	podman build -t z4b-test -f Containerfile.test .
	podman run --rm z4b-test -c 'echo "SMOKE_OK"'

clean:
	rm -rf .zcompdump
