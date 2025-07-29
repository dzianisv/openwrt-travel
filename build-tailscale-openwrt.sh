#!/bin/bash

# Tailscale OpenWrt Multi-Architecture Build Script
# Builds minimized Tailscale binaries for OpenWrt devices
# Supports: ARMv7, ARM64, MIPS Big-Endian, MIPS Little-Endian

set -euo pipefail

# Configuration
TAILSCALE_REPO="https://github.com/tailscale/tailscale.git"
BUILD_DIR="tailscale-build"
OUTPUT_DIR="binaries"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v go &> /dev/null; then
        missing_deps+=("go")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v upx &> /dev/null; then
        log_warning "UPX not found. Binaries will not be compressed."
        log_info "Install UPX with: brew install upx (macOS) or apt-get install upx (Ubuntu)"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    # Check Go version
    local go_version
    go_version=$(go version | grep -oE 'go[0-9]+\.[0-9]+' | sed 's/go//')
    local major_version
    major_version=$(echo "$go_version" | cut -d. -f1)
    local minor_version
    minor_version=$(echo "$go_version" | cut -d. -f2)
    
    if [ "$major_version" -lt 1 ] || ([ "$major_version" -eq 1 ] && [ "$minor_version" -lt 13 ]); then
        log_error "Go 1.13+ required, found Go $go_version"
        exit 1
    fi
    
    log_success "All dependencies satisfied (Go $go_version)"
}

# Clone or update Tailscale repository
setup_tailscale() {
    log_info "Setting up Tailscale source code..."
    
    cd "$SCRIPT_DIR"
    
    if [ -d "$BUILD_DIR" ]; then
        log_info "Updating existing Tailscale repository..."
        cd "$BUILD_DIR"
        git fetch origin
        git reset --hard origin/main
    else
        log_info "Cloning Tailscale repository..."
        git clone "$TAILSCALE_REPO" "$BUILD_DIR"
        cd "$BUILD_DIR"
    fi
    
    local commit_hash
    commit_hash=$(git rev-parse --short HEAD)
    log_success "Tailscale source ready (commit: $commit_hash)"
}

# Build function for a specific architecture
build_architecture() {
    local arch_name="$1"
    local goos="$2"
    local goarch="$3"
    local goarm="${4:-}"
    local gomips="${5:-}"
    
    log_info "Building for $arch_name..."
    
    cd "$SCRIPT_DIR/$BUILD_DIR"
    
    # Set environment variables
    export GOOS="$goos"
    export GOARCH="$goarch"
    export CGO_ENABLED=0
    
    if [ -n "$goarm" ]; then
        export GOARM="$goarm"
    fi
    
    if [ -n "$gomips" ]; then
        export GOMIPS="$gomips"
    fi
    
    local binary_name="tailscale-${arch_name}"
    
    # Build with symbol stripping and optimization
    if ! go build -trimpath -ldflags="-s -w" -tags ts_include_cli -o "$binary_name" ./cmd/tailscaled; then
        log_error "Failed to build for $arch_name"
        return 1
    fi
    
    # Compress with UPX if available
    if command -v upx &> /dev/null; then
        log_info "Compressing $arch_name binary with UPX..."
        if upx --lzma --best "$binary_name" 2>/dev/null; then
            log_success "Compressed $arch_name binary"
        else
            log_warning "UPX compression failed for $arch_name, keeping uncompressed binary"
        fi
    fi
    
    # Move to output directory
    mkdir -p "$SCRIPT_DIR/$OUTPUT_DIR"
    mv "$binary_name" "$SCRIPT_DIR/$OUTPUT_DIR/"
    
    local file_size
    file_size=$(ls -lh "$SCRIPT_DIR/$OUTPUT_DIR/$binary_name" | awk '{print $5}')
    log_success "Built $arch_name: $file_size"
}

# Verify binary architecture
verify_binary() {
    local binary_path="$1"
    local expected_arch="$2"
    
    if command -v file &> /dev/null; then
        local file_output
        file_output=$(file "$binary_path")
        log_info "Binary info: $(basename "$binary_path") - $file_output"
    fi
}

# Main build process
main() {
    log_info "Starting Tailscale OpenWrt Multi-Architecture Build"
    log_info "================================================="
    
    # Check dependencies
    check_dependencies
    
    # Setup Tailscale source
    setup_tailscale
    
    # Clean output directory
    rm -rf "$SCRIPT_DIR/$OUTPUT_DIR"
    mkdir -p "$SCRIPT_DIR/$OUTPUT_DIR"
    
    # Build for all architectures
    local build_start_time
    build_start_time=$(date +%s)
    
    log_info "Building binaries for all architectures..."
    
    # ARMv7 (32-bit ARM with hardware floating point)
    build_architecture "armv7" "linux" "arm" "7" ""
    
    # ARM64 (64-bit ARM)
    build_architecture "arm64" "linux" "arm64" "" ""
    
    # MIPS Big-Endian (32-bit MIPS with software floating point)
    build_architecture "mips" "linux" "mips" "" "softfloat"
    
    # MIPS Little-Endian (32-bit MIPS with software floating point)
    build_architecture "mipsle" "linux" "mipsle" "" "softfloat"
    
    local build_end_time
    build_end_time=$(date +%s)
    local build_duration=$((build_end_time - build_start_time))
    
    log_info "================================================="
    log_success "Build completed in ${build_duration}s"
    
    # Show final results
    log_info "Built binaries:"
    cd "$SCRIPT_DIR/$OUTPUT_DIR"
    for binary in tailscale-*; do
        if [ -f "$binary" ]; then
            verify_binary "$binary" "$(echo "$binary" | sed 's/tailscale-//')"
        fi
    done
    
    log_info ""
    log_info "Binary sizes:"
    ls -lh tailscale-* | awk '{print $9 ": " $5}'
    
    log_info ""
    log_info "Binaries are located in: $SCRIPT_DIR/$OUTPUT_DIR"
    log_success "All builds completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Tailscale OpenWrt Multi-Architecture Build Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --clean        Clean build directory and exit"
        echo ""
        echo "Supported architectures:"
        echo "  - ARMv7 (armv7)    : 32-bit ARM with hardware floating point"
        echo "  - ARM64 (arm64)    : 64-bit ARM"
        echo "  - MIPS (mips)      : 32-bit MIPS big-endian with software floating point"
        echo "  - MIPS LE (mipsle) : 32-bit MIPS little-endian with software floating point"
        echo ""
        echo "Requirements:"
        echo "  - Go 1.13 or newer"
        echo "  - git"
        echo "  - upx (optional, for compression)"
        exit 0
        ;;
    --clean)
        log_info "Cleaning build directory..."
        rm -rf "$SCRIPT_DIR/$BUILD_DIR"
        rm -rf "$SCRIPT_DIR/$OUTPUT_DIR"
        log_success "Cleaned build and output directories"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac