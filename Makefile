# CodeGraph — build / test / package / verify
#
# Targets:
#   make build         Build a fully static musl binary (x86_64) via cargo-zigbuild
#   make build-native  Build the native (glibc) release binary via cargo
#   make test          Run the full Rust test suite
#   make package       Package the static binary into a release tar.gz
#   make verify        Check the binary is statically linked and runs
#   make clean         Remove build artifacts

BINARY      := codegraph
TARGET      := x86_64-unknown-linux-musl
VERSION     := $(shell grep '^version' Cargo.toml | head -1 | sed 's/.*"\(.*\)".*/\1/')
RELEASE_DIR := target/$(TARGET)/release
BIN_PATH    := $(RELEASE_DIR)/$(BINARY)
ARCHIVE     := $(BINARY)-$(VERSION)-$(TARGET).tar.gz

# sqlite-vec 0.1.6 uses BSD-style u_int*_t types that musl does not define;
# map them to the standard uint*_t so the C code compiles under musl.
MUSL_CFLAGS := -Du_int8_t=uint8_t -Du_int16_t=uint16_t -Du_int32_t=uint32_t -Du_int64_t=uint64_t

# cargo-zigbuild bundles/requires a `zig` compiler on PATH.
ZIG ?= zig

.PHONY: build build-native test package verify clean all

all: build

## Build a fully static x86_64 musl binary (runs on any glibc version)
build:
	@command -v $(ZIG) >/dev/null 2>&1 || { \
		echo "zig not found on PATH. Install it (e.g. download from ziglang.org/download)"; \
		echo "or run: cargo install cargo-zigbuild"; exit 1; }
	@command -v cargo-zigbuild >/dev/null 2>&1 || { \
		echo "cargo-zigbuild not found. Run: cargo install cargo-zigbuild"; exit 1; }
	CFLAGS="$(MUSL_CFLAGS)" cargo zigbuild --release --target $(TARGET) --no-default-features

## Build the native (glibc) release binary
build-native:
	cargo build --release --no-default-features

## Run the full test suite
test:
	cargo test --no-default-features

## Package the static binary into a release tar.gz
package: build
	@mkdir -p dist
	@cp "$(BIN_PATH)" dist/$(BINARY)
	@tar czf "dist/$(ARCHIVE)" -C dist "$(BINARY)"
	@rm -f dist/$(BINARY)
	@echo "Packaged: dist/$(ARCHIVE)"

## Verify the binary is statically linked and runs
verify:
	@test -x "$(BIN_PATH)" || { echo "Binary not found: $(BIN_PATH)"; echo "Run: make build"; exit 1; }
	@echo "file:   $$(file -b $(BIN_PATH))"
	@if ldd "$(BIN_PATH)" 2>&1 | grep -q "not a dynamic executable"; then \
		echo "link:   statically linked (no dynamic deps)"; \
	else \
		echo "link:   DYNAMIC — check ldd output:"; ldd "$(BIN_PATH)"; exit 1; \
	fi
	@"$(BIN_PATH)" --version

## Remove build artifacts
clean:
	cargo clean
	rm -rf dist
