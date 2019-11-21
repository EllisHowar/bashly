# ---
# Config handling functions
# This file is a part of bashly's standard library functions.
#
# Usage:
# - In your script, set the CONFIG_FILE variable. For rxample:
#   CONFIG_FILE=config.ini
# - Use any of the functions below to access the config file.
# ---

# Create a new config file.
# There is normally no need to use this fucntion, it is used by othe rfunctions
# as needed.
config_init() {
  CONFIG_FILE=${CONFIG_FILE:=config.ini}
  [[ -f "$CONFIG_FILE" ]] || touch "$CONFIG_FILE"
}

# Get a value from the config
# Usage: result=$(config_get hello)
config_get() {
  key=$1
  regex="^$key\s*=\s*(.+)$"

  config_init
  
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ $regex ]]; then
      value="${BASH_REMATCH[1]}"
      break
    fi
  done < "$CONFIG_FILE"

  echo "$value"
}

# Add or update a key=value pair in the config.
# Usage: config_set key value
config_set() {
  key=$1
  shift
  value="$*"

  config_init

  regex="^($key)\s*=\s*.+$"
  output=""
  found_key=""
  
  while IFS= read -r line || [ -n "$line" ]; do
    newline=$line
    if [[ $line =~ $regex ]]; then
      found_key="${BASH_REMATCH[1]}"
      newline="$key = $value"
      output="$output$newline\n"
    elif [[ $line ]]; then
      output="$output$line\n"
    fi
  done < "$CONFIG_FILE"

  if [[ -z $found_key ]]; then
    output="$output$key = $value\n"
  fi

  echo -e "$output" > "$CONFIG_FILE"
}

# Delete a key from teh config.
# Usage: config_del key
config_del() {
  key=$1

  regex="^($key)\s*="
  output=""

  config_init

  while IFS= read -r line || [ -n "$line" ]; do
    newline=$line
    if [[ $line ]] && [[ ! $line =~ $regex ]]; then
      output="$output$line\n"
    fi
  done < "$CONFIG_FILE"

  echo -e "$output" > "$CONFIG_FILE"
}

# Show the config file
config_show() {
  config_init
  cat "$CONFIG_FILE"
}