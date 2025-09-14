# GitHub Actions Workflows

This directory contains 3 GitHub Actions workflows for the openwrt-config repository. These workflows provide comprehensive testing, automated dependency management, and release automation for OpenWrt firmware builds.

## Workflows

### 1. Build Check (`build-check.yml`)

**Purpose**: Validates OpenWrt configuration and builds for development.

**Triggers**:
- Push to main branch
- Pull requests to main branch
- Manual dispatch

**Features**:
- Checks flake validity and formatting
- Dry-run build validation (fast)
- Full build validation (comprehensive)
- Artifact upload for debugging (7-day retention)
- Build output verification

### 2. Build Release (`build-release.yml`)

**Purpose**: Creates production OpenWrt firmware builds for distribution.

**Triggers**:
- Release creation (automatic)
- Manual dispatch with artifact options

**Features**:
- Full production build
- Extended artifact retention (90 days)
- Automatic release asset upload
- Build metadata generation
- Comprehensive file uploads (sysupgrade, sdcard, bootloader files)

### 3. Update Dependencies (`update-dependencies.yml`)

**Purpose**: Automatically updates flake dependencies.

**Triggers**:
- Weekly schedule (Sundays at 1 AM UTC)
- Manual dispatch

**Features**:
- Updates all or specific dependencies
- Validates updated dependencies with build tests
- Creates pull requests with updates
- OpenWrt-specific dependency support

**Manual Inputs**:
- `update-type`: Type of update (all, nixpkgs, openwrt-imagebuilder)
- `create-pr`: Whether to create a pull request (default: true)

## Key Features

### OpenWrt-Specific Dependencies

The update dependencies workflow supports:
- **nixpkgs**: Core Nix packages
- **openwrt-imagebuilder**: OpenWrt ImageBuilder tool from astro/nix-openwrt-imagebuilder
- **all**: All dependencies

### Multi-Stage Build Validation

- **Dry-run builds**: Fast validation without full compilation
- **Full builds**: Complete validation with artifact generation
- **Output verification**: Checks for required firmware files
- **Format validation**: Ensures code quality standards

### Artifact Management

- **Build Check**: 7-day retention for debugging and development
- **Build Release**: 90-day retention for distribution and archival
- **Automated uploads**: Release assets automatically attached to GitHub releases

### Coordinated Scheduling

The workflow is scheduled to run before other repository updates:
- **1:00 AM UTC**: OpenWrt dependencies update
- **2:00 AM UTC**: Nix-config submodule updates  
- **3:00 AM UTC**: Main nix-config-private updates

This ensures fresh dependencies flow through the ecosystem.

## Usage

### Running Workflows Manually

1. Go to the Actions tab in your GitHub repository
2. Select the desired workflow
3. Click "Run workflow"
4. Configure inputs if needed
5. Click "Run workflow"

### Build Artifacts

After successful builds, firmware files are available as:
- **Sysupgrade image**: `*-sysupgrade.itb` (for existing installations)
- **SD card image**: `*-sdcard.img.gz` (for fresh installations) 
- **Bootloader files**: `*-preloader.bin`, `*-bl31-uboot.fip`
- **Checksums**: `sha256sums` for verification
- **Build info**: Metadata about the build process

### Release Process

1. Create a release tag in GitHub
2. Build Release workflow automatically triggers
3. Firmware files are built and attached to the release
4. Download firmware files from the release page

## Target Hardware

- **Primary**: Banana Pi BPI-R4 (`bpi-r4`)
- **Platform**: MediaTek MT7988A
- **Architecture**: ARM64

## Configuration

### Required Secrets

No additional secrets are required beyond the default `GITHUB_TOKEN`.

### Build Requirements

- **Platform**: x86_64-linux (ImageBuilder limitation)
- **Nix**: Experimental features (nix-command, flakes)
- **Cache**: Uses nix-community Cachix for faster builds
