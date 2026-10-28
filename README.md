# dotfiles

这个仓库用于管理我的开发环境配置（目前以 zsh 为主），通过拆分模块避免单个配置文件膨胀。

> 说明：本仓库默认面向 **macOS + Apple Silicon（Homebrew 在 /opt/homebrew）**。

## 目录结构

```
dotfiles/
  zsh/
    zshrc
    env.zsh
    aliases.zsh
    functions/
      yazi.zsh
    completions.zsh
    tools/
      bun.zsh
      fnm.zsh
      fzf.zsh
      kubectl.zsh
      docker.zsh
      go.zsh
      fastfetch.zsh
      modern-cli.zsh
      omlx.zsh
    omz.zsh
    prompt.zsh
  .zshrc
  bootstrap.sh
  Brewfile
```

## 使用方式

1. 把仓库放在本机任意路径（推荐：`~/.dotfiles`）。
2. 入口为仓库内的 `.zshrc`，它会继续 source `zsh/zshrc`。
3. 重新加载 shell：
   - `source ~/.zshrc`
   - 或重启终端

## 使用说明

### 首次接入

推荐通过软链接管理 `~/.zshrc`：

```
ln -s ~/.dotfiles/.zshrc ~/.zshrc
```

如果你已有 `~/.zshrc` 且不想替换，也可以在原文件中追加一行：

```
source ~/.dotfiles/.zshrc
```

也可以一键执行（推荐，默认只应用配置/不做安装）：

```
cd ~/.dotfiles
./bootstrap.sh
exec zsh -l
```

如需安装/更新（可选）：

```
./bootstrap.sh --install
```

`--install` 的包列表唯一来源是仓库内 `Brewfile`（等价于 `brew bundle install --file=... --no-upgrade`，
只补缺失项，不隐式升级已安装的包）。本机已有 Docker Desktop / OrbStack / Rancher Desktop 时自动跳过 `docker` cask。

### 依赖与插件

当前配置默认使用：

- Oh My Zsh：`$HOME/.oh-my-zsh`
- 提示符：**Starship** 单引擎（`zsh/prompt.zsh`），OMZ 主题置空（`ZSH_THEME=""`）避免两个 prompt 抢 `PROMPT`
- 插件：`git`、`zsh-autosuggestions`、`zsh-syntax-highlighting`（`z` 已移除，由 zoxide 提供）

如需增删插件，编辑 `zsh/omz.zsh` 中的 `plugins` 列表即可。

提示符定制写在 `~/.config/starship.toml`（不存在时用 starship 内置默认配置）：

```
starship config          # 打印当前生效配置
starship preset nerd-font-symbols -o ~/.config/starship.toml
```

如需换回 p10k：`brew install romkatv/powerlevel10k/powerlevel10k`（或 `git clone` 到
`$ZSH_CUSTOM/themes/powerlevel10k`）→ 运行 `p10k configure` 生成 `~/.p10k.zsh` →
在 `zsh/prompt.zsh` 里改成 source `~/.p10k.zsh`，并把 `zsh/omz.zsh` 的 `ZSH_THEME` 设为
`powerlevel10k/powerlevel10k`。

### 缺少 CLI 会怎样

多数配置都有存在性判断，缺少对应 CLI 时不会导致 shell 启动失败：

- `go` 不存在时，不会追加 `GOPATH/bin`
- `kubectl` 不存在时，不会加载补全
- `fnm` 不存在时，不会加载 `fnm env`
- `fzf` 文件不存在时，不会 source
- `fd` / `eza` / `bat` / `zoxide` 不存在时，对应 alias 与初始化整体跳过

需要注意的是：函数/alias 仍会定义（如 `y`、`k`），但只有在实际调用时才会因缺少 CLI 报错，不影响启动。

### 现代 CLI 工具

由 `zsh/tools/modern-cli.zsh` 与 `zsh/tools/fzf.zsh` 配置：

| 工具 | 替代 | 说明 |
| --- | --- | --- |
| `eza` | `ls` | `ls`/`ll`/`la`/`lt`（树形）替换为带图标、Git 状态、目录优先的版本 |
| `bat` | `cat` | 语法高亮 + 行号；`cat` 仅在交互式 shell 中被 alias，脚本用原生 `command cat` |
| `fd` | `find` | 命令本身即用；作为 fzf 默认候选来源（遵守 `.gitignore`） |
| `ripgrep` (`rg`) | `grep -r` | 命令本身即用 |
| `zoxide` | `z` | `z <关键字>` 跳转，`zi` 交给 fzf 交互选择；OMZ 的 `z` 插件已移除 |

`Ctrl-T` 文件选择器带预览：目录用 `eza` 列表，文本文件用 `bat` 高亮前 200 行。

### 常见操作

- 修改环境变量：编辑 `zsh/env.zsh`
- 新增工具配置：在 `zsh/tools/` 下添加新文件
- 新增函数：在 `zsh/functions/` 下添加新文件
- 补全相关：集中在 `zsh/completions.zsh`

## 约定

- `env.zsh`：环境变量与 PATH 管理（`typeset -gU path` 去重；`-g` 不可省，否则在本仓库的 `source_if_exists` 函数里声明成局部变量，PATH 改动会被丢弃）
- `tools/`：每个工具单独文件，便于增删维护；每个文件都要能在对应 CLI 缺失时安全跳过
- `completions.zsh`：统一处理 `compinit`，并在 compinit 之后加载依赖 `compdef` 的补全（bun、kubectl）
- kubectl 补全缓存在 `${XDG_CACHE_HOME:-~/.cache}/zsh/kubectl-completion.zsh`，kubectl 更新后（可执行文件比缓存新）自动重建；首次启动多 ~100ms，之后省掉这段开销

## 建议安装（已安装可忽略）

- Oh My Zsh: https://github.com/ohmyzsh/ohmyzsh
- zsh-autosuggestions: https://github.com/zsh-users/zsh-autosuggestions
- zsh-syntax-highlighting: https://github.com/zsh-users/zsh-syntax-highlighting
- zoxide（替代 OMZ `z` 插件）: https://github.com/ajeetdsouza/zoxide
- starship: https://starship.rs/
- yazi: https://github.com/sxyazi/yazi
- fzf: https://github.com/junegunn/fzf
- fd: https://github.com/sharkdp/fd
- eza: https://github.com/eza-community/eza
- bat: https://github.com/sharkdp/bat
- ripgrep: https://github.com/BurntSushi/ripgrep
- zoxide: https://github.com/ajeetdsouza/zoxide
- fnm: https://github.com/Schniz/fnm
- kubectl: https://github.com/kubernetes/kubectl
- go: https://go.dev/
- docker: https://www.docker.com/products/docker-desktop/

如果你使用 Homebrew，也可以（可选）：

```
brew bundle --file ~/.dotfiles/Brewfile
```
