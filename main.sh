#!/bin/bash


# Global variables for easy access
raw_ids=(); # IDs as stored in database
ids=(); # Incrementing IDs for cleaner display (maps to raw_ids)
names=();

folders=();
pdf_paths=();
book_paths=();
github_pdf_paths=();

last_updated=();
last_committed=();
pinned=();
complete=();

WEBSITE_PATH="C:/Users/user/OneDrive/Coding Projects/GitHub/My Website";
WEBSITE_FILES_PATH="C:/Users/user/OneDrive/Coding Projects/GitHub/My Website/data/documents/";

# Load projects from SQLite database
load_projects() {
    echo " =============================================================="
    echo "||   _____     _              _____                           ||"
    echo "||  |   | |___| |_ ___ ___   |     |___ ___ ___ ___ ___ ___   ||"
    echo "||  | | | | . |  _| -_|_ -|  | | | | .'|   | .'| . | -_|  _|  ||"
    echo "||  |_|___|___|_| |___|___|  |_|_|_|__,|_|_|__,|_  |___|_|    ||"
    echo "||                                             |___|          ||"
    echo "||                                                            ||"
    echo -e "||     \e[34mBy genevieve | est. 2026 \e[0m                              ||"
    echo " =============================================================="
    
    echo ""

    # Reset
    raw_ids=();
    ids=();
    names=();

    folders=();
    pdf_paths=();
    book_paths=();
    github_pdf_paths=();

    last_updated=();
    last_committed=();
    pinned=();
    complete=();

    while IFS= read -r line; do
        # Parse each line, split by '|''
        IFS="|" read -ra ELEMENTS <<< "$line";
        
        raw_ids+=("${ELEMENTS[0]}");
        names+=("${ELEMENTS[1]}");

        folders+=("${ELEMENTS[2]}")
        pdf_paths+=("${ELEMENTS[3]}");
        last_updated+=("$(date -r "${ELEMENTS[3]}" +'%Y-%m-%d %H:%M:%S')");
        book_paths+=("${ELEMENTS[4]}");
        github_pdf_paths+=("${ELEMENTS[5]}")

        last_committed+=("${ELEMENTS[6]}");
        pinned+=("${ELEMENTS[7]}");
        complete+=("${ELEMENTS[8]}");
    
    done < <(sqlite3 data.sqlite "SELECT id,name,folder,pdf_path,book_path,github_pdf_path,last_commit,pinned,complete,id FROM projects")
    # ^The final 'id' column is just there to prevent undefined behavior with EOF or similar.
    # Quickest fix I found.
    
    proj_len=${#raw_ids[@]};


    # Projects display
    id_tracker=0;
    printf "    ID                       Title                             Updated              Committed        \n";
    printf "  |----|-----------------------------------------------|---------------------|---------------------| \n";
    
    # 1. Pinned
    for ((i = 0; i < $proj_len; i++)); do
        if [[ "${pinned[$i]}" == "1" ]]; then

            # Different display colors if commit is lagging update
            if [[ "${last_committed[$i]}" == "N/A" ]]; then
                printf "  | \e[33m%-2s\e[0m | \e[33m%-45s\e[0m | \e[34m%-19s\e[0m | \e[33m%-19s\e[0m | \n" "$id_tracker" "${names[$i]}" "${last_updated[$i]}" "${last_committed[$i]}";
            else
                last_updated_unix=$(date -d "${last_updated[$i]}" +%s);
                last_committed_unix=$(date -d "${last_committed[$i]}" +%s);

                if (( last_updated_unix > last_committed_unix )); then
                    printf "  | \e[33m%-2s\e[0m | \e[33m%-45s\e[0m | \e[34m%-19s\e[0m | \e[31m%-19s\e[0m | \n" "$id_tracker" "${names[$i]}" "${last_updated[$i]}" "${last_committed[$i]}";
                else
                    printf "  | \e[33m%-2s\e[0m | \e[33m%-45s\e[0m | \e[34m%-19s\e[0m | \e[34m%-19s\e[0m | \n" "$id_tracker" "${names[$i]}" "${last_updated[$i]}" "${last_committed[$i]}";
                fi
            fi
            
            ids+=($i);
            let id_tracker++;
        fi
    done

    if (( id_tracker != 0 )); then
        printf "  |----|-----------------------------------------------|---------------------|---------------------| \n";
    fi

    # 2. Other (unpinned)
    for ((i = 0; i < $proj_len; i++)); do
        if [[ "${pinned[$i]}" == "0" ]]; then
            
            # Different display colors if commit is lagging update
            if [[ "${last_committed[$i]}" == "N/A" ]]; then
                printf "  | \e[33m%-2s\e[0m | \e[33m%-45s\e[0m | \e[34m%-19s\e[0m | \e[33m%-19s\e[0m | \n" "$id_tracker" "${names[$i]}" "${last_updated[$i]}" "${last_committed[$i]}";
            else
                last_updated_unix=$(date -d "${last_updated[$i]}" +%s);
                last_committed_unix=$(date -d "${last_committed[$i]}" +%s);

                if (( last_updated_unix > last_committed_unix )); then
                    printf "  | \e[33m%-2s\e[0m | \e[33m%-45s\e[0m | \e[34m%-19s\e[0m | \e[31m%-19s\e[0m | \n" "$id_tracker" "${names[$i]}" "${last_updated[$i]}" "${last_committed[$i]}";
                else
                    printf "  | \e[33m%-2s\e[0m | \e[33m%-45s\e[0m | \e[34m%-19s\e[0m | \e[34m%-19s\e[0m | \n" "$id_tracker" "${names[$i]}" "${last_updated[$i]}" "${last_committed[$i]}";
                fi
            fi

            ids+=($i);
            let id_tracker++;
        fi
    done

    echo ""
}

# Documentation
print_docs() {
    echo -e "\e[31mopen\e[0m \e[34m[ID] -p -v -b\e[0m"
    echo -e "    Open the project corresponding to \e[34mID\e[0m."
    echo -e "    \e[34m-p\e[0m, the PDF file; \e[34m-v\e[0m, a VSCode environment; \e[34m-b\e[0m, the linked book (if it exists)"
    echo "    If no arguments are specified, only the PDF is opened."
    echo ""

    echo -e "\e[31medit\e[0m \e[34m[ID]\e[0m"
    echo -e "    Edit details of the project corresponding to \e[34mID\e[0m."
    echo ""

    echo -e "\e[31mdelete\e[0m \e[34m[ID]\e[0m"
    echo -e "    Delete the project corresponding to \e[34mID\e[0m."
    echo -e "    Requires double-confirmation."
    echo ""

    echo -e "\e[31mnew\e[0m"
    echo -e "    Registers a new project (prompts for details when run)."
    echo ""

    echo -e "\e[31mcommit\e[0m \e[34m[ID 1] [ID 2] [ID 3] ...\e[0m"
    echo -e "    Commits the projects corresponding to the \e[34mID\e[0ms given in parameters to my site."
    echo -e "    Requires double-confirmation."
    echo ""

    echo -e "\e[31mclear\e[0m"
    echo -e "    Clears the entire scren and refreshes the projects."

    echo ""
}

# Register a new project
add_project() {
    echo ""
    echo "[PROJECT REGISTRATION]"
    echo "Leave out file suffixes. All quotation marks will be stripped."
    echo ""

    name=""
    folder=""
    pdf_path=""
    book_path=""
    pinned=0
    complete=0
    github_pdf_path=""

    # -r: don't escape slashes.
    read -rep "Name: " name
    read -rep "Project folder: " folder
    read -rep "Path to PDF file: " pdf_path
    read -rep "Path to book (or leave blank): " book_path
    read -rep "Pin? (Y/N): " pinned_str
    read -rep "Complete? (Y/N): " complete_str
    read -rep "PDF file name within GitHub site: " github_pdf_path

    # Strip quotation marks
    name="${name%\"}" ; name="${name#\"}" ; name="${name%\'}" ; name="${name#\'}"
    folder="${folder%\"}" ; folder="${folder#\"}" ; folder="${folder%\'}" ; folder="${folder#\'}"
    pdf_path="${pdf_path%\"}" ; pdf_path="${pdf_path#\"}" ; pdf_path="${pdf_path%\'}" ; pdf_path="${pdf_path#\'}"
    book_path="${book_path%\"}" ; book_path="${book_path#\"}" ; book_path="${book_path%\'}" ; book_path="${book_path#\'}"
    github_pdf_path="${github_pdf_path%\"}" ; github_pdf_path="${github_pdf_path#\"}" ; github_pdf_path="${github_pdf_path%\'}" ; github_pdf_path="${github_pdf_path#\'}"

    if [[ "${pinned_str,,}" == "y" ]]; then
        pinned=1
    fi
    if [[ "${complete_str,,}" == "y" ]]; then
        complete=1
    fi

    echo ""
    echo "The following project will be registered:"
    echo -e "    title: \e[33m$name\e[0m"
    echo -e "    folder: \e[33m$folder\e[0m"
    echo -e "    pdf path: \e[33m$pdf_path\e[0m"
    echo -e "    book path: \e[33m$book_path\e[0m"
    if [ $pinned -eq 1 ]; then echo -e "    pinned: \e[34mYes\e[0m"
    else echo -e "    pinned: \e[31mNo\e[0m"
    fi
    if [ $complete -eq 1 ]; then echo -e "    complete: \e[34mYes\e[0m"
    else echo -e "    complete: \e[31mNo\e[0m"
    fi
    echo -e "    github file: \e[36m$github_pdf_path\e[0m"

    # Final confirmation
    read -ep "Press Y to continue and any other key to abort: " get_continue
    if [[ "${get_continue,,}" != "y" ]]; then
        return
    fi

    # Check for duplicate github_pdf_path
    duplicate_gh_files=$(sqlite3 data.sqlite "SELECT github_pdf_path FROM projects WHERE github_pdf_path IN ('$github_pdf_path');")
    if [ -n "$duplicate_gh_files" ]; then
        read -ep "Error: GitHub file already exists. Press enter to continue: " error_continue;
        return;
    fi

    # Insert into database
    { # try
        sqlite3 data.sqlite "INSERT INTO projects (name, folder, pdf_path, book_path, pinned, complete, github_pdf_path, last_commit) \
            values ('$name', '$folder', '$pdf_path', '$book_path', $pinned, $complete, '$github_pdf_path', 'N/A');"
        
    } || { # catch
        read -ep "Failed to insert to database. Press enter to continue: " error_continue
    }
}

# Edit project details
edit_project() {
    declare -i PROJ_ID="$1";

    # Convert to actual array counter index
    PROJ_ID=${ids[$PROJ_ID]};
    
    echo ""
    echo "[EDITING PROJECT $1]"
    echo -e "Editing: \e[33m${names[$PROJ_ID]}\e[0m";
    echo "Leave out file suffixes. All quotation marks will be stripped."
    echo ""

    # Default values
    name="${names[$PROJ_ID]}";
    folder="${folders[$PROJ_ID]}";
    pdf_path="${pdf_paths[$PROJ_ID]}";
    book_path="${book_paths[$PROJ_ID]}";
    declare -i pinned="${pinned[$PROJ_ID]}";
    declare -i complete="${complete[$PROJ_ID]}";
    github_pdf_path="${github_pdf_paths[$PROJ_ID]}";

    # -r: don't escape slashes.
    read -rep "Name: " -i "$name" name
    read -rep "Project folder: " -i "$folder" folder
    read -rep "Path to PDF file: " -i "$pdf_path" pdf_path
    read -rep "Path to book (or leave blank): " -i "$book_path" book_path
    
    if [ $pinned -eq 1 ]; then read -rep "Pin? (Y/N): " -i "Y" pinned_str;
    else read -rep "Pin? (Y/N): " -i "N" pinned_str;
    fi
    if [ $complete -eq 1 ]; then read -rep "Complete? (Y/N): " -i "Y" complete_str;
    else read -rep "Complete? (Y/N): " -i "N" complete_str;
    fi
    
    read -rep "PDF file name within GitHub site: " -i "$github_pdf_path" github_pdf_path

    # Strip quotation marks
    name="${name%\"}" ; name="${name#\"}" ; name="${name%\'}" ; name="${name#\'}"
    folder="${folder%\"}" ; folder="${folder#\"}" ; folder="${folder%\'}" ; folder="${folder#\'}"
    pdf_path="${pdf_path%\"}" ; pdf_path="${pdf_path#\"}" ; pdf_path="${pdf_path%\'}" ; pdf_path="${pdf_path#\'}"
    book_path="${book_path%\"}" ; book_path="${book_path#\"}" ; book_path="${book_path%\'}" ; book_path="${book_path#\'}"
    github_pdf_path="${github_pdf_path%\"}" ; github_pdf_path="${github_pdf_path#\"}" ; github_pdf_path="${github_pdf_path%\'}" ; github_pdf_path="${github_pdf_path#\'}"

    if [[ "${pinned_str,,}" == "y" ]]; then
        pinned=1;
    else
        pinned=0;
    fi
    if [[ "${complete_str,,}" == "y" ]]; then
        complete=1;
    else
        complete=0;
    fi

    echo ""
    echo "The following project will be registered:"
    echo -e "    title: \e[33m$name\e[0m"
    echo -e "    folder: \e[33m$folder\e[0m"
    echo -e "    pdf path: \e[33m$pdf_path\e[0m"
    echo -e "    book path: \e[33m$book_path\e[0m"
    if [ $pinned -eq 1 ]; then echo -e "    pinned: \e[34mYes\e[0m";
    else echo -e "    pinned: \e[31mNo\e[0m";
    fi
    if [ $complete -eq 1 ]; then echo -e "    complete: \e[34mYes\e[0m";
    else echo -e "    complete: \e[31mNo\e[0m";
    fi
    echo -e "    github file: \e[36m$github_pdf_path\e[0m"

    # Final confirmation
    read -ep "Press Y to continue and any other key to abort: " get_continue
    if [[ "${get_continue,,}" != "y" ]]; then
        return
    fi

    # Insert into database
    { # try
        
        # Convert to database index
        PROJ_ID=${raw_ids[$PROJ_ID]};

        # Check for duplicate github_pdf_path
        duplicate_gh_files=$(sqlite3 data.sqlite "SELECT github_pdf_path,id FROM projects WHERE github_pdf_path IN ('$github_pdf_path') AND id != $PROJ_ID;");
        if [ -n "$duplicate_gh_files" ]; then
            read -ep "Error: GitHub file already exists. Press enter to continue: " error_continue;
            return;
        fi

        sqlite3 data.sqlite "UPDATE projects SET name='$name', folder='$folder', pdf_path='$pdf_path', book_path='$book_path', pinned=$pinned, complete=$complete, github_pdf_path='$github_pdf_path' WHERE id=$PROJ_ID;"

    } || { # catch
        read -ep "Failed to update database. Press enter to continue: " error_continue
    }
}

# Open specific project: VSCode, PDF, book options
open_project() {
    INPUT="$1";

    # Default: ID 0
    declare -i id_to_open=0;
    id_to_open="${INPUT:5:1}";
    echo "Opening project #$id_to_open...";

    # Convert between visual ID and database ID
    id_to_open=${ids[$id_to_open]};
    
    # Temporarily set IFS and read the string into an array
    delimiter="-"
    IFS="$delimiter" read -ra FLAGS <<< "${INPUT:6}"

    p_set=false
    v_set=false
    b_set=false

    # Iterate over the resulting array
    for flag in "${FLAGS[@]}"; do
        # Check if characters appear
        [[ "$flag" == *"p"* ]] && p_set=true;
        [[ "$flag" == *"b"* ]] && b_set=true;
        [[ "$flag" == *"v"* ]] && v_set=true;
    done

    if $p_set; then
        start "" "${pdf_paths[$id_to_open]}";
    fi
    if $v_set; then
        code "${folders[$id_to_open]}";
    fi
    if $b_set; then
        if [[ -n "${book_paths[$id_to_open]}" ]]; then
            start "" "${book_paths[$id_to_open]}";
        else
            echo "No book path associated with project.";
        fi
    fi

    # Default: open PDF
    if ! $p_set; then
        if ! $v_set; then
            if ! $b_set; then
                echo "No flags were set. Opening PDF."
                start "" "${pdf_paths[$id_to_open]}";
            fi
        fi
    fi

    echo "";
}

# Delete project screen (double-confirmation)
delete_project() {
    declare -i PROJ_ID="$1";
    
    # Convert to database index
    PROJ_ID=${ids[$PROJ_ID]};

    echo ""
    echo "[DELETING PROJECT $1]";
    echo -e "Deleting: \e[33m${names[$PROJ_ID]}\e[0m";

    # Double-confirmation
    read -rep "Confirm deletion (Y/N): " confirm

    if [[ "${confirm,,}" == "y" ]]; then
        # Convert to raw database ID
        PROJ_ID=${raw_ids[$PROJ_ID]};

        sqlite3 data.sqlite "DELETE FROM projects WHERE id=$PROJ_ID;" || {
            read -ep "Failed to delete project. Press enter to continue: " error_continue
        }
    fi
}

# Commit some projects
commit_project() {
    INPUT="$1";

    # Temporarily set IFS and read the string into an array
    delimiter=" "
    IFS="$delimiter" read -ra PROJECT_IDS <<< "${INPUT}"

    # Print projects
    echo "The following will be committed to the GitHub site:";
    for (( i=0; i<${#PROJECT_IDS[@]}; i++ )); do
        proj_id=${PROJECT_IDS[i]};
        proj_id=${proj_id:0:1};
        PROJECT_IDS[$i]=${ids[$proj_id]};

        echo -e "  \e[33m${names[${PROJECT_IDS[$i]}]}\e[0m"
    done

    echo ""

    # Double-confirmation
    read -rep "Confirm the procedure (Y/N): " confirm

    if [[ "${confirm,,}" != "y" ]]; then
        return;
    fi


    { # try
        # Go to website
        cd "$WEBSITE_PATH";
        
        for (( i=0; i<${#PROJECT_IDS[@]}; i++ )); do
            # Copy file from folder to website path (replace as necessary)
            proj_id=${PROJECT_IDS[$i]};

            if [[ "${github_pdf_paths[$proj_id]}" == "" ]]; then
                echo -e "\e[31mError\e[0m: No GitHub PDF corresponds to \e[33m${names[$proj_id]}\e[0m. Moving to next.";
                continue;
            fi

            cp -f "${pdf_paths[$proj_id]}" "${WEBSITE_FILES_PATH}${github_pdf_paths[$proj_id]}.pdf";

            # Stage commits
            git add data/documents/"${github_pdf_paths[$proj_id]}.pdf";
        done

        # Commit
        git commit -m "update notes (automatic from notes_manager)";
        git push origin main;

        # Update "last_commit" column
        cd -;
        for (( i=0; i<${#PROJECT_IDS[@]}; i++ )); do
            # Raw database ID
            proj_id=${PROJECT_IDS[$i]};

            # If not committed, don't update
            if [[ "${github_pdf_paths[$proj_id]}" == "" ]]; then
                continue;
            fi

            PROJECT_IDS[$i]=${raw_ids[$proj_id]};
            
            # Update "last_committed" dates
            last_commit=$(date +"%Y-%m-%d %T");
            sqlite3 data.sqlite "UPDATE projects SET last_commit='$last_commit' WHERE id=${PROJECT_IDS[$i]};"
        done

        echo "";
        read -ep "Press enter to continue: " done_continue;

    } || { #catch
        read -ep "Failed to update database. Press enter to continue: " error_continue;
    }
}

# Debugging purposes
debug() {
    counter=0
    for id in "${ids[@]}"; do
        echo "[counter] $counter | [id] $id | [raw_id] ${raw_ids[$counter]} | [name] ${names[$counter]}";
        let counter++;
    done
}

# Main loop
while(true)
do
    load_projects

    echo ""
    echo -e "Enter \e[31mhelp\e[0m for a list of commands, or start editing."
    read -ep "Enter input: " user_input

    # Commands so far: help, open, clear, new, edit, delete, commit
    
    # Valid commands
    while [[ "$user_input" != "help" && "${user_input:0:4}" != "open" && "${user_input:0:6}" != "delete" && "${user_input:0:4}" != "edit" && "${user_input:0:6}" != "commit" && "$user_input" != "clear" && "$user_input" != "new" ]]; do
        read -ep "Invalid input. Enter again: " user_input;
    done

    # Should we keep looping or clear the screen?
    # Certain commands = loop
    loop=false;
    [[ "$user_input" == "help" ]] && loop=true;
    [[ "${user_input:0:4}" == "open" ]] && loop=true;

    while $loop;
    do
        # 'help', 'open'
        [[ "$user_input" == "help" ]] && print_docs;
        [[ "${user_input:0:4}" == "open" ]] && open_project "$user_input";

        # Take input again
        loop=false;

        read -ep "Enter input: " user_input
        [[ "$user_input" == "help" ]] && loop=true;
        [[ "${user_input:0:4}" == "open" ]] && loop=true;
    done


    # For the following inputs, we want to clear the screen at the end.
    # Hence no while loops are used.
    # New project
    [[ "$user_input" == "new" ]] && {
        add_project
        printf '\033c';
    };

    # Edit project
    [[ "${user_input:0:4}" == "edit" ]] && {
        edit_project "${user_input:5:1}"
        printf '\033c';
    };

    # Delete project
    [[ "${user_input:0:6}" == "delete" ]] && {
        delete_project "${user_input:7:1}"
        printf '\033c';
    };

    # Commit projects
    [[ "${user_input:0:6}" == "commit" ]] && {
        commit_project "${user_input:7}"
        printf '\033c';
    };

    # Clear screen
    [[ "$user_input" == "clear" ]] && {
        printf '\033c';
    };

done
