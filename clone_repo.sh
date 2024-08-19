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

print_error()
{
	echo -e "$RED $1 $NOCOLOR"
}

print_info()
{
	echo -e "$GREEN $1 $NOCOLOR"
}

print_help()
{
	echo -e "${GREEN}$1${NOCOLOR} $2\n"
}

yh()
{
	# arg1 is the operation: clone, push, pull, list, go, tar
	# arg2 is the project name
	if [[ $# -eq 0 ]]; then
		print_error "Must specify at least one argument!"
		return
	fi

	local args=("$@")
	local args_num=${#args[@]}

	case ${args[0]} in
		"clone" | "push" | "pull" | "go" | "tar")
			if [[ ${args[-1]} == "http" ]]; then
				local prefix=$git_http_prefix
				local check_projects=("${git_public_projects[@]}")
			else
				local prefix=$git_ssh_prefix
				local check_projects=("${git_projects[@]}")
			fi
			local select_projects=(${args[@]:1:${args_num}})
			local final_projects=()
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

			let local final_projects_num=${#final_projects[@]}-1
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
						print_error "----------$project: clone success! ----------"
					else
						print_info "----------$project: clone fail! ----------"
					fi
				elif [[ ${args[0]} == "push" ]]; then
					print_info ">>>>>>>> git push: $project start ..."
					if [ ! -d $target_path ]; then
						print_error "$target_path not exists! No such project, please download first!"
						print_error ">>>>>>>> git push: $project fail!"
					fi
					local commit_message="update, user($(whoami)), host($(hostname)), date($(date))"
					cd $target_path
					git add . && git commit -m "${commit_message}" && git push
					cd -
					print_info ">>>>>>>> git push: $project success!"

				elif [[ ${args[0]} == "pull" ]]; then
					print_info "git pull: $project"

				elif [[ ${args[0]} == "go" ]]; then
					if [ $init_final_projects_num -eq 0 ]; then
						print_error "No scuh project: ${args[0]}"
					elif [ -d $target_path ]; then
						print_info "-> $target_path"
						cd $target_path
					else
						print_error "$target_path not exists! No such project, please download first!"
					fi
					break # just run once

				elif [[ ${args[0]} == "tar" ]]; then
					cd $target_dir
					local tar_top_dir=$target_dir/mygithub_tar
					if [ ! -d $tar_top_dir ]; then
						mkdir -p $tar_top_dir
					fi
					if [ ! -d $target_dir/$project ]; then
						print_error "$target_dir/project not exist! Can not tar"
						continue
					fi
					if [ -d $tar_top_dir/$project ]; then
						rm -rf $tar_top_dir/$project
					fi
					cp -r $target_dir/$project $tar_top_dir
					if [[ $project == ${final_projects[$final_projects_num]} ]]; then
						print_info "tar the $tar_top_dir"
						tar -f mygithub_tar.tar -c $(basename $tar_top_dir)
					fi
				else
					print_error "No such operation!"
				fi
			done
		;;
		"list")
			print_info "private git repo:"
			local sign='-'
			for private_repo in ${git_private_projects[@]}; do
				if [ -d $target_dir/$private_repo ]; then
					sign='+'
				else
					sign='-'
				fi
				echo -e "($sign) $private_repo"
			done
			print_info "public git repo:"
			for public_repo in ${git_public_projects[@]}; do
				if [ -d $target_dir/$private_repo ]; then
					sign='+'
				else
					sign='-'
				fi
				echo -e "($sign) $public_repo"
			done
			;;
		"source")
			if [ -d $target_dir/repo ]; then
				print_info "repo: $target_dir/repo update!"
				source $target_dir/repo/clone_repo.sh
			else
				print_error "repo: $target_dir/repo not exists!"
			fi
			;;
		"help")
			print_help "clone/push/pull/tar:" "shell-vim-cfg shell-script [other project] [http]/[ssh]"
			print_help "list:" "show all the possible repo, + means the exist in your local, - means not exists!"
			print_help "source:" "source ~/mygithub/repo/clone_*.sh, update the funcion you use(yh)"
			print_help "help:" "show the help information"
			;;
		*)
			print_error "Not the right args: ${args[0]}"
			;;
	esac
}

