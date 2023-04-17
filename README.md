# zsh-cmd-time

| ![Views](https://img.shields.io/endpoint?color=green&label=Views&logoColor=red&style=plastic&url=https%3A%2F%2Fhits.dwyl.com%2FTomfromBerlin%2Fzsh-cmd-time) | ![Unique Viewers](https://img.shields.io/endpoint?color=green&label=Unique%20Viewers&logoColor=pink&style=plastic&url=https%3A%2F%2Fhits.dwyl.com%2FTomfromBerlin%2Fzsh-cmd-time%3Fshow%3Dunique) |
|-|-|

## Introduction

Actually, this is a fork of [zsh-command-time plugin](https://github.com/popstas/zsh-command-time) made by [Stanislav Popov](https://github.com/popstas), who honestly seems to be a much more talented developer than me.

I created this fork because I wanted to have a display of the command execution time in my RPS1, but I do not want to use frameworks like antigen or powerlevel9k/p10k, although they are good and sophisticated frameworks for the Z shell.

After a while I thought it would be nice to have a display of fractions of seconds for short commands and I startet to search for a ready-to-use solution. I did not found any, so I created my own based on the [zsh-command-time plugin](https://github.com/popstas/zsh-command-time).

When I was 53 commits ahead of [zsh-command-time plugin](https://github.com/popstas/zsh-command-time), the code between the two branches differed greatly and it would break [zsh-command-time plugin](https://github.com/popstas/zsh-command-time) if it were merged with my code. In addition, his repository no longer seems to be maintained, so I decided to decouple this repository from its origin and create a standalone repository. Nevertheless, popstas deserves most of the credits, because without his code, zsh-cmd-time would not exist at all.

## What distinguish this fork from the original?

One is that the original is bash-compatible. Unfortunately, this is not possible with this repository without bloating the code. That is, this plugin runs only with the Z Shell without any problems.

The orignal plugin, on the other hand, only displays whole seconds. This fork __can__ display fractions of seconds. It's up to you whether you want that or not.

In addition, the original is somewhat easier to configure with regard to the color scheme and the output whether very short program execution times should be displayed.

## Installation

If you want to use zsh-cmd-time I recommend using [zplugin](/../../../../TomfromBerlin/zplugin) to load this plugin. [zplugin](/../../../../TomfromBerlin/zplugin) is small and you have full control over which plugins to load. To install [zplugin](/../../../../TomfromBerlin/zplugin) perform the following steps:

```
mkdir ~/.zplugin
git clone https://github.com/psprint/zplugin.git ~/.zplugin/bin
```
and then add

```zsh
zplugin load TomfromBerlin/zsh-cmd-time
```
to your `.zshrc` to install the zsh-cmd-time plugin. [zplugin](/../../../../TomfromBerlin/zplugin) then downloads the plugin, and compiles it with zcompile giving your shell a noticeable performance boost.

**To display the execution time in the right prompt, add the following line to your prompt definitions (probably in your .zshrc)**.

```zsh
RPS1='${elapsed} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
```

If you don't want that just put `echo -e $(elapsed)` or `echo -e $(timer_show)` right above your prompt or without `echo -e` somewhere in your PS1 definition. In Bash you can use (parentheses), while the Z shell accepts {braces} or does not require them at all. At this point, it is quite helpful to have a little knowledge about how to customize the prompt.

Execution time will then be shown right above, or within your left prompt. If you only want to see the execution time without any text you can use the `timer_show` variable.

_Other plugin managers / frameworks see [here](README.md#install-with-antigen)_

### Description of zsh-cmd-time

`zsh-cmd-time` is a plugin that outputs the execution time of commands and exports the result to a variable that can be used elsewhere. It is similar to the built-in [REPORTTIME](http://zsh.sourceforge.net/Doc/Release/Parameters.html) function, but it is also slightly different.

`REPORTTIME` is a nifty feature of zsh. If you set it to a non-negative value, then every time, any command you run that takes longer than the value you set it to in seconds, zsh will print usage statistics afterwards as if you had run the command prefixed with `time`. Well, almost every time.

The following screenshot shows two measurements, both with `REPORTTIME=3`, but `REPORTTIME` itself remains silent. The output would look like that of the second measurement but that comes from `time` command. (Just ignore the right prompt at this point.)

![reporttime](https://user-images.githubusercontent.com/123265893/232536349-55ca37e6-7fdf-45dc-93bb-6a4cf9bcd14a.png)

As mentioned before `REPORTTIME` has been set to `REPORTTIME=3` (seconds) and one would expect a response by `REPORTTIME`. However, `sleep` does not consume any CPU time and `REPORTTIME` does not recognize such idle commands. Here `zsh-cmd-time` comes into play. As you can see, the right prompt shows the execution time regardless of whether CPU time was consumed or not and this is the plugin at work.

So if you want to monitor CPU-consuming commands only, you should use `REPORTTIME` instead of this plugin.

_At this point, it is probably worth mentioning that the measured times do vary, especially with many decimal places, even if the same program is executed twice directly in succession. Well, the measurement is not done with a high precision clock, but with a computer with many different components of hardware and software, which can have different effects at different times. In addition, there are rounding errors, which are unavoidable due to the way floating point numbers are handled in a digital environment. For this reason, the measured times are to be understood rather as approximate values. If necessary, a series of measurements is recommended, from which an average value can then be calculated._

## Configuration

You can override defaults in `.zshrc`:
```zsh

# Message to display (set to "" for disable).
ZSH_CMD_TIME_MSG="took %s"

# Exclude some commands
ZSH_CMD_TIME_EXCLUDE=(vim nano ranger mc mcedit clear cls)
```

### Customization
You can customize the output of the plugin by redefining the zsh_command_time function. Here are two examples of custom definitions.

The variable $ZSH_COMMAND_TIME contains the execution time in seconds since the execution time is always measured in seconds. The plugin converts the seconds into minutes and hours if it seems necessary and output this information in the terminal.

### 1st example (default config in this fork)

The configuration below can handle floating point numbers and will display six decimal places for short commands (< 1 minute). Longer execution times will be displayed as "mm:ss", or "hh:mm:ss" respectively. When execution time is above 60 seconds, neither milliseconds nor nanoseconds are displayed.

For output in milliseconds, or even nanoseconds you have to put `typeset -F SECONDS` into your .zshrc, otherwise there are only zeros as decimal places.

```zsh
zsh_cmd_time() {
    if [[ -n "$ZSH_CMD_TIME" ]]; then
# we leave the handling of floating point numbers to bc --> https://www.gnu.org/software/bc/manual/html_mono/bc.html
        h=$(bc <<< "${ZSH_CMD_TIME}/3600")
        m=$(bc <<< "(${ZSH_CMD_TIME}%3600)/60")
        s=$(bc <<< "${ZSH_CMD_TIME}%60")
        if [[ "$ZSH_CMD_TIME" -le 1 ]]; then
             ZSH_CMD_TIME_COLOR="magenta"
             timer_show=$(printf %.6f" sec" "$ZSH_CMD_TIME")
        elif [[ "$ZSH_CMD_TIME" -le 60 ]]; then
             ZSH_CMD_TIME_COLOR="green"
             timer_show=$(printf %.3f" sec" "$ZSH_CMD_TIME") # "%.nf" defines the number of decimal places,
                                                           # where "n" is an integer. Values above 14 are
                                                           # possible, but not useful, because the
                                                           # computer's internal representation of
                                                           # floating point Numbers has a limited number
                                                           # of bits and as a consequence a limited accuracy.
                                                           # So numbers with floating point cannot be
                                                           # stored as e.g. 3.000000000.... in memory,
                                                           # but as 3.0000000002 or 2.99999998.
                                                           # You can safely ignore everything after
                                                           # the 14th decimal place in a result.
        elif [[ "$ZSH_CMD_TIME" -gt 60 ]] && [[ "$ZSH_CMD_TIME" -le 180 ]]; then
             ZSH_CMD_TIME_COLOR="cyan"
             timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        else
            if [[ "$h" -gt 0 ]]; then
                m=$((m%60))
             ZSH_CMD_TIME_COLOR="red"
                 timer_show=$(printf '%dh:%02dm:%02ds' $((h)) $((m)) $((s)))
            else
             ZSH_CMD_TIME_COLOR="yellow"
                 timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
            fi
        fi
          elapsed=$(echo -e "%F{$ZSH_CMD_TIME_COLOR}$(printf '%s' "${ZSH_CMD_TIME_MSG}"" $timer_show")%f")
          export elapsed
    fi
}
```

When execution time is below 1 second you will see 6 decimal places, between one second and 60 seconds there will be 3 decimal places. If execution time lasts more than one minute the output is mm:ss, or hh:mm:ss if you have very long running commands with execution times over one hour.

The output on the right prompt in the Z shell looks like this:

![zsh-cmd-time](https://user-images.githubusercontent.com/123265893/232322193-3d9ad194-1d30-4415-83b5-29c4093c7fae.png)

| Annotation |
|:-|
| When using `print -P` in the right prompt of the Z shell, it happened that the output was severely out of place with the above configuration. Unfortunately, `print -P` moves the right prompt towards the center of the window and I haven't found a solution for this yet, except to replace `print -P` with `echo -e`. Maybe this is the only solution, who knows. I tried to fix it with `%{$elapsed%}`, but that moves RPS1 too much to the right and then causes an unwanted line break. So there is a mix of `echo -e` and `printf` on one line, which looks pretty stupid - but works and even [shellcheck](https://www.shellcheck.net/) do not complain. |

### 2nd example

This is a similar configuration, but without color output of the execution time.

```zsh
zsh_cmd_time() {
    if [[ -n "$ZSH_CMD_TIME" ]]; then
# we leave the handling of floating point numbers to bc --> https://www.gnu.org/software/bc/manual/html_mono/bc.html
        h=$(bc <<< "${ZSH_CMD_TIME}/3600")
        m=$(bc <<< "(${ZSH_CMD_TIME}%3600)/60")
        s=$(bc <<< "${ZSH_CMD_TIME}%60")
        if [[ "$ZSH_CMD_TIME" -le 1 ]]; then
             timer_show=$(printf %.6f" sec" "$ZSH_CMD_TIME")
        elif [[ "$ZSH_CMD_TIME" -le 60 ]]; then
            timer_show=$(printf %.3f" sec" "$ZSH_CMD_TIME")  # for explanation of "%.nf"
                                                             # see configuration example above
        elif [[ "$h" -gt 0 ]]; then
                 m=$((m%60))
                 timer_show=$(printf '%dh:%02dm:%02ds' $((h)) $((m)) $((s)))
        else
                 timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        fi
         printf '%s' "${ZSH_CMD_TIME_MSG}" " $timer_show"
    fi
}
```
Todo:
- [x] Make sure that the plugin outputs fractions of a second (milliseconds) if the execution of a command takes less than 1.5 seconds. This way you will have a handy benchmark tool, even though it won't be very accurate. The output should be in a readable format.
- [x] colored output depending on command execution time
- [ ] reset the right prompt after `clear`/`cls`; unfortunately after clearing the screen with `clear` the execution time of the last command still persists in the right prompt (even with `setopt TRANSIENT_PROMPT`). The only way to avoid this is to measure the execution time of `clear`, but I don't want to do that because it doesn't seem reasonable.

-------------------------------------------------------

## Install with [antigen](/../../../../zsh-users/antigen)

```bash
antigen bundle TomfromBerlin/zsh-cmd-time
```

## Install for [oh my zsh](/../../../../ohmyzsh/ohmyzsh)

Download:

```bash
git clone https://github.com/TomfromBerlin/zsh-cmd-time.git ~/.oh-my-zsh/custom/plugins/cmd-time
```

And add `cmd-time` to `plugins` in `.zshrc`.

## Usage with [powerlevel9k](/../../../../bhilburn/powerlevel9k) theme

❗ **To make it short: Do not use this plugin with powerlevel9k/p10k** ❗ 

powerlevel9k as of v0.6.0 has a [native segment of command_execution_time](/../../../../bhilburn/powerlevel9k#command_execution_time)
(see [PR](/../../../../bhilburn/powerlevel9k/pull/402)), so you can easily add it to your prompt:

```bash
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs vcs command_execution_time time)
```

And now have fun and be nice to each other.
