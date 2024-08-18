#! /bin/bash

# designed not:
# clone ssh/http
# go project
# list project
# push project
# pull project
# tar project

target_dir=$HOME/mygithub

if [ ! -d $target_dir ]; then
	mkdir -p $target_dir
fi

git_http_prefix="http://github.com/GuangjiHuang"
git_ssh_prefix="git@github.com:GuangjiHuang"

git_public_projects=(
	"repo"
	"shell-vim-cfg"
	"shell-script"
)

git_private_projects=(
	"everyday-record"
	"goal"
	"data-shared"
	"isp"
	"rtsp"
)

git_projects=("${public_projects[@]}" "${private_projects[@]}")

is_in_array()
{
	local value=$1
	shift
	local array=("$@")

	for item in "${array[@]}"; do
		if [[ "$item" == "$value" ]]; then
			return 0
		fi
	done
	return 1
}

yhrepo()
{

	# arg1 is the operation: clone, push, pull, list, go, tar
	# arg2 is the project name
	arg1=$1
	local args=("$@")

	case $arg1 in
		"clone" | "push" | "pull" | "go" | "tar")
			let arg_num=${#args[@]}-1
			echo "arg_num is the: ${arg_num}"
			if [[ ${args[-1]} == "http" ]]; then
				echo "----------using http to clone the git repo----------"
				prefix=$http_prefix
				select_projects=(${projects[@]}:1:${arg_num})
			elif [[ ${args[-1]} == "ssh" ]]; then
				echo "----------using ssh to clone the git repo----------"
				prefix=$ssh_prefix
				select_projects=(${projects[@]:1:${arg_num}})
			else
				echo "----------using ssh to clone the git repo----------"
				prefix=$ssh_prefix
				select_projects=(${projects[@]:1:${arg_num}})
			fi

			final_projects=()
			for select_project in ${select_projects[@]}; do
				if is_in_array "$select_project" "$select_projects"; then
					final_projects+=("$select_project")
				fi
			done

			if [ ${#final_projects[@]} -eq 0 ]; then
				final_projects=("${git_projects}")
			fi

			for project in ${final_projects[@]}; do
				target_path=$target_dir/$project
				project_url=$prefix/$project

				if [[ $arg1 == "clone" ]]; then
					#if [[ -d $target_path ]]; then
					#	rm -rf $target_path
					#fi
					#git clone $project_url $target_path >/dev/null 2>&1
					echo "git push: $project"
				elif [[ $arg1 == "push" ]]; then
					echo "git push: $project"
				elif [[ $arg1 == "pull" ]]; then
					echo "git push: $project"
				elif [[ $arg1 == "pull" ]]; then
					echo "git push: $project"
				fi

				if [ $? -eq 0 ]; then
					echo "----------$project: clone success! ----------"
				else
					echo "----------$project: clone fail! ----------"
				fi
			done
		;;
		"list")
			;;
		*)
			echo "Not the right args: $arg1"
			;;
	esac
}

