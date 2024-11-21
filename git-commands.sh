#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
RED='\033[0;31m'

# 定义每页显示的条目数
ITEMS_PER_PAGE=10

# 定义命令分类和命令
declare -A categories=(
    ["1"]="基础操作"
    ["2"]="分支管理"
    ["3"]="远程操作"
    ["4"]="撤销与回退"
    ["5"]="暂存操作"
    ["6"]="GitHub CLI"
)

# 定义命令数组（按分类）
declare -A git_commands=(
    # 基础操作
    ["1.1"]="git init                    # 初始化一个新的Git仓库"
    ["1.2"]="git clone <url>             # 克隆远程仓库到本地"
    ["1.3"]="git add .                   # 添加所有改动到暂存区"
    ["1.4"]="git add <file>              # 添加指定文件到暂存区"
    ["1.5"]="git commit -m \"message\"     # 提交暂存的更改"
    ["1.6"]="git commit --amend          # 修改最后一次提交"
    ["1.7"]="git status                  # 查看仓库状态"
    ["1.8"]="git log                     # 查看提交历史"
    ["1.9"]="git log --oneline          # 查看简化的提交历史"
    ["1.10"]="git diff                   # 查看未暂存的更改"
    ["1.11"]="apply_gitignore_template    # 选择并应用 .gitignore 模板"
    ["1.12"]="git check-ignore <file>    # 检查文件是否被忽略"
    ["1.13"]="git rm --cached <file>     # 从Git中移除但保留在工作目录"
    ["1.14"]="git update-index --skip-worktree <file>  # 临时忽略文件更改"
    ["1.15"]="git update-index --no-skip-worktree <file>  # 恢复跟踪文件更改"

    # 分支管理
    ["2.1"]="git branch                  # 查看本地分支列表"
    ["2.2"]="git branch -r               # 查看远程分支列表"
    ["2.3"]="git branch -a               # 查看所有分支列表"
    ["2.4"]="git checkout -b <branch>    # 创建并切换到新分支"
    ["2.5"]="git switch -c <branch>      # 创建并切换到新分支(新语法)"
    ["2.6"]="git branch -d <branch>      # 删除本地分支"
    ["2.7"]="git branch -D <branch>      # 强制删除本地分支"
    ["2.8"]="git merge <branch>          # 合并指定分支到当前分支"
    ["2.9"]="git rebase <branch>         # 变基到指定分支"
    ["2.10"]="git cherry-pick <commit>   # 挑选提交到当前分支"

    # 远程操作
    ["3.1"]="git remote -v               # 查看远程仓库信息"
    ["3.2"]="git remote add origin <url> # 添加远程仓库"
    ["3.3"]="git push origin main        # 推送到远程仓库"
    ["3.4"]="git push -u origin main     # 设置上游并推送"
    ["3.5"]="git pull                    # 拉取远程更改并合并"
    ["3.6"]="git fetch                   # 获取远程更改但不合并"
    ["3.7"]="git remote prune origin     # 清理已删除的远程分支"
    ["3.8"]="git push --tags             # 推送所有标签"
    ["3.9"]="git clone --depth 1 <url>   # 浅克隆仓库"
    ["3.10"]="git pull --rebase          # 使用rebase方式拉取"

    # 撤销与回退
    ["4.1"]="git reset --hard HEAD^      # 回退到上一个版本"
    ["4.2"]="git reset --soft HEAD^      # 软回退到上一个版本"
    ["4.3"]="git reset HEAD <file>       # 取消暂存文件"
    ["4.4"]="git checkout -- <file>      # 恢复文件到上次提交状态"
    ["4.5"]="git revert <commit>         # 创建一个新提交来撤销指定提交"
    ["4.6"]="git clean -fd               # 删除未跟踪的文件和目录"
    ["4.7"]="git reset --hard origin/main # 重置到远程main分支"
    ["4.8"]="git reflog                  # 查看操作历史"

    # 暂存操作
    ["5.1"]="git stash                   # 暂存当前修改"
    ["5.2"]="git stash save \"message\"    # 添加说明并暂存"
    ["5.3"]="git stash list              # 查看暂存列表"
    ["5.4"]="git stash pop               # 恢复最近的暂存"
    ["5.5"]="git stash apply             # 应用暂存但不删除"
    ["5.6"]="git stash drop              # 删除最近的暂存"
    ["5.7"]="git stash clear             # 清空所有暂存"
    ["5.8"]="git stash show              # 查看暂存的内容"

    # GitHub CLI
    ["6.1"]="gh repo create              # 创建新的GitHub仓库"
    ["6.2"]="gh repo clone <repo>        # 克隆GitHub仓库"
    ["6.3"]="gh repo fork               # Fork当前仓库"
    ["6.4"]="gh pr create               # 创建Pull Request"
    ["6.5"]="gh pr list                 # 列出Pull Requests"
    ["6.6"]="gh issue create            # 创建Issue"
    ["6.7"]="gh issue list              # 列出Issues"
    ["6.8"]="gh auth login              # 登录GitHub"
    ["6.9"]="gh repo view               # 在浏览器中查看仓库"
    ["6.10"]="gh release create         # 创建新版本发布"
)

