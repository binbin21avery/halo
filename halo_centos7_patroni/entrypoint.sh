#!/bin/bash  
  
# 设置错误检查，如果任何命令返回非零状态，则立即退出  
set -e  
  
# 检查 shellcheck 是否可用，并使用它来检查脚本的语法错误  
# shellcheck source=runtime/functionssource "/home/${USER}/runtime/function"configure_patroni  
  shellcheck source=runtime/functions
# 运行 configure_patroni 函数，该函数定义在 "/home/${USER}/runtime/function" 文件中  
source "/home/${USER}/runtime/function"  
configure_patroni





