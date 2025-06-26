#!/usr/bin/env bash
#
# This script generates the file_permissions array for an archiso profiledef.sh
# It preserves a list of predefined exceptions and assigns a default
# owner:group:mode (1000:1000:644 for files, 1000:1000:755 for dirs)
# to all other files and directories within the airootfs.

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

# --- Main Script ---

# Define an associative array to hold the explicit permission definitions.
# These will be printed first and will be excluded from the general scan.
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

# --- Output Generation ---

# Start printing the Bash array definition
echo "file_permissions=("

# Print the explicit permissions first
echo "  # Predefined critical file permissions"
for path in "${!explicit_permissions[@]}"; do
  printf '  ["%s"]="%s"\n' "${path}" "${explicit_permissions[$path]}"
done
echo "" # Add a newline for readability

# Now, generate the rest
echo "  # Automatically generated default permissions (1000:1000)"
# Change directory to avoid complex path manipulation with sed/awk/etc.
cd "${AIROOTFS_DIR}" || exit

# Use find to list all files and directories starting from the current location (.)
find . -print0 | while IFS= read -r -d '' path; do
  # Remove the leading './' from find's output
  iso_path="${path#./}"
  # For the root directory itself, `find` outputs '.', which becomes an empty string.
  # We need to represent it as '/'.
  if [[ -z "$iso_path" ]]; then
      iso_path="/"
  else
      # Prepend the root slash for all other paths
      iso_path="/${iso_path}"
  fi

  # Check if the path is one of our explicit exceptions. If so, skip it.
  if [[ -v "explicit_permissions[${iso_path}]" ]]; then
    continue
  fi

  # Determine the permission mode based on type
  mode=""
  if [[ -d "$path" ]]; then
    mode="755"
  elif [[ -f "$path" ]]; then
    mode="644"
  else
    # Skip symlinks, block devices, etc.
    continue
  fi

  # Print the formatted line for the array
  printf '  ["%s"]="1000:1000:%s"\n' "${iso_path}" "${mode}"

done

# Print the closing parenthesis for the array
echo ")"