# 在文件开头添加危险命令列表
declare -A dangerous_commands=(
    ["git reset --hard"]="1"
    ["git clean -fd"]="1"
    ["git branch -D"]="1"
    ["git reset --hard origin/main"]="1"
    ["git stash clear"]="1"
    ["git stash drop"]="1"
)

# 当前页码和分类
current_page=1
current_category=""

# 显示分类菜单
show_categories() {
    clear
    echo -e "${GREEN}=== Git 命令速查字典 ===${NC}"
    echo -e "${YELLOW}选择命令分类：${NC}"
    echo "----------------------------------------"
    # 使用排序后的键来显示分类
    for key in $(echo "${!categories[@]}" | tr ' ' '\n' | sort -n); do
        echo -e "${BLUE}$key${NC}. ${categories[$key]}"
    done
    echo "----------------------------------------"
    echo "输入 'q' 退出，输入 's' 搜索"
}

# 显示命令菜单
show_commands() {
    local category=$1
    local total_items=0
    local start_idx=$(( (current_page-1) * ITEMS_PER_PAGE + 1 ))
    local end_idx=$(( current_page * ITEMS_PER_PAGE ))
    
    clear
    echo -e "${GREEN}=== ${categories[$category]} ===${NC}"
    echo -e "第 $current_page 页"
    echo "----------------------------------------"

    # 计算当前分类的命令总数
    for key in "${!git_commands[@]}"; do
        if [[ $key == $category.* ]]; then
            ((total_items++))
        fi
    done

    local total_pages=$(( (total_items + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE ))

    # 显示当前页的命令
    local shown_items=0
    for i in $(seq 1 $total_items); do
        local cmd_key="$category.$i"
        if [[ -n "${git_commands[$cmd_key]}" ]]; then
            if (( i >= start_idx && i <= end_idx )); then
                echo -e "${BLUE}$cmd_key${NC}. ${git_commands[$cmd_key]}"
                ((shown_items++))
            fi
        fi
    done

    echo "----------------------------------------"
    echo -e "页码: $current_page / $total_pages (共 $total_items 条命令)"
    echo -e "${YELLOW}导航：${NC}"
    echo "• n: 下一页"
    echo "• p: 上一页"
    echo "• b: 返回分类"
    echo "• q: 退出"
    echo "• s: 搜索"
    echo "• 输入命令编号执行或复制命令"
}

# 搜索函数
search_commands() {
    echo -e "${YELLOW}搜索提示：${NC}"
    echo "• 搜索不区分大小写"
    echo "• 可以搜索命令名或描述"
    echo "• 直接回车返回主菜单"
    echo -n "输入搜索关键词: "
    read keyword
    
    if [[ -z "$keyword" ]]; then
        return
    fi
    
    echo "----------------------------------------"
    echo "搜索结果："
    local found=0
    for key in "${!git_commands[@]}"; do
        if echo "${git_commands[$key]}" | grep -i "$keyword" > /dev/null; then
            echo -e "${BLUE}$key${NC}. ${git_commands[$key]}"
            ((found++))
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        echo -e "${YELLOW}未找到匹配的命令${NC}"
    else
        echo -e "\n${GREEN}共找到 $found 个匹配结果${NC}"
    fi
    echo "----------------------------------------"
    echo "按回车键返回..."
    read
}

# 添加 .gitignore 模板
declare -A gitignore_templates=(
    ["1"]="Node.js"
    ["2"]="Python"
    ["3"]="Visual Studio Code"
    ["4"]="JetBrains IDEs"
    ["5"]="macOS"
    ["6"]="Windows"
    ["7"]="Linux"
    ["8"]="Java"
    ["9"]="Maven"
    ["10"]="Gradle"
)

declare -A gitignore_contents=(
    ["Node.js"]="# Node.js
node_modules/
npm-debug.log
yarn-debug.log*
yarn-error.log*
package-lock.json
.npm
.env
.env.local
.env.*.local
dist/
build/"

    ["Python"]="# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
.pytest_cache/
.coverage
htmlcov/
.venv
venv/
ENV/"

    ["Visual Studio Code"]="# Visual Studio Code
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace
.history/
.ionide"

    ["JetBrains IDEs"]="# JetBrains IDEs
.idea/
*.iml
*.iws
*.ipr
out/
.idea_modules/"

    ["macOS"]="# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent"

    ["Windows"]="# Windows
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msix
*.msm
*.msp
*.lnk"

    ["Linux"]="# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*"

    ["Java"]="# Java
*.class
*.log
*.ctxt
.mtj.tmp/
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*
replay_pid*
target/"

    ["Maven"]="# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties"

    ["Gradle"]="# Gradle
.gradle
**/build/
!src/**/build/
gradle-app.setting
!gradle-wrapper.jar
.gradletasknamecache
gradle/wrapper/gradle-wrapper.properties"
)

# 添加 gitignore 模板应用函数
apply_gitignore_template() {
    clear
    echo -e "${GREEN}=== 选择 .gitignore 模板 ===${NC}"
    echo "----------------------------------------"
    # 使用排序后的键来显示模板
    for key in $(echo "${!gitignore_templates[@]}" | tr ' ' '\n' | sort -n); do
        echo -e "${BLUE}$key${NC}. ${gitignore_templates[$key]}"
    done
    echo "----------------------------------------"
    echo "输入 'b' 返回, 'q' 退出"
    echo -n "请选择模板 (可多选，用空格分隔): "
    read -a choices

    if [[ ${#choices[@]} -eq 0 ]]; then
        echo -e "\n${YELLOW}未选择任何模板，操作取消${NC}"
        echo -e "\n按回车键继续..."
        read
        return
    fi

    for choice in "${choices[@]}"; do
        if [[ $choice == "q" ]]; then
            exit 0
        elif [[ $choice == "b" ]]; then
            return
        elif [[ -n "${gitignore_templates[$choice]}" ]]; then
            template_name="${gitignore_templates[$choice]}"
            echo -e "\n${GREEN}应用 $template_name 模板${NC}"
            if [[ ! -f .gitignore ]]; then
                echo -e "# $template_name" > .gitignore
                echo "${gitignore_contents[$template_name]}" >> .gitignore
            else
                echo -e "\n# $template_name" >> .gitignore
                echo "${gitignore_contents[$template_name]}" >> .gitignore
            fi
        fi
    done
    
    echo -e "\n${GREEN}已更新 .gitignore 文件${NC}"
    echo "是否要查看文件内容？(y/N): "
    read view_content
    if [[ $view_content =~ ^[Yy]$ ]]; then
        echo -e "\n${YELLOW}=== .gitignore 内容 ===${NC}"
        cat .gitignore
    fi
    
    echo -e "\n按回车键继续..."
    read
}

# 修改命令执行函数，添加编辑功能
execute_command() {
    local command="$1"
    local is_dangerous="$2"
    
    if [ $is_dangerous -eq 1 ]; then
        echo -e "\n${RED}⚠️  警告：这是一个危险命令！${NC}"
        echo -e "${RED}该命令可能会导致：${NC}"
        echo -e "  • 不可恢复的数据丢失"
        echo -e "  • 工作区的永久性改变"
        echo -e "${YELLOW}命令：${NC}$command"
        echo -n "确定要执行吗？(y/N): "
        read confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo -e "\n${YELLOW}操作取消${NC}"
            return
        fi
    fi
    
    # 显示命令并提供编辑选项
    echo -e "\n${YELLOW}当前命令：${NC}${command}"
    echo -e "按回车直接执行，输入 'e' 编辑命令: "
    read edit_choice
    
    if [[ $edit_choice == "e" ]]; then
        echo -n "请输入修改后的命令: "
        read -e -i "$command" command
    fi
    
    # 执行命令
    echo -e "\n${GREEN}执行命令：${NC}$command"
    eval "$command"
}

# 添加新函数来获取 GitHub 仓库列表
get_github_repo_url() {
    echo -e "\n${YELLOW}选择仓库 URL 的方式：${NC}"
    echo "1. 从 GitHub 仓库列表选择"
    echo "2. 手动输入仓库 URL"
    echo "3. 返回"
    echo -n "请选择: "
    read choice

    case $choice in
        "1")
            # 检查是否安装了 gh
            if ! command -v gh &> /dev/null; then
                echo -e "${RED}错误: 未安装 GitHub CLI (gh)${NC}"
                echo "请先安装 GitHub CLI: https://cli.github.com/"
                return 1
            fi

            # 检查是否已登录
            if ! gh auth status &> /dev/null; then
                echo -e "${YELLOW}请先登录 GitHub CLI${NC}"
                gh auth login
                if [ $? -ne 0 ]; then
                    echo -e "${RED}登录失败${NC}"
                    return 1
                fi
            fi

            echo -e "${YELLOW}正在获取您的 GitHub 仓库列表...${NC}"
            repos=$(timeout 5s gh repo list --json nameWithOwner,url --limit 100 --jq '.[] | "\(.nameWithOwner)|\(.url)"' 2>/dev/null)
            
            if [ $? -ne 0 ] || [ -z "$repos" ]; then
                echo -e "${RED}获取仓库列表失败${NC}"
                return 1
            fi

            # 显示仓库列表供用户选择
            local i=1
            declare -A repo_map
            while IFS='|' read -r name url; do
                echo -e "${BLUE}$i${NC}. $name"
                repo_map[$i]=$url
                ((i++))
            done <<< "$repos"

            echo -n "请选择仓库编号: "
            read repo_choice
            if [[ $repo_choice =~ ^[0-9]+$ ]] && [ -n "${repo_map[$repo_choice]}" ]; then
                echo "${repo_map[$repo_choice]}"
                return 0
            else
                echo -e "${RED}无效的选择${NC}"
                return 1
            fi
            ;;
            
        "2")
            echo -e "\n${YELLOW}请输入仓库 URL${NC}"
            echo "示例格式："
            echo "• HTTPS: https://github.com/username/repo.git"
            echo "• SSH: git@github.com:username/repo.git"
            echo -n "URL: "
            read url
            if [[ -n "$url" ]]; then
                echo "$url"
                return 0
            fi
            return 1
            ;;
            
        "3"|"b"|"")
            return 1
            ;;
            
        *)
            echo -e "${RED}无效的选择${NC}"
            return 1
            ;;
    esac
}

