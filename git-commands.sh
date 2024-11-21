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
    for key in "${!categories[@]}"; do
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
    echo -e "页码: $current_page / $total_pages"
    echo "输入命令编号复制命令"
    echo "n: 下一页, p: 上一页, b: 返回分类, q: 退出, s: 搜索"
}

# 搜索函数
search_commands() {
    echo -n "输入搜索关键词: "
    read keyword
    echo "----------------------------------------"
    echo "搜索结果："
    for key in "${!git_commands[@]}"; do
        if echo "${git_commands[$key]}" | grep -i "$keyword" > /dev/null; then
            echo -e "${BLUE}$key${NC}. ${git_commands[$key]}"
        fi
    done
    echo "----------------------------------------"
    echo "按回车键返回..."
    read
}

# 修改复制和执行函数
handle_command() {
    local key=$1
    command=$(echo "${git_commands[$key]}" | cut -d '#' -f1 | tr -d '\n' | tr -d '\r' | sed 's/[[:space:]]*$//')
    
    echo -e "\n${YELLOW}选择操作：${NC}"
    echo "1. 复制命令"
    echo "2. 执行命令"
    echo "3. 返回"
    echo -n "请选择 (1-3): "
    read operation

    case $operation in
        1)
            echo "$command" | tr -d '\n' | pbcopy 2>/dev/null || xclip -selection clipboard 2>/dev/null || echo "无法复制到剪贴板"
            echo -e "\n${GREEN}已复制命令：${NC}$command"
            ;;
        2)
            # 检查是否是危险命令
            is_dangerous=0
            for dangerous_cmd in "${!dangerous_commands[@]}"; do
                if [[ $command == *"$dangerous_cmd"* ]]; then
                    is_dangerous=1
                    break
                fi
            done

            # 如果是危险命令，需要二次确认
            if [ $is_dangerous -eq 1 ]; then
                echo -e "\n${YELLOW}警告：这是一个危险命令，可能会导致数据丢失！${NC}"
                echo -e "${RED}命令：${NC}$command"
                echo -n "确定要执行吗？(y/N): "
                read confirm
                if [[ ! $confirm =~ ^[Yy]$ ]]; then
                    echo -e "\n${YELLOW}操作已取消${NC}"
                    echo -e "\n按回车键继续..."
                    read
                    return
                fi
            fi

            # 检查命令中是否包含占位符
            if [[ $command == *"<"*">"* ]]; then
                echo -e "\n${YELLOW}该命令包含需要替换的参数：${NC}"
                echo -e "${BLUE}$command${NC}"
                echo -n "请输入完整命令: "
                read complete_command
                
                # 如果修改后的命令也是危险命令，再次确认
                if [ $is_dangerous -eq 1 ]; then
                    echo -e "\n${YELLOW}请再次确认完整命令：${NC}"
                    echo -e "${RED}$complete_command${NC}"
                    echo -n "确定要执行吗？(y/N): "
                    read confirm
                    if [[ ! $confirm =~ ^[Yy]$ ]]; then
                        echo -e "\n${YELLOW}操作已取消${NC}"
                        echo -e "\n按回车键继续..."
                        read
                        return
                    fi
                fi
                
                echo -e "\n${GREEN}执行命令：${NC}$complete_command"
                eval "$complete_command"
            else
                echo -e "\n${GREEN}执行命令：${NC}$command"
                eval "$command"
            fi
            ;;
        3)
            return
            ;;
        *)
            echo "无效的选择"
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
                local total_items=0
                for key in "${!git_commands[@]}"; do
                    if [[ $key == $current_category.* ]]; then
                        ((total_items++))
                    fi
                done
                local total_pages=$(( (total_items + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE ))
                
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
