#!/usr/bin/env bash
#
# This script generates a partial file_permissions array for profiledef.sh.
# It includes a predefined list of root-owned files and then generates
# 1000:1000 permissions ONLY for the contents of specific directories.

set -euo pipefail

# --- Configuration ---

# The profile directory (e.g., 'releng') should be passed as the first argument.
if [[ -z "${1-}" ]]; then
  echo "Usage: $0 <path_to_profile_dir>" >&2
  echo "Example: $0 releng" >&2
  exit 1
fi

PROFILE_DIR="$1"
AIROOTFS_DIR="${PROFILE_DIR}/airootfs"

if [[ ! -d "$AIROOTFS_DIR" ]]; then
  echo "Error: airootfs directory not found at '${AIROOTFS_DIR}'" >&2
  exit 1
fi

# 1. Define the explicit, root-owned permissions that should always be present.
declare -A explicit_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)

# 2. Define the specific ISO paths to process for 1000:1000 ownership.
declare -a target_iso_dirs=(
    "/home/cilgin"
    "/usr/share/themes"
    "/usr/share/icons"
)

# --- Output Generation ---

# Start printing the Bash array definition
echo "file_permissions=("

# Print the explicit permissions first
echo "  # Predefined critical file permissions (owned by root)"
for path in "${!explicit_permissions[@]}"; do
  printf '  ["%s"]="%s"\n' "${path}" "${explicit_permissions[$path]}"
done
echo "" # Add a newline for readability

# Now, process ONLY the target directories
echo "  # Automatically generated permissions for user-specific directories (owned by 1000:1000)"

# Loop through each target directory
for iso_dir in "${target_iso_dirs[@]}"; do
    fs_path="${AIROOTFS_DIR}${iso_dir}"

    # Safely skip if the directory doesn't exist in the airootfs
    if [[ ! -d "${fs_path}" ]]; then
        echo "  # Info: Skipping non-existent directory: ${iso_dir}" >&2
        continue
    fi

    # Use find to scan the specific directory and its contents
    find "${fs_path}" -print0 | while IFS= read -r -d '' full_path; do
        # Convert the full filesystem path to the required path within the ISO
        iso_path="${full_path#${AIROOTFS_DIR}}"

        # Determine the permission mode based on type (directory or file)
        mode=""
        if [[ -d "$full_path" ]]; then
            mode="755"
        elif [[ -f "$full_path" ]]; then
            mode="644"
        else
            # Skip symlinks, sockets, etc. as they don't get explicit perms this way
            continue
        fi

        # Print the formatted line for the array
        printf '  ["%s"]="1000:1000:%s"\n' "${iso_path}" "${mode}"
    done
done

# Print the closing parenthesis for the array
echo ")"
