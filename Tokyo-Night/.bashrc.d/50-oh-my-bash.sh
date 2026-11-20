# shellcheck shell=bash disable=SC2034
# Tokyo Night prompt (oh-my-bash "duru"), installed read-only in /usr/share/oh-my-bash
[[ $- == *i* ]] || return 0
export OSH=/usr/share/oh-my-bash
[[ -r $OSH/oh-my-bash.sh ]] || return 0
OSH_THEME="duru"
DISABLE_AUTO_UPDATE="true"   # /usr is read-only
completions=(git ssh)
aliases=(general)
plugins=(git bashmarks)
# shellcheck source=/dev/null
source "$OSH/oh-my-bash.sh"
