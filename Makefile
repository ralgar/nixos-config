NIXOS_CHANNEL = nixos-25.05

# Default Target: build and run the test VM, keeping any persistence.
.PHONY: run
run: build
	./result/bin/disko-vm

# Clear persistent data, then build and run a fresh test VM.
.PHONY: fresh
fresh: clean-persistence run

# Initialize Nix
.PHONY: init
init:
	sudo nix-channel --add https://nixos.org/channels/$(NIXOS_CHANNEL) nixpkgs
	sudo nix-channel --update

# Build test VM from Nixpkgs Stable channel
.PHONY: build
build:
	sudo nix build .#test-vm

# Build live ISO from Nixpkgs Stable channel
.PHONY: iso
iso:
	mkdir -p ./output
	sudo nix build .#live-iso
	sudo cp result/iso/*.iso ./output/

# Delete persistent test VM storage.
.PHONY: clean-persistence
clean-persistence:
	rm -f nixos.qcow2

# Clean up everything.
.PHONY: clean
clean: clean-persistence
	rm -rf ./output
	rm -f ./nixos-efi-vars.fd	# Delete stored UEFI variables
	rm -f ./result				# First, delete the symlink to the build.
	sudo nix-collect-garbage	# Now Nix will actually clean the build up.
