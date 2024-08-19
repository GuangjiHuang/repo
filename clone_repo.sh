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

git_projects=("${git_public_projects[@]}" "${git_private_projects[@]}")

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
	if [[ $# -eq 0 ]]; then
		echo "Must specify at least one argument!"
		return
	fi

	local args=("$@")
	local args_num=${#args[@]}

	case ${args[0]} in
		"clone" | "push" | "pull" | "go" | "tar")
			if [[ ${args[-1]} == "http" ]]; then
				echo "----------using http to clone the git repo----------"
				prefix=$git_http_prefix
				check_projects=("${git_public_projects[@]}")
			else
				echo "----------using ssh to clone the git repo----------"
				prefix=$git_ssh_prefix
				check_projects=("${git_projects[@]}")
			fi
			select_projects=(${args[@]:1:${args_num}})
			final_projects=()
			for select_project in ${select_projects[@]}; do
				if is_in_array "$select_project" "${check_projects[@]}"; then
					final_projects+=("$select_project")
				fi
			done

			init_final_projects_num=${#final_projects[@]}
			if [ ${#final_projects[@]} -eq 0 ]; then
				if [[ "$prefix" == "$git_http_prefix" ]]; then
					final_projects=("${git_public_projects[@]}")
				else
					final_projects=("${git_projects[@]}")
				fi
			fi

			#echo "final projects: ${final_projects[@]}"

			# ---- operate the final_projects -----
			for project in ${final_projects[@]}; do
				target_path=$target_dir/$project
				project_url=$prefix/$project

				if [[ ${args[0]} == "clone" ]]; then
					if [[ -d $target_path ]]; then
						rm -rf $target_path
					fi
					#git clone $project_url $target_path >/dev/null 2>&1
					git clone $project_url $target_path
					if [ $? -eq 0 ]; then
						echo "----------$project: clone success! ----------"
					else
						echo "----------$project: clone fail! ----------"
					fi
				elif [[ ${args[0]} == "push" ]]; then
					echo "git push: $project"
					if [ ! -d $target_path ]; then
						echo "$target_path not exists! No such project, please download first!"
						echo "----------$project: push fail! ----------"
					fi
					commit_message="update, user($(whoami)), host($(hostname)), date($(date))"
					echo $commit_message
					cd $target_path
					git add . && git commit -m "${commit_message}" && git push
					cd -
					echo "----------$project: push success! ----------"

				elif [[ ${args[0]} == "pull" ]]; then
					echo "git pull: $project"
				elif [[ ${args[0]} == "go" ]]; then
					if [ $init_final_projects_num -eq 0 ]; then
						echo "No scuh project: ${args[0]}"
					elif [ -d $target_path ]; then
						echo "-> $target_path"
						cd $target_path
					else
						echo "$target_path not exists! No such project, please download first!"
					fi
					break # just run once
				elif [[ ${args[0]} == "tar" ]]; then
					echo "tar: $project"
				else
					echo "No such operation!"
				fi
			done
		;;
		"list")
			;;
		*)
			echo "Not the right args: ${args[0]}"
			;;
	esac
}

