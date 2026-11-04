# AGENTS.md

Lavanda 是一个基于 Elegant Design 的 GTK 桌面主题，覆盖 GNOME Shell、Cinnamon、XFCE、MATE/Metacity、Plank 等桌面环境。样式以 Sass 编写，通过 `sassc` 编译为 CSS，Bash 脚本负责构建与安装。

通用编码规范（中文回复、变更预算、审批边界等）继承上级 `../AGENTS.md`，本文只记录本项目特有约定。

## 技术栈

- Sass（`.scss`，用 `sassc` / libsass 编译）
- Bash（`build.sh`、`install.sh`）
- GTK 2 / 3 / 4、libadwaita、GNOME Shell 3.28–47、Cinnamon、Metacity、XFWM4、Plank
- 无测试框架、无包管理器、不使用 Make/CMake

## 目录结构

```
build.sh                 编译标准变体 CSS 到源码树
install.sh               按变体编译并安装主题（-d/-n/-t/-c/-s/-i/-l/-u）
src/sass/                可复用 Sass partial（颜色、变量、绘制、各环境样式）
src/sass/gtk/            GTK 3/4 共享样式与应用特例
src/sass/gnome-shell/    GNOME Shell 样式，按版本拆分 _widgets-<ver>.scss
src/sass/cinnamon/       Cinnamon 样式
src/main/                各环境 SCSS 入口与静态资源（gtkrc、metacity XML、xfwm4 themerc、plank）
src/main/gtk-3.0/        入口：gtk{,-Sea}{,-Light,-Dark}.scss
src/main/gtk-4.0/        入口：gtk{,-Sea}{,-Light,-Dark}.scss
src/main/gnome-shell/    入口：gnome-shell{,-Sea}{,-Light,-Dark}.scss
src/main/cinnamon/       入口：cinnamon{,-Sea}{,-Light,-Dark}.scss
src/assets/              SVG/PNG 资源，按环境与变体存放（*-Dark、*-Sea、theme-assets 等）
wallpaper/               壁纸源文件与 XML
```

## 变体矩阵

主题目录名由三段变体拼接：`Lavanda{theme}{color}{size}`。

| 维度 | 取值 | 示例 |
| --- | --- | --- |
| 主题 | 默认（standard）、`Sea` | `Lavanda-Sea` |
| 颜色 | 默认（standard）、`Light`、`Dark` | `Lavanda-Dark` |
| 尺寸 | 默认（standard）、`Compact` | `Lavanda-Compact` |

`build.sh` 只编译颜色变体（不含 Sea）；`install.sh` 按所选 `-t/-c/-s` 组合现场编译并安装。

## 构建与安装

```sh
./build.sh                # 需要 sassc，生成 src/main/*/*.css
./install.sh              # 安装到 ~/.themes；root 用户装到 /usr/share/themes
./install.sh -d /tmp/lavanda-test -t sea -c dark -s compact   # 临时目录验证
./install.sh -u           # 卸载已安装主题
```

## 开发约定

- 只改 Sass 源码，不手改生成的 `.css`。`src/main/**/*.css` 与 `src/sass/gnome-shell/_common-temp.scss` 是构建产物，已被 `.gitignore` 忽略，不要提交。
- 颜色、尺寸与功能开关集中在 `src/sass/_colors.scss`、`_color-palette.scss`、`_variables.scss`、`_options.scss`；调整主题基调优先改这里。
- 新增组件样式写入对应的 `_` 前缀 partial，再由环境入口（`src/main/<env>/*.scss`）`@import`，不要复制粘贴大段样式。
- GNOME Shell 样式按版本分文件（`_widgets-3-28.scss` 至 `_widgets-47-0.scss`），改动需检查相邻版本；`install.sh` 依据 `gnome-shell --version` 选择 `GS_VERSION`。
- 资源目录按变体镜像组织（`assets`、`assets-Dark`、`theme-assets-Sea`、`common-assets` 等），新增图标要同步放入所有相关变体目录，否则对应变体会回退默认图标。
- 保持 Bash 现有风格：2 空格缩进、小写函数名、`[[ ]]` 判断、变量加双引号。
- 不新增依赖，`sassc` 是唯一构建依赖。

## 验证

项目没有自动化测试，改动后按以下检查点验证：

1. `./build.sh` 无 sassc 编译错误；
2. `./install.sh -d /tmp/lavanda-test` 执行成功，确认 `Lavanda*/gtk-3.0/gtk.css`、`gnome-shell/gnome-shell.css`、`index.theme` 存在；
3. 至少抽查一个非默认变体（如 `-t sea -c dark -s compact`）；
4. 涉及 SCSS 时，确认生成的 CSS 中目标选择器与颜色已生效。

## 注意

- `screenshot-*.png` 是 README 展示图，主题外观明显变化时同步更新。
- 许可证为 GPL-3.0。
