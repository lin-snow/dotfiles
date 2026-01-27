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
      fnm.zsh
      fzf.zsh
      kubectl.zsh
      docker.zsh
      go.zsh
    omz.zsh
    p10k.zsh
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

### 依赖与插件

当前配置默认使用：

- Oh My Zsh：`$HOME/.oh-my-zsh`
- 提示符：默认 **Starship**（可用 `PROMPT_ENGINE` 切换到 p10k）
- 插件：`git`、`zsh-autosuggestions`、`zsh-syntax-highlighting`、`z`

如需增删插件，编辑 `zsh/omz.zsh` 中的 `plugins` 列表即可。

提示符切换：

```
export PROMPT_ENGINE=starship   # starship | p10k
exec zsh -l
```

### 缺少 CLI 会怎样

多数配置都有存在性判断，缺少对应 CLI 时不会导致 shell 启动失败：

- `go` 不存在时，不会追加 `GOPATH/bin`
- `kubectl` 不存在时，不会加载补全
- `fnm` 不存在时，不会加载 `fnm env`
- `fzf` 文件不存在时，不会 source

需要注意的是：函数/alias 仍会定义（如 `y`、`k`），但只有在实际调用时才会因缺少 CLI 报错，不影响启动。

### 常见操作

- 修改环境变量：编辑 `zsh/env.zsh`
- 新增工具配置：在 `zsh/tools/` 下添加新文件
- 新增函数：在 `zsh/functions/` 下添加新文件
- 补全相关：集中在 `zsh/completions.zsh`

## 约定

- `env.zsh`：环境变量与 PATH 管理
- `tools/`：每个工具单独文件，便于增删维护
- `completions.zsh`：统一处理 `compinit`，避免重复初始化

## 建议安装（已安装可忽略）

- Oh My Zsh: https://github.com/ohmyzsh/ohmyzsh
- p10k: https://github.com/romkatv/powerlevel10k
- zsh-autosuggestions: https://github.com/zsh-users/zsh-autosuggestions
- zsh-syntax-highlighting: https://github.com/zsh-users/zsh-syntax-highlighting
- z: https://github.com/rupa/z
- starship: https://starship.rs/
- yazi: https://github.com/sxyazi/yazi
- fzf: https://github.com/junegunn/fzf
- fnm: https://github.com/Schniz/fnm
- kubectl: https://github.com/kubernetes/kubectl
- go: https://go.dev/
- docker: https://www.docker.com/products/docker-desktop/

如果你使用 Homebrew，也可以（可选）：

```
brew bundle --file ~/.dotfiles/Brewfile
```
