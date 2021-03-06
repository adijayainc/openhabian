#!/usr/bin/env bash

# Attention: This file will be sourced earlier than all others

# Colors for later use
ESC="\\033["
COL_DEF=$ESC"39;49;00m"
COL_RED=$ESC"31;01m"
COL_GREEN=$ESC"32;01m"
COL_YELLOW=$ESC"33;01m"
COL_BLUE=$ESC"34;01m"
COL_MAGENTA=$ESC"35;01m"
COL_CYAN=$ESC"36;01m"
COL_LGRAY=$ESC"37;01m"
COL_DGRAY=$ESC"90;01m"
export COL_DEF COL_RED COL_GREEN COL_YELLOW COL_BLUE COL_MAGENTA COL_CYAN COL_LGRAY COL_DGRAY

cond_redirect() {
  if [ -n "$SILENT" ]; then
    "$@" &>/dev/null
    return $?
  else
    echo -e "\\n$COL_DGRAY\$ $* $COL_DEF"
    "$@"
    return $?
  fi
}

cond_echo() {
  if [ -z "$SILENT" ]; then
    echo -e "$COL_YELLOW$*$COL_DEF"
  fi
}

## Add keys to apt for new package sources
## Valid Arguments: URL
##
##    add_keys(String url)
##
add_keys() {
	  local repoKey
	  
  repoKey="$(mktemp /tmp/openhabian.XXXXX)"
  
  echo -n "$(timestamp) [openHABian] Adding required keys to apt... "
  cond_redirect wget -qO "$repoKey" "$1"
  if cond_redirect apt-key add "$repoKey"; then
    echo "OK"
    rm -f "$repoKey"
  else
    echo "FAILED"
    rm -f "$repoKey"
    return 1;
  fi
}

# fingerprinting based on
# https://www.raspberrypi.org/documentation/hardware/raspberrypi/revision-codes/README.md
is_pizero() {
  # shellcheck disable=SC2154
  if [[ "$hw" == "pi0" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]09[0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_pizerow() {
  if [[ "$hw" == "pi0w" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]0[cC][0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_pione() {
  if [[ "$hw" == "pi1" ]]; then return 0; fi
  if grep -q "^Revision\\s*:\\s*00[0-9a-fA-F][0-9a-fA-F]$" /proc/cpuinfo; then
    return 0
  elif grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]0[0-36][0-9a-fA-F]$" /proc/cpuinfo; then
    return 0
  else
    return 1
  fi
}
is_cmone() {
  # shellcheck disable=SC2154
  if [[ "$hw" == "cm1" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]06[0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_pitwo() {
  if [[ "$hw" == "pi2" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]04[0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_pithree() {
  if [[ "$hw" == "pi3" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]08[0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_cmthree() {
  if [[ "$hw" == "cm3" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]0[aA][0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_pithreeplus() {
  if [[ "$hw" == "pi3+" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]0[dDeE][0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_cmthreeplus() {
  if [[ "$hw" == "cm3+" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]10[0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_pifour() {
  if [[ "$hw" == "pi4" ]]; then return 0; fi
  grep -q "^Revision\\s*:\\s*[ 123][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]11[0-9a-fA-F]$" /proc/cpuinfo
  return $?
}
is_pi() {
  if is_pizero || is_pizerow || is_pione || is_cmone || is_pitwo || is_pithree || is_cmthree || is_pithreeplus || is_cmthreeplus || is_pifour; then return 0; fi
  return 1
}
is_pine64() {
  [[ $(uname -r) =~ "pine64-longsleep" ]]
  return $?
}
is_arm() {
  if is_armv6l || is_armv7l || is_aarch64; then return 0; fi
  return 1;
}
is_arm64() {
  # shellcheck disable=SC2154
  if [[ "$hwarch" == "arm64" ]]; then return 0; fi
  case "$(uname -m)" in
    arm64) return 0 ;;
    *) return 1 ;;
  esac
}
is_armv6l() {
  if [[ "$hwarch" == "armv6l" ]]; then return 0; fi
  case "$(uname -m)" in
    armv6l) return 0 ;;
    *) return 1 ;;
  esac
}
is_armv7l() {
  if [[ "$hwarch" == "armv7l" ]]; then return 0; fi
  case "$(uname -m)" in
    armv7l) return 0 ;;
    *) return 1 ;;
  esac
}
is_aarch64() {
  if [[ "$hwarch" == "aarch64" ]] || [[ "$hwarch" == "arm64" ]]; then return 0; fi
  case "$(uname -m)" in
    aarch64|arm64) return 0 ;;
    *) return 1 ;;
  esac
}
is_x86_64() {
  if [[ "$hwarch" == "x86_64" ]] || [[ "$hwarch" == "amd64" ]]; then return 0; fi
  case "$(uname -m)" in
    x86_64|amd64) return 0 ;;
    *) return 1 ;;
  esac
}
is_ubuntu() {
  # shellcheck disable=SC2154
  if [[ "$release" == "ubuntu" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "Ubuntu" ]]
  return $?
}
is_debian() {
  if [[ "$release" == "debian" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "Debian" ]]
  return $?
}
is_raspbian() {
  if [[ "$release" == "raspbian" ]]; then return 0; fi
  [[ "$(cat /etc/*release*)" =~ "Raspbian" ]]
  return $?
}
# Debian/Raspbian, to be deprecated, LTS ends 2020-06-30
is_jessie() {
  if [[ "$release" == "jessie" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "jessie" ]]
  return $?
}
# Debian/Raspbian oldstable
is_stretch() {
  if [[ "$release" == "stretch" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "stretch" ]]
  return $?
}
# Debian/Raspbian stable
is_buster() {
  if [[ "$release" == "buster" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "buster" ]]
  return $?
}
# Debian/Raspbian testing
is_bullseye() {
  if [[ "$release" == "bullseye" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "bullseye" ]]
  return $?
}
# Debian/Raspbian unstable
is_sid() {
  if [[ "$release" == "sid" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "sid" ]]
  return $?
}
# Ubuntu 14, to be deprecated
is_trusty() {
  if [[ "$release" == "trusty" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "trusty" ]]
  return $?
}
# Ubuntu 16
is_xenial() {
  if [[ "$release" == "xenial" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "xenial" ]]
  return $?
}
# Ubuntu 18.04 LTS
is_bionic() {
  if [[ "$release" == "bionic" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "bionic" ]]
  return $?
}
# Ubuntu 20.04 LTS
is_focal() {
  if [[ "$release" == "focal" ]]; then return 0; fi
  [[ $(cat /etc/*release*) =~ "focal" ]]
  return $?
}
running_in_docker() {
  grep -q 'docker\|lxc' /proc/1/cgroup
}
running_on_github() {
  [[ -n "$GITHUB_RUN_ID" ]]
  return $?
}
tryUntil() {
  # tryUntil() executes $1 as command
  # either $2 times or until cmd evaluates to 0, sleeps $3 seconds inbetween
  # returns the number of cmd runs that would have been left
  cmd="$1"
  count=${2:-10}
  local i=$count
  interval=${3:-1}
  until [ "$i" -le 0 ]; do
    cond_echo "(executing ${cmd}) ${COL_DEF}\c"
    eval "${cmd}"
    ret=$?
    if [ $ret -eq 0 ]; then break; fi
    sleep "${interval}"
    echo -n ".${i}."
    ((i-=1))
  done
  return "$i"
}
has_lowmem() {
  totalmemory=$(grep MemTotal /proc/meminfo |awk '{print $2}')
  if [ "${totalmemory:-1000000}" -lt 900000 ]; then return 0; else return 1; fi
}
