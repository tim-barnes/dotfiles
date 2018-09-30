# vim:ft=zsh ts=2 sw=2 sts=2
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.

  SEGMENT_1_FG=black
  SEGMENT_2_FG=244
  SEGMENT_2_FG_A=184
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && fg="%F{$1}" || fg="%k"
  echo -n "%{$fg%}"
  [[ -n $3 ]] && echo -n " $3"
}

# End the prompt, closing any open segments
prompt_end() {
  echo -n "%{%f%}"
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(git status --porcelain 2> /dev/null | tail -n1)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment 014 black
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '\u2A01'
    zstyle ':vcs_info:*' unstagedstr '\u2692'
    zstyle ':vcs_info:*' formats ' %u%c '
    zstyle ':vcs_info:*' actionformats ' %u%c '
    vcs_info
    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

prompt_bzr() {
    (( $+commands[bzr] )) || return
    if (bzr status >/dev/null 2>&1); then
        status_mod=`bzr status | head -n1 | grep "modified" | wc -m`
        status_all=`bzr status | head -n1 | wc -m`
        revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment yellow black
            echo -n "bzr@"$revision "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment yellow black
                echo -n "bzr@"$revision

            else
                prompt_segment green black
                echo -n "bzr@"$revision
            fi
        fi
    fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev status
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green black
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment red black
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green black
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment 6 6 '%~ '
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path ]]; then
    prompt_segment 69 $SEGMENT_1_FG "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
  [[ $1 -ne 0 ]] && symbols+="%{%F{red}%}✘" || symbols+="%{%F{green}%}\u2714"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  
  prompt_segment black default "$symbols"
}

# Time
prompt_time() {
  prompt_segment 69 6 "%T"
}

prompt_kube() {
  prompt_segment 69 $SEGMENT_1_FG "\u2638 $(kubectl config current-context) "
}

prompt_history() {
  prompt_segment 6 6 "\ue0a1 %h"
}

prompt_docker_host() {
  [[ ! -z $DOCKER_MACHINE_NAME ]] && prompt_segment $SEGMENT_1_FG $SEGMENT_1_BG " \uf0ee $AZURE_RESOURCE_GROUP/$DOCKER_MACHINE_NAME "
}

# Returns the battery life
battery_level() {
  upower -i /org/freedesktop/UPower/devices/battery_BAT0 \
    | grep 'percentage' \
    | cut -d':' -f2 \
    | grep -o '[0-9]*'
}



prompt_battery() {
  local level bg battery

  level="$(battery_level)"

  [[ $level -le 20 ]] && \
    prompt_segment 9 white "B"
  
}


## Main prompt
build_prompt() {
  SEGMENT_SEPARATOR=$SEGMENT_SEPARATOR_L
  local result=$1

  local seg_1 seg_2 w_limit
  w_limit=$(($COLUMNS / 3))

  seg_1=$(
    prompt_virtualenv
    prompt_context
    prompt_dir
    prompt_git
    prompt_bzr
    prompt_hg
    prompt_kube
  )

  seg_2=$(prompt_history
    prompt_time
    prompt_battery
    prompt_status $result
    prompt_end
  )

  if [[ $(echo -n $seg_1 | wc -m) > $w_limit ]]; then 
    echo $seg_1
    echo -n $seg_2
  else
    echo -n $seg_1$seg_2
  fi
}


PROMPT='%{%f%b%k%}$(build_prompt $?) '