# 修改 handle_command 函数
handle_command() {
    local key=$1
    command=$(echo "${git_commands[$key]}" | cut -d '#' -f1 | tr -d '\n' | tr -d '\r' | sed 's/[[:space:]]*$//')
    
    # 特殊处理 gitignore 模板命令
    if [[ $command == "apply_gitignore_template" ]]; then
        echo -e "\n${YELLOW}选择 .gitignore 模板：${NC}"
        echo "----------------------------------------"
        for key in "${!gitignore_templates[@]}"; do
            echo -e "${BLUE}$key${NC}. ${gitignore_templates[$key]}"
        done
        echo "----------------------------------------"
        echo "可以输入多个编号（用空格分隔）"
        echo -n "请选择要应用的模板: "
        read -a choices

        if [[ ${#choices[@]} -eq 0 ]]; then
            echo -e "\n${YELLOW}未选择任何模板，操作取消${NC}"
            echo -e "\n按回车键继续..."
            read
            return
        fi

        for choice in "${choices[@]}"; do
            if [[ -n "${gitignore_templates[$choice]}" ]]; then
                template_name="${gitignore_templates[$choice]}"
                echo -e "\n${GREEN}应用 $template_name 模板${NC}"
                if [[ ! -f .gitignore ]]; then
                    echo -e "# $template_name" > .gitignore
                    echo "${gitignore_contents[$template_name]}" >> .gitignore
                else
                    echo -e "\n# $template_name" >> .gitignore
                    echo "${gitignore_contents[$template_name]}" >> .gitignore
                fi
            fi
        done
        
        echo -e "\n${GREEN}已更新 .gitignore 文件${NC}"
        echo "是否要查看文件内容？(y/N): "
        read view_content
        if [[ $view_content =~ ^[Yy]$ ]]; then
            echo -e "\n${YELLOW}=== .gitignore 内容 ===${NC}"
            cat .gitignore
        fi
        
        echo -e "\n按回车键继续..."
        read
        return
    fi

    echo -e "\n${YELLOW}选择操作：${NC}"
    echo "1. 复制命令"
    echo "2. 执行命令 (默认)"
    echo "3. 返回"
    echo -n "请选择 (回车执行命令): "
    read operation

    case $operation in
        "1")
            if echo "$command" | tr -d '\n' | pbcopy 2>/dev/null || echo "$command" | tr -d '\n' | xclip -selection clipboard 2>/dev/null; then
                echo -e "\n${GREEN}✓ 已成功复制命令到剪贴板：${NC}"
                echo -e "${BLUE}$command${NC}"
            else
                echo -e "\n${RED}✗ 复制失败：系统不支持剪贴板操作${NC}"
            fi
            ;;
        "3")
            return
            ;;
        *)  # 默认执行命令（包括空输入）
            # 检查是否是危险命令
            is_dangerous=0
            for dangerous_cmd in "${!dangerous_commands[@]}"; do
                if [[ $command == *"$dangerous_cmd"* ]]; then
                    is_dangerous=1
                    break
                fi
            done

            # 检查命令中是否包含占位符
            if [[ $command == *"<"*">"* ]]; then
                if [[ $command == *"git remote add origin <url>"* ]]; then
                    echo -e "\n${YELLOW}正在获取仓库信息...${NC}"
                    repo_url=$(get_github_repo_url)
                    if [ $? -eq 0 ]; then
                        complete_command="git remote add origin $repo_url"
                        execute_command "$complete_command" $is_dangerous
                    fi
                else
                    echo -e "\n${YELLOW}该命令包含需要替换的参数：${NC}"
                    echo -e "${BLUE}$command${NC}"
                    echo -n "请输入完整命令: "
                    read -e -i "$command" complete_command
                    execute_command "$complete_command" $is_dangerous
                fi
            else
                execute_command "$command" $is_dangerous
            fi
            ;;
    esac
    
    echo -e "\n按回车键继续..."
    read
}

