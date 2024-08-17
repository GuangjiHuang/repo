#! /bin/bash

target_dir=$HOME/mygithub

if [ ! -d $target_dir ]; then
	mkdir -p $target_dir
fi

ssh_prefix="http://github.com/GuangjiHuang"
http_prefix="git@github.com:GuangjiHuang"

http_projects=(
	"shell-vim-cfg"
	"shell-script"
)

ssh_projects=(
	"shell-vim-cfg"
	"shell-script"
	"everyday-record"
	"repo"
	"goal"
	"data-shared"
	"isp"
	"rtsp"
)

# arg: ssh or the  http

if [[ $1 == "http" ]]; then
	echo "----------using http to clone the git repo----------"
	prefix=$http_prefix
	projects=("${http_projects[@]}")
else
	echo "----------using ssh to clone the git repo----------"
	prefix=$ssh_prefix
	projects=("${ssh_projects[@]}")
fi

for project in ${projects[@]}
do
	target_path=$target_dir/$project
	if [[ -d $target_path ]]; then
		rm -rf $target_path
	fi

	project_url=$prefix/$project
	git clone $project_url $target_path >dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo "----------$project: clone success! ----------"
	else
		echo "----------$project: clone fail! ----------"
	fi
done
