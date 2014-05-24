八中OJ程序下载器
================
有个朋友误删了所有BZOJ的程序，所以写了这个自动下载器。输入你的用户名和密码，即可
自动下载所有在BZOJ提交过的程序（严格地说是下载每个评测记录对应的程序）。

用法: `./dl.bash MYDIR`

代码很短，有需要的话大家自行hack哈。

dependencies
------------
大多数Linux发行版均自带Bash (4.x)等软件，因此下面没有列出。若您使用其他操作系统，
请自行安装所需的工具。
  - Ruby (tested on 1.9.3)
  - cURL