# 主循环
while true; do
    if [[ -z $current_category ]]; then
        show_categories
        echo -n "请选择分类: "
        read choice
        
        if [[ $choice == "q" ]]; then
            echo "退出程序"
            exit 0
        elif [[ $choice == "s" ]]; then
            search_commands
        elif [[ -n "${categories[$choice]}" ]]; then
            current_category=$choice
            current_page=1
        else
            echo "无效的选择，按回车键继续..."
            read
        fi
    else
        show_commands $current_category
        echo -n "请输入选择: "
        read choice
        
        case $choice in
            "q")
                echo "退出程序"
                exit 0
                ;;
            "s")
                search_commands
                ;;
            "b")
                current_category=""
                ;;
            "n")
                # 计算总页数并检查是否可以翻到下一页
                total_items=0
                for key in "${!git_commands[@]}"; do
                    if [[ $key == $current_category.* ]]; then
                        ((total_items++))
                    fi
                done
                total_pages=$(( (total_items + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE ))
                
                if (( current_page < total_pages )); then
                    ((current_page++))
                fi
                ;;
            "p")
                if (( current_page > 1 )); then
                    ((current_page--))
                fi
                ;;
            *)
                if [[ -n "${git_commands[$current_category.$choice]}" ]]; then
                    handle_command "$current_category.$choice"
                fi
                ;;
        esac
    fi
done
