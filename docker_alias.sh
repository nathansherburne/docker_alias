docker () {
    for last in $@ ; do true; done

    ### If not build option or the last arg is not a directory, pass it through to actual docker command ###
    if [ "$1" != "build" ] || [ ! -d "$last" ] ; then
        command="docker"
        for token in $@ ; do
            command+=" $token"
        done
        eval "command $command"
        return
    fi

    ### Get path from root directory to container directory ###
    # Once the loop finishes, the last argument (where the root of the project is) will be stored.
    rel_path_to_root=$last


    # Get the relative path from the root to the current directory (since that's what docker wants)
    # (reversed since going up the directory tree)
    path_dirs_rev=()
    for path in $(echo $rel_path_to_root | tr "/" "\n") ; do
        path_dirs_rev+=(${PWD##*/})
        cd $path
    done
    
    # Reverse the (reversed) path so that it goes from the root to the calling directory.
    relpath=""
    for (( idx=${#path_dirs_rev[@]}-1 ; idx>=0 ; idx-- )) ; do
        relpath+="${path_dirs_rev[idx]}/"
    done
    
    # Change directory back into calling directory just to reset the side-effects.
    cd $relpath

    ### Iterate through arguments, replacing file names/paths with path from root ###

    new_command=""
    i=0
    for n in $@
    do
        root=$n

        # If on the last iteration, break because we don't want to concatenate the root directory to the command.
        if [ "$i" -eq "$(($# - 1))" ] ; then
            break
        fi
        # Check for VAR=file case
        if [[ "$n" = *"="* ]] ; then
            # Split the string on '=', then put all three tokens into array
            args=()
            for token in $(echo $n | tr "=" "\n") ; do
                args+=("$token") 
            done
            args=(${args[0]} "=" ${args[1]})
        else
            # Put single token into array
            args=("$n")
        fi
        for token in ${args[*]} ; do
            # Make sure its a file
            if [ -f "$token" ] ; then
                path=$relpath$token
                new_command+=" ${path}"
            else
                new_command+=" ${token}"
            fi
        done

        ((i++))
    done
    new_command="${new_command/ = /=}"
    new_command="docker${new_command}"

    cd $root
    # Add new root
    new_command+=" ."

    eval "command $new_command"
    
    # Change back to calling directory to leave off where called from.
    cd $relpath
}
