.PHONY: test container-test clean

test:
	zunit

container-test:
	podman build -t z4b-test -f Containerfile.test .
	podman run --rm z4b-test zsh /root/zsh4bermudi/container-smoke.zsh

clean:
	rm -rf .zcompdump
