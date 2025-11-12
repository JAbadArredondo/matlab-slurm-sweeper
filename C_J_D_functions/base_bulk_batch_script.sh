#!/bin/bash
# =====================================
#  Auto-generated batch submission file
# =====================================

# Folder list (MATLAB will replace this)
folders=%FOLDER_LIST

# Job script name
JOBSCRIPT="%JOBSCRIPT_NAME"

# Loop through folders
for folder in "${folders[@]}"; do 
    # list what we are doing
    echo "Submitting job in folder: $folder"
    
    # Go into the folder, if it exists
    if cd "$folder" 2>/dev/null; then
        #Debug:
        #Tell me where you are, so I know it is right
        #echo "Current path: $(pwd)"

        #Once everything works, you can run this:
        sbatch "$JOBSCRIPT"
        cd ..

    else #No folder with such name exists, skip it.
        echo "Warning: folder $folder not found, skipping."
    fi

done


 
