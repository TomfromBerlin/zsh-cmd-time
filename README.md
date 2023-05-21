# zsh-cmd-time

| ![Views](https://img.shields.io/endpoint?color=green&label=Views&logoColor=red&style=plastic&url=https%3A%2F%2Fhits.dwyl.com%2FTomfromBerlin%2Fzsh-cmd-time) | ![Unique Viewers](https://img.shields.io/endpoint?color=green&label=Unique%20Viewers&logoColor=pink&style=plastic&url=https%3A%2F%2Fhits.dwyl.com%2FTomfromBerlin%2Fzsh-cmd-time%3Fshow%3Dunique) | ![https://img.shields.io/github/license/TomfromBerlin/zsh-cmd-time?style=plastic](https://img.shields.io/github/license/TomfromBerlin/zsh-cmd-time?style=plastic)||
|-|-|-|-|

![zsh-cmd-time_test](https://github.com/TomfromBerlin/zsh-cmd-time/assets/123265893/622a5f14-e2e0-40a1-9a6a-58a91d142d5c)

## Introduction

Actually, this is a fork of [zsh-command-time plugin](https://github.com/popstas/zsh-command-time) made by [Stanislav Popov](https://github.com/popstas), who honestly seems to be a much more talented developer than me.

I created this fork because I wanted to have a display of the command execution time in my RPS1, but I do not want to use frameworks like antigen or powerlevel9k/p10k, although they are good and sophisticated frameworks for the Z shell.

After a while I thought it would be nice to have a display of fractions of seconds for short commands, so I created my own based on the [zsh-command-time plugin](https://github.com/popstas/zsh-command-time).

When I was 53 commits ahead of [zsh-command-time plugin](https://github.com/popstas/zsh-command-time), the code between the two branches differed greatly and it would break [zsh-command-time plugin](https://github.com/popstas/zsh-command-time) if it were merged with my code. In addition, his repository no longer seems to be maintained, so I decided to decouple this repository from its origin and create a standalone repository. Nevertheless, popstas deserves most of the credits, because without his code, zsh-cmd-time would not exist at all.

#### What distinguish this fork from the original?

<details><summary>...</summary>
One is that the original is probably bash-compatible. Unfortunately, this is not possible with this repository without bloating the code. That is, this plugin runs only with the Z Shell without any problems.

The orignal plugin, on the other hand, only displays whole seconds. This fork __can__ display fractions of seconds. It's up to you whether you want that or not.

In addition, the original is somewhat easier to configure with regard to the color scheme and the output whether very short program execution times should be displayed.
</details>

## Description of zsh-cmd-time

`zsh-cmd-time` is a plugin that outputs the execution time of commands and exports the result to a variable that can be used elsewhere. It is similar to the built-in [REPORTTIME](http://zsh.sourceforge.net/Doc/Release/Parameters.html) function, but it is also slightly different.

`REPORTTIME` is a nifty feature of zsh. If you set it to a non-negative value, then every time, any command you run that takes longer than the value you set it to in seconds, zsh will print usage statistics afterwards as if you had run the command prefixed with `time`. Well, almost every time.

The following screenshot shows two measurements, both with `REPORTTIME=3`, but `REPORTTIME` itself remains silent. The output would look like that of the second measurement but that comes from `time` command. (Just ignore the right prompt at this point.)

![reporttime](https://user-images.githubusercontent.com/123265893/232536349-55ca37e6-7fdf-45dc-93bb-6a4cf9bcd14a.png)

As mentioned before `REPORTTIME` has been set to `REPORTTIME=3` (seconds) and one would expect a response by `REPORTTIME`. However, `sleep` does not consume any CPU time and `REPORTTIME` does not recognize such idle commands. Here `zsh-cmd-time` comes into play. As you can see, the right prompt shows the execution time regardless of whether CPU time was consumed or not and this is the plugin at work.

So if you want to monitor CPU-consuming commands only, you should use `REPORTTIME` instead of this plugin.

_At this point, it is probably worth mentioning that the measured times do vary, especially with many decimal places, even if the same program is executed twice directly in succession. Well, the measurement is not done with a high precision clock, but with a computer with many different components of hardware and software, which can influence the results differently at different times. In addition, there are rounding errors, which are unavoidable due to the way floating point numbers are handled in a digital environment. For this reason, the measured times are to be understood rather as approximate values. If desired, it is recommended to perform a series of measurements from which an average value can then be calculated._

## Installation

My first recommendation is: don't use a plugin manager or framework at all if you only want to use a few plugins to improve your daily zsh experience. Instead you can use [zsh_unplugged](/../../../../TomfromBerlin/zsh_unplugged). zsh_unplugged just contains around 20 lines of code. All you need is adding a few lines to your .zshrc-file:

<details><summary>Code</summary>
    
    ```
    # ZSH UNPLUGGED start (first part)
    # where do you want to store your plugins?
    ZPLUGINDIR=${ZDOTDIR:-~/.config/zsh}/plugins
    # get zsh_unplugged and store it with your other plugins
    if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
      git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
    fi
    source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh
    
    # make list of the Zsh plugins you use (the order of the list can be important, it depends on the plugins used)
    repos=(
        $ZPLUGINDIR/zsh-enhanced-completion # this is a local plugin
        TomfromBerlin/zsh-cmd-time # this plugun will be cloned from Github
        )
    # ZSH UNPLUGGED end (first part)
    ```
    
    and before `autoload -Uz promptinit && promptinit`, add
    
    ```
    # ZSH UNPLUGGED start (second part)
    plugin-load $repos
    # ZSH UNPLUGGED end (second part)
    ```
</details>

**For output with decimal places you have to put `typeset -F SECONDS` into your .zshrc, otherwise there are only zeros as decimal places.**

You may want to consider to run the script [zrecompile](/../../../../TomfromBerlin/mothers-little-helpers/blob/main/helpers/scripts/misc/zrecompile) to compile all the zsh-dot-files to give your shell another performance boost. A descrption of what the script does can be found within the source file. The line `autoload -Uz [$HOME]/path/to/script/zrecompile`, placed somewhere in your .zshcr, may be helpful when (re)running the script, e.g. after changing dot-files.

**❗ This plugin will replace your RPS1 definition. To avoid this, remove the strings below and add ${elapsed} or ${timer_show} to your RPS1. ❗**

```zsh
RPS1='%(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
RPS1='${elapsed} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
```

Of course, you can use it in your PS1. At this point, it is quite helpful to have a little knowledge about how to customize the prompt. If you only want to see the execution time without prefixed text you can use the `timer_show` variable.

### Install with other plugin managers/frameworks

<details><summary>show instructions</summary>
    
#### [zplugin](/../../../../TomfromBerlin/zplugin)

This is the second best recommendation I can give. Zplugin is relatively fast and offers a few convenient functions around plugin management.

At first you need to install [zplugin](/../../../../TomfromBerlin/zplugin). To do this perform the following steps:

```
mkdir ~/.zplugin
git clone https://github.com/TomfromBerlin/zplugin.git ~/.zplugin/bin # The original "zplugin" plugin manager repository no longer exists. Be aware that there is no support for "zplugin".
```

and add

```
source ~/.zplugin/bin/zplugin.zsh # should be called before compinit
zmodload zsh/complist # should be called before compinit, the directory `zsh` should be in your $FPATH
```

before loading completion settings as well as

```
autoload -Uz compinit && compinit -C -d ${zdumpfile}
zplugin cdreplay -q # -q is for quiet
```

after loading completion settings.

Then add `zplugin load TomfromBerlin/zsh-cmd-time` to your `.zshrc` to install the cmd-time plugin. Best practice: place it before your prompt definitions. Next time you start a terminal [zplugin](/../../../../TomfromBerlin/zplugin) downloads the plugin and compiles it with zcompile, giving your shell a noticeable performance boost.

#### Install with [antigen](/../../../../zsh-users/antigen)

```zsh
antigen bundle TomfromBerlin/zsh-cmd-time
```

#### Install for [oh my zsh](/../../../../ohmyzsh/ohmyzsh)

Download:

```zsh
git clone https://github.com/TomfromBerlin/zsh-cmd-time.git ~/.oh-my-zsh/custom/plugins/cmd-time
```

And add `cmd-time` to `plugins` in `.zshrc`.

#### Usage with [powerlevel9k](/../../../../bhilburn/powerlevel9k) theme

❗ **To make it short: Do not use this plugin with powerlevel9k/p10k** ❗ 

powerlevel9k as of v0.6.0 has a [native segment of command_execution_time](/../../../../bhilburn/powerlevel9k#command_execution_time), so you can easily add it to your prompt:

`POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs vcs command_execution_time time)`

</details>

## Configuration

You do not need to configure the plugin. It should run out of the box. But you can override some defaults in `.zshrc`:

```zsh
# Pefixed message to display (set to "" for disable).
ZSH_CMD_TIME_MSG="took %s"

# Exclude some commands
ZSH_CMD_TIME_EXCLUDE=(clear cls man mc mcedit nano ranger vim)
```

### Customization

You can also customize the output of the plugin by redefining the zsh_command_time function. Here are two examples of custom definitions.

The configuration below can handle floating point numbers and will display decimal places for short commands:

- 6 decimal places when exec time is < 1 second
- 3 decimal places when exec time is between 1 second and 60 seconds

_Have a look at the code snippet for explanation how to change the number of the decimal places._

Longer execution times will be displayed as "mm:ss", or "hh:mm:ss" respectively. When execution time is above 60 seconds, neither milliseconds nor nanoseconds are displayed.

#### Output with colors (default configuration)

```zsh
zsh_cmd_time() {
    if [[ -n "$timer_show" ]]; then
# we leave the handling of floating point numbers to bc --> https://www.gnu.org/software/bc/manual/html_mono/bc.html
        h=$(bc <<< "${timer_show}/3600") && m=$(bc <<< "(${timer_show}%3600)/60") && s=$(bc <<< "${timer_show}%60")
        if [[ "$timer_show" -le 1 ]]; then ZSH_CMD_TIME_COLOR="magenta" && timer_show=$(printf '%.6f'" sec" "$timer_show")
        elif [[ "$timer_show" -le 60 ]]; then ZSH_CMD_TIME_COLOR="green" && timer_show=$(printf '%.3f'" sec" "$timer_show")
        elif [[ "$timer_show" -gt 60 ]] && [[ "$timer_show" -le 180 ]]; then ZSH_CMD_TIME_COLOR="cyan" && timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        elif [[ "$h" -gt 0 ]]; then m=$((m%60)) && ZSH_CMD_TIME_COLOR="red" && timer_show=$(printf '%02dh:%02dm:%02ds' $((h)) $((m)) $((s))); else ZSH_CMD_TIME_COLOR="yellow" && timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        fi
          elapsed=$(echo -e "%F{$ZSH_CMD_TIME_COLOR}$(printf '%s' "${ZSH_CMD_TIME_MSG}"" $timer_show")%f")
          export elapsed
          RPS1='${elapsed} ${vcs_info_msg_0_} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
    fi
}
```

The output on the right prompt in the Z shell looks like this:

![zsh-cmd-time](https://user-images.githubusercontent.com/123265893/232322193-3d9ad194-1d30-4415-83b5-29c4093c7fae.png)

You can change the colors, too. Just look for `"cyan"`, `"green"`, `"magenta"`, `"red"`, and `"yellow"` and replace it with your desired colors. Double quotes are required.

| Annotation |
|:-|
| When using `print -P` in the right prompt of the Z shell with the above configuration, it happened that the output was severely out of place. Unfortunately, `print -P` moves the right prompt towards the center of the window and I haven not found a solution for this yet, except to replace `print -P` with `echo -e`. Maybe this is the only solution, who knows. I tried to fix it with `%{$elapsed%}`, but that moves RPS1 too much to the right and then causes an unwanted line break. So there is a mix of `echo -e` and `printf` on one line, which looks pretty stupid - but works and even [shellcheck](https://www.shellcheck.net/) do not complain. |

#### Output without colors

```zsh
zsh_cmd_time() {
    if [[ -n "$ZSH_CMD_TIME" ]]; then
# we leave the handling of floating point numbers to bc --> https://www.gnu.org/software/bc/manual/html_mono/bc.html
        h=$(bc <<< "${timer_show}/3600") && m=$(bc <<< "(${timer_show}%3600)/60") && s=$(bc <<< "${timer_show}%60")
        if [[ "$ZSH_CMD_TIME" -le 1 ]]; then timer_show=$(printf %.6f" sec" "$ZSH_CMD_TIME")
        elif [[ "$ZSH_CMD_TIME" -le 60 ]]; then timer_show=$(printf %.3f" sec" "$ZSH_CMD_TIME")  # for explanation of "%.nf" see configuration example above
        elif [[ "$h" -gt 0 ]]; then m=$((m%60)) && timer_show=$(printf '%dh:%02dm:%02ds' $((h)) $((m)) $((s)))
        else timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        fi
        elapsed=$(printf '%s' "${ZSH_CMD_TIME_MSG}"" $timer_show")
        export elapsed
        RPS1='${elapsed} ${vcs_info_msg_0_} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
    fi
}
```

_And now have fun and be nice to each other._
