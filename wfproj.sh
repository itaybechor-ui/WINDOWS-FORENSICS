#!/bin/bash

# ==== Global variables for results ====
SECONDS=0                             
DATA_DIR="$HOME/wfproj/data"          
REPORT="$DATA_DIR/report.txt"          
export PATH="$PATH:/usr/games"
# ---------------- Logging (Windows Forensics) ----------------

RUN_TS="$(date '+%Y%m%d_%H%M%S')"
RUN_LOG_DIR="$LOG_DIR/$RUN_TS"

mkdir -p "$RUN_LOG_DIR"

TOOLS_LOG="$RUN_LOG_DIR/tools.log"
FILES_LOG="$RUN_LOG_DIR/files_summary.log"
RUN_LOG="$RUN_LOG_DIR/run.log"
clear

# ================================================================
#  Professional Header Banner (Cyber Security Style)
# ================================================================

clear

# ================================================================
#  Professional Header Banner (Cyber Security Style)
# ================================================================

clear

# ================================================================
#  Professional Header Banner (Cyber Security Style)
# ================================================================

echo " .---------------------------------------------------------------------------." | lolcat
echo " |                                                                           |" | lolcat
echo " |   ██     ██ ██ ███    ██ ██████   ██████  ██     ██ ███████  ███████      |" | lolcat
echo " |   ██     ██ ██ ████   ██ ██   ██ ██    ██ ██     ██ ██       ██           |" | lolcat
echo " |   ██  █  ██ ██ ██ ██  ██ ██   ██ ██    ██ ██  █  ██ █████    ███████      |" | lolcat
echo " |   ██ ███ ██ ██ ██  ██ ██ ██   ██ ██    ██ ██ ███ ██ ██            ██      |" | lolcat
echo " |    ███ ███  ██ ██   ████ ██████   ██████   ███ ███  ███████  ███████      |" | lolcat
echo " |                                                                           |" | lolcat
echo " |                             WINDOWS FORENSICS                             |" | lolcat
echo " |                          Project by: Itay Bechor                          |" | lolcat
echo " |                                                                           |" | lolcat
echo " '---------------------------------------------------------------------------'" | lolcat


# 1.1 – Check if the script is running as root; if not, exit.

if [ "$(whoami)" = "root" ]; then       
 # Run 'whoami' and compare its output to the string "root"
 
  echo "[+] You are root!!"
  # Inform the user that the script is running with root privileges

else
  # If the current user is not root

  echo "[-] You are not root.  exiting ..."
  # Print an error message indicating insufficient privileges
  
exit 
  # Exit the script immediately to prevent running without root

fi 
    # End of the root-check conditional block
 
 

# 1.2 – Ask the user for a memory image file and verify that it exists.


read -p "Please enter a memory file to analyze: " MEM
# Prompt the user with the message and read their input into the variable MEM

MEM="$(realpath "$MEM" 2>/dev/null || printf "%s" "$MEM")"
# Try to resolve MEM into an absolute path using 'realpath'
# Redirect any realpath error messages to /dev/null (so they are not shown on screen)
# If realpath fails (for example if the path is not valid), use the original value of MEM instead
# Assign the resulting path (absolute or original) back into the MEM variable


echo "[*] The memory file to analyze is : $MEM"
# Display the final memory file path that will be used for the analysis



if [ -f "$MEM" ]; then
 # Test if there is a regular file at the path stored in MEM

  echo "[+] File exists"
  # Confirm that the memory image file exists

else
 # If the file does not exist or is not a regular file

  echo "[-] File does not exist"
   # Inform the user that the given path is invalid

fi
 # End of the file-existence check
 



# 1.3 Create a function to install the forensics tools if they are missing.
 INSTL() 
{
    APPS=("foremost" "binwalk" "scalpel" "bulk-extractor" "strings" "exiftool")
    # Create an array named APPS that contains all required forensic tools.
    # Each tool name is a separate element inside the array.


    for i in "${APPS[@]}"; do
    # Loop through each item in the APPS array

        if command -v "$i" >/dev/null 2>&1; then
         # 'command -v' checks whether the tool exists in the system PATH.
        # Redirecting both stdout and stderr to /dev/null hides any output.
        # If the tool exists, the condition is TRUE.

            echo "[+] $i is already installed"
            # Inform the user that this specific tool is already installed. 
            
        else
            echo "[-] $i is not installed"
            # Inform the user that the tool was not found on the system.

            echo "[*] Installing $i..."
             # Print a message indicating that installation is starting.


            apt-get install -y "$i"
             # Install the missing tool using apt-get.
            # The -y flag automatically answers "yes" to installation prompts.

        fi
        # End of if/else block

    done
    # End of the loop over APPS

    
}


# 1.4 Use different carvers to automatically extract data
# 1.5 Data should be saved into a directory
CVRS() 
{
	
	# Create the output directory path inside the user's home

  
  DIR="$HOME/wfproj/data"
   # Directory where carved data will be stored

  echo "[*] Preparing output dir: $DIR"
  
  rm -rf "$DIR"
   # Remove previous directory if it exists (ensures clean output)

  mkdir -p "$DIR"
   # Create the output directory (including parent dirs)



    #########################################################
    # BINWALK
    #########################################################


      # Check if binwalk exists in PATH

  
  if command -v binwalk >/dev/null 2>&1; then
       # Tests if the 'binwalk' tool is installed

    echo "[*] Running binwalk -> $DIR/binwalk.txt"
      # Run binwalk against memory image and save output

    binwalk "$MEM" > "$DIR/binwalk.txt" 2>/dev/null || true
     # Scans the memory dump for embedded files and signatures
        # Output redirected into binwalk.txt

  fi
     # End of if/else block
     
     
    #########################################################
    # STRINGS
    #########################################################

     
      # Check if strings exists
  
  if command -v strings >/dev/null 2>&1; then
     # Tests if the 'strings' tool is installed

    echo "[*] Running strings -> $DIR/strings.txt"
    # Extract readable ASCII/Unicode strings

    strings -a -n 8 "$MEM" > "$DIR/strings.txt" 2>/dev/null || true
    # -a = scan entire file
        # -n 8 = minimum string length 8 chars
  fi


    #########################################################
    # EXIFTOOL
    #########################################################

# Check if exiftool exists
  
  if command -v exiftool >/dev/null 2>&1; then
      #  Tests if the 'exiftool' tool is installed

    echo "[*] Running exiftool -> $DIR/exif.txt"
     # Extract metadata from the memory image

    exiftool "$MEM" > "$DIR/exif.txt" 2>/dev/null || true
      #  Reads metadata fields that may appear in carved files

  fi

    #########################################################
    # SCALPEL
    #########################################################

      # Check if scalpel is installed

  
  if command -v scalpel >/dev/null 2>&1; then
     # Tests if scalpel exists

    echo "[*] Running scalpel -> $DIR/scalpel/"
    mkdir -p "$DIR/scalpel"
     # Output folder for scalpel results

    scalpel "$MEM" -o "$DIR/scalpel" -q || true
     #  Carves files using rules defined in scalpel.conf
        #  -o sets output directory
        #  -q quiet mode

  fi
  
  
  #########################################################
    # FOREMOST
    #########################################################

       # Check if foremost is installed

  
  
  if command -v foremost >/dev/null 2>&1; then
     #  Tests if foremost exists

    echo "[*] Running foremost -> $DIR/foremost/"
    mkdir -p "$DIR/foremost"
     #  Create output folder

    foremost -i "$MEM" -o "$DIR/foremost" -q || true
       # Carves files by file headers/footers (jpg, pdf, doc, zip, etc.)

  fi
    
    
    #########################################################
    # BULK_EXTRACTOR
    #########################################################

    
        # Check if bulk_extractor is installed
    
  
  if command -v bulk_extractor >/dev/null 2>&1; then
  # Tests if the tool exists

    echo "[*] Running bulk_extractor -> $DIR/bulki/"
    mkdir -p "$DIR/bulki"
    # Create output folder

    bulk_extractor -o "$DIR/bulki" "$MEM" || true
     # Extracts email addresses, URLs, credit card patterns, pcap files, artifacts, etc.

  fi
  
  
     #########################################################
    # FINAL STATUS
    #########################################################

  
  
  
  
  echo "[+] Carving done. Output saved under: $DIR"
  echo "[*] Quick listing:"
     #  Print the first 200 lines of the output directory listing
  ls -1 "$DIR" | sed -n '1,200p' || true
  
}

# ---------------------------
# 1.6 Attempt to extract network traffic (PCAP)
# ---------------------------
PCAP() {
  set -euo pipefail
  # set -e  -> exit immediately if any command returns a non-zero status
    # set -u  -> treat use of undefined variables as an error
    # set -o pipefail -> if any command in a pipeline fails, the whole pipeline fails

  info() { printf "\e[1;34m[]\e[0m %s\n" "$"; }
   # info(): helper function to print informational messages in blue


  warn() { printf "\e[1;33m[!]\e[0m %s\n" "$*"; }
    # warn(): helper function to print warning messages in yellow



  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # SCRIPT_DIR = absolute path of the directory where this script is located

  DIR="$SCRIPT_DIR/data"    
  # DIR = base output directory where all tool results are stored

                     
  MEM="${1:-/home/kali/wjproj/memdump.mem}"     
      # MEM = memory image to analyze
    # If the function gets a first argument -> use it
    # Otherwise use the default path to memdump.mem


  BULK_DIR="$DIR/bulki"
    # BULK_DIR = directory where bulk_extractor originally wrote its output

  NET_DIR="$DIR/bulki_net"
  # NET_DIR = directory where we will keep network related results (PCAP/PCAPNG)


  info "Searching for captured network traffic under: $DIR"
        # Inform the user that we are going to look for PCAP/PCAPNG files


 
  mapfile -t PCAPS < <(find "$DIR" -type f \( -iname ".pcap" -o -iname ".pcapng" \) 2>/dev/null || true)
  # Use find to look recursively under $DIR for files that end with .pcap or .pcapng
    # mapfile -t PCAPS  -> read all found paths into the bash array PCAPS
    # 2>/dev/null       -> hide error messages (e.g., permission denied)
    # || true           -> avoid failing the whole function if find exits non-zero


  
  if [ "${#PCAPS[@]}" -eq 0 ] && command -v bulk_extractor >/dev/null 2>&1; then
        # If no PCAP/PCAPNG files were found AND bulk_extractor is installed…

    info "No PCAPs yet. Running bulk_extractor -E net,tcp ..."
      # Tell the user we are trying to carve network traffic using bulk_extractor

    rm -rf "$NET_DIR"; mkdir -p "$NET_DIR"
     # Remove any previous network-output directory (if it exists)
     # Re-create a clean network-output directory

    bulk_extractor -E net,tcp -o "$NET_DIR" "$MEM" >/dev/null 2>&1 || true
      # Run bulk_extractor on the memory image
        #   -E net,tcp   -> enable the net and tcp scanners for network artifacts
        #   -o "$NET_DIR" -> write all results under $NET_DIR
        #   "$MEM"       -> input memory image
        # 2>/dev/null    -> hide verbose errors
        # || true        -> do not crash if bulk_extractor exits with an error

    mapfile -t PCAPS < <(find "$NET_DIR" -type f \( -iname ".pcap" -o -iname ".pcapng" \) 2>/dev/null || true)
      # After bulk_extractor finishes, search again for PCAP/PCAPNG files,
        # this time only under $NET_DIR, and store them in the PCAPS array

  fi

  if [ "${#PCAPS[@]}" -eq 0 ]; then
      # If we still have no PCAP/PCAPNG files after all attempts…

    warn "Network traffic not found."
       # Print a warning message to the user
       
    return 0
    # Exit the function gracefully without treating it as a fatal error

  fi
  
 # If we reach this point, PCAPS[] contains at least one PCAP/PCAPNG file

 
  for x in "${PCAPS[@]}"; do
     # Iterate over each captured PCAP/PCAPNG file
   
    size="$(ls -lh "$x" | awk '{print $5}')"
      # Use ls -lh to get a human-readable size (e.g., 2.0M, 850K)
        # awk '{print $5}' extracts only the size column

    echo "File Location:$x  File Size $size"
       # Print a one-line summary for this capture file
    done

  

  
  {
    echo "PCAP summary"; date
      # Header line in the summary file and  add current date/time to the summary


    for x in "${PCAPS[@]}"; do
        # Loop over all PCAP files again, this time for the summary report

      size="$(ls -lh "$x" | awk '{print $5}')"
        # Get human-readable size again

      echo "$size  $x"
       # Write "size path" into the summary (good for quick grep/sorting)

    done
  } > "$DIR/pcap_summary.txt"
  info "Saved summary -> $DIR/pcap_summary.txt"
  # Final message to the user with the exact path of the summary file

}

PCAP() 
{
	
 x="$(find "$DIR" -type f -name 'packets.pcap' -print -quit)"
    # Use 'find' to search under $DIR for the first file named 'packets.pcap'
    # -print -quit -> stop after the first match and return its path into variable x


if [ -n "$x" ]; then
    # If x is not empty, it means a PCAP file was found

  
  y="$(ls -lh "$x" | awk '{print $5}')"
  # Get human-readable size of that PCAP and store it in y

  echo "File Location:$x  File Size $y"
   # Print location and size of the found packets.pcap file

else
  # If x is empty, no matching PCAP was found

  echo "[!] Network traffic not found under: $DIR"
   # Inform the user that no network traffic capture file exists in $DIR

fi

 
 
 
 
}





# ----- 1.7 Check for human-readable (exe files, passwords, usernames, etc.) ----
STR() {

    # Print status message for the analyst
    echo "[*] Checking for human-readable artifacts (strings, passwords, usernames, etc.) ..."

    # Create an output directory for all string-based results.
    # -p  : create parent directories if needed
    # 2>/dev/null : hide 'already exists' warnings
    # || true : never fail the script if mkdir returns an error
    mkdir -p "$DATA_DIR/strings" 2>/dev/null || true

    # Define a list of interesting keywords to search for in the memory image.
    # These are typical indicators for credentials or sensitive data.
    local TERMS=(exe password username http https dll login pass cred token apikey)

    # Loop over each keyword and create a dedicated output file for it
    for term in "${TERMS[@]}"; do

        # Build the output filename for this specific keyword
        out="$DATA_DIR/strings/${term}.txt"

        # Extract all printable strings from the memory image and search for the keyword.
        # strings -a      : scan the whole file (not only text sections)
        # -n 4            : only strings with minimum length 4 characters
        # "$MEM"          : the memory dump file to analyze
        # 2>/dev/null     : hide warnings/errors from strings
        # grep -Ei        : case-insensitive search using extended regex
        # "$term"         : the current keyword we are looking for
        # > "$out"        : save all matching lines to the keyword file
        # || true         : do not stop the script if grep finds nothing
        strings -a -n 4 "$MEM" 2>/dev/null \
            | grep -Ei "$term" > "$out" || true

        # If the output file is non-empty, report it to the analyst
        # -s : test 'file exists and size > 0'
        if [ -s "$out" ]; then

            # Get human-readable size of the file (e.g. 4K, 12K, 1.3M)
            # ls -lh   : long listing, human readable
            # awk '{print $5}' : take only the size column
            sz=$(ls -lh "$out" | awk '{print $5}')

            # Print a short status line with keyword, file path and size
            echo "[*] Found '$term' -> $out ($sz)"
        fi
    done

    # Create a global summary file with ANY of the important patterns.
    # This lets the analyst review everything in one place.
    # The regex covers: exe, password, username, login, user, http/https, dll, token, apikey, cred
    strings -a -n 4 "$MEM" 2>/dev/null \
        | grep -Ei 'exe|password|username|login|user[^A-Za-z]|http|https|\.dll|token|apikey|cred' \
        > "$DATA_DIR/strings/all_hits.txt" || true

    # If the summary file has content, notify the user where it is stored
    if [ -s "$DATA_DIR/strings/all_hits.txt" ]; then
        echo "[*] Summary saved: $DATA_DIR/strings/all_hits.txt"
    else
        # Otherwise, mention that nothing matched our patterns
        echo "[!] No human-readable hits found (with current patterns)."
    fi

    # (Optional) WinPE scan using bulk_extractor this is still part of 1.7,
    # but focused on WinPE artifacts, registry hives, DLL paths, etc.
    if command -v bulk_extractor >/dev/null 2>&1; then
        # Create output directory for WinPE module results
        mkdir -p "$DATA_DIR/bulki_winpe" 2>/dev/null || true

        # Run bulk_extractor with the winpe module
        # -E winpe         : enable WinPE extractor
        # -o <dir>         : output directory
        # "$MEM"           : memory image to scan
        bulk_extractor -E winpe -o "$DATA_DIR/bulki_winpe" "$MEM" >/dev/null 2>&1 || true

        # List all files created by the WinPE module and save the index
        find "$DATA_DIR/bulki_winpe" -type f -maxdepth 1 -ls \
            > "$DATA_DIR/strings/winpe_list.txt" 2>/dev/null || true

        # Final status line for the WinPE scan
        echo "[*] WinPE scan done (bulk_extractor). Index: $DATA_DIR/strings/winpe_list.txt"
    fi

}  # end STR()

# ---- end 1.7 ----


VOL_BIN="/home/kali/wjproj/volatility_2.5.linux.standalone/volatility_2.5_linux_x64"

# Path to the Volatility binary (stand-alone Linux version)


# 2.1 Check if the file can be analyzed in Volatility; if yes, run Volatility.
function VOL()
{
    echo "[+] Checking if the memory file can be analyzed with Volatility..."
    # Inform the user that we are about to verify the memory image with Volatility


    if "$VOL_BIN" -f "$MEM" imageinfo 2>/dev/null | grep -q "No suggestion"; then
     # Run 'imageinfo' on the memory file.
    # If Volatility prints 'No suggestion', it means the file is NOT a valid memory image.

        echo "[!] This is not a memory file"
         # Negative result: this is not a supported memory image

        return 1
        # Return non-zero so the caller knows the check failed

    else
        echo "[+] This is a memory file"
        # Positive result: Volatility was able to analyze the file

        return 0
        # Return success (0) so the script can continue

    fi
}

# 2.2 Find the memory profile and save it into a variable.
function VOL_PROFILE() {

    # Let the user know we are determining the correct Volatility profile
    echo "[+] Detecting Volatility profile..."

    VOL_PROFILE=$(
        "$VOL_BIN" -f "$MEM" imageinfo 2>/dev/null |  # Run imageinfo quietly on the memory file
        grep "Suggested Profile"                 |  # Filter the line that contains the suggested profiles
        awk '{print $4}'                         |  # Extract the 4th field (first suggested profile)
        tr -d ','                                  # Remove any trailing comma from the profile name
    )
    # Now VOL_PROFILE holds something like: WinXPSP2x86

   # Display the detected profile to the analyst
echo "[+] Detected Volatility profile: $VOL_PROFILE"

# Save the profile into a file under $DATA_DIR
echo "$VOL_PROFILE" > "$DATA_DIR/vol_profile.txt"

}

  # -------------------------------------------------------
# 2.3 Display running processes using Volatility
# -------------------------------------------------------
function VOL_PROCS() {
    echo "[*] Extracting running processes ..."
     # Inform the analyst that process extraction is starting


# Run Volatility with:
    #   $VOL_BIN       Path to the Volatility standalone executable
    #   -f "$MEM"     The memory image file specified earlier
    #   --profile      The OS memory profile previously detected
    #   pslist        Volatility plugin that lists active processes
    #
    # Redirect output:
    #   >    Write output to vol_processes.txt
    #   2>&1  Redirect errors to the same file
    


    "$VOL_BIN" -f "$MEM" --profile="$VOL_PROFILE" pslist \
        > "$DATA_DIR/vol_processes.txt" 2>&1

      # Notify the user where the output file was saved
    echo "[+] Saved running processes to: $DATA_DIR/vol_processes.txt"
}

  # -------------------------------------------------------
# 2.4 Display network connections
# -------------------------------------------------------
function VOL_NET() {
	
	 # Inform the analyst that network extraction is starting
    echo "[*] Extracting network connections ..."
    
    # For Windows XP memory images, Volatility uses:
    #   connections lists active or recently closed TCP connections
    #
    # Parameters:
    #   $VOL_BIN     Path to the Volatility executable
    #   -f "$MEM"     The memory dump to analyze
    #   --profile     The detected OS memory profile
    #
    # Redirect all output and errors into the output file
  
    

    # For Windows XP memory dumps, use connections or connscan
    "$VOL_BIN" -f "$MEM" --profile="$VOL_PROFILE" connections \
        > "$DATA_DIR/vol_network.txt" 2>&1

            # Inform the user where the results were saved
    echo "[+] Saved network connections to: $DATA_DIR/vol_network.txt"
}
  
  
  
  # -------------------------------------------------------
# 2.5 Attempt to extract registry information
# -------------------------------------------------------

VOL_REG() {

    echo "[*] Extracting registry information ..."

    #  Dump the list of registry hives from the memory image
    #    This creates vol_hives.txt with all hive paths and virtual addresses.
    "$VOL_BIN" -f "$MEM" --profile="$VOL_PROFILE" hivelist \
        > "$DATA_DIR/vol_hives.txt" 2>/dev/null

    echo "[+] Saved registry hive list to: $DATA_DIR/vol_hives.txt"

    #  Use Volatility printkey on the SOFTWARE key
    #    This is exactly what produces the output style I saw 
    #    Legend, Registry , Key name  Software, Last updated, Subkeys, Values.
    "$VOL_BIN" -f "$MEM" --profile="$VOL_PROFILE" printkey \
        -K "Software" \
        > "$DATA_DIR/vol_registry_info.txt" 2>/dev/null

    echo "[+] Registry information saved to: $DATA_DIR/vol_registry_info.txt"
}
  
  
  
  
  




# 3. Results
# 3.1 Display general statistics (time of analysis, number of found files, etc.)
# 3.2 Save all the results into a report (name, files extracted, etc.)

RESULTS() {

    echo "[*] Generating analysis summary ..."

    # -----------------------------------------------------------
    # Calculate how long the script has been running (in seconds)
    # -----------------------------------------------------------
    ANALYSIS_TIME="${SECONDS}"

    # -----------------------------------------------------------
    # Count how many files were created under the data directory
    # -----------------------------------------------------------
    TOTAL_FILES=$(find "$DATA_DIR" -type f | wc -l)

    # -----------------------------------------------------------
    # Write the full forensic report into the report file
    # Everything inside { } goes ONLY to $REPORT (not printed)
    # -----------------------------------------------------------
    {
        echo "================ Forensic Analysis Report ==================="
        echo
        echo "Date               : $(date)"          # Current date/time
        echo "Memory image file  : $MEM"             # Input memory dump
        echo "Data directory     : $DATA_DIR"        # Output data dir
        echo
        echo "Analysis time      : $ANALYSIS_TIME s" # Total run time
        echo "Total files found  : $TOTAL_FILES"     # Files extracted
        echo
        echo "Subdirectories under data:"            # List dirs
        find "$DATA_DIR" -maxdepth 1 -type d -printf "  %f\n"
        echo
        echo "Files per subdirectory:"               # Count per folder
        for d in "$DATA_DIR"/*; do
            [ -d "$d" ] || continue
            count=$(find "$d" -type f | wc -l)
            echo "  $(basename "$d") : $count files"
        done
        echo "===================================================================="
        echo
    } > "$REPORT"   # Redirect everything above into report.txt

    # -----------------------------------------------------------
    # Print only the short summary to the screen
    # -----------------------------------------------------------
    echo "Analysis time      : $ANALYSIS_TIME s"
    echo "Total files found  : $TOTAL_FILES"

    # -----------------------------------------------------------
    # Tell the user where the report was saved
    # -----------------------------------------------------------
    echo "[+] Report saved to: $REPORT"


    # 3.3 Zip the extracted files and the report file
    echo                                    # Print a blank line for readability
    echo "[*] Creating ZIP archive with all extracted files and the report ..."

    BASE_DIR=$(dirname "$DATA_DIR")        # Get the parent directory of DATA_DIR
    ZIP_FILE="$BASE_DIR/wfproj_results.zip" # Full path/name of the ZIP archive to create

    # Check if the zip command exists on this system
    if command -v zip >/dev/null 2>&1; then
        (
            cd "$BASE_DIR" || exit 1       # Change into BASE_DIR or exit on failure

            # Create a ZIP archive with:
            #   the entire data directory
            #   the final report file
            zip -r "$(basename "$ZIP_FILE")" \
                   "$(basename "$DATA_DIR")" \
                   "$(basename "$REPORT")" >/dev/null 2>&1
        )

        echo "[+] ZIP archive saved to: $ZIP_FILE"  # Inform the user where the ZIP was saved
    else
        # If zip is not installed, notify the user and skip this step
        echo "[!] 'zip' command not found. Skipping ZIP creation."
    fi
    
}



log_run_summary() {
  echo "[*] Creating run summary logs under: $RUN_LOG_DIR"

  local tools=("binwalk" "strings" "exiftool" "scalpel" "foremost" "bulk_extractor")

  printf "[%s] Windows Forensics run (memory=%s, data_dir=%s, tools=%s)\n" \
    "$(date '+%Y-%m-%d %H:%M:%S')" \
    "$MEM" \
    "$DATA_DIR" \
    "${tools[*]}" > "$RUN_LOG"

  for tool in "${tools[@]}"; do
    printf "[%s] %s executed (memory=%s, data_dir=%s)\n" \
      "$(date '+%Y-%m-%d %H:%M:%S')" \
      "$tool" \
      "$MEM" \
      "$DATA_DIR" >> "$TOOLS_LOG"
  done

  TS="$(date '+%Y-%m-%d %H:%M:%S')"

  {
    echo "================ Files summary for run at $TS ================"
    echo "Memory image : $MEM"
    echo "Data dir     : $DATA_DIR"
    echo

    TOTAL_FILES_RUN=$(find "$DATA_DIR" -type f | wc -l)
    echo "Total files found: $TOTAL_FILES_RUN"
    echo

    echo "Files per subdirectory:"
    for d in "$DATA_DIR"/*; do
      [ -d "$d" ] || continue
      count=$(find "$d" -type f | wc -l)
      printf "  %-15s : %s files\n" "$(basename "$d")" "$count"
    done
    echo

    echo "Files per extension (file types):"
    find "$DATA_DIR" -type f | sed -n 's/.*\.\([A-Za-z0-9]\{1,\}\)$/\1/p' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -nr | awk '{printf "  %-8s : %s files\n", $2, $1}'

    echo "=============================================================="
    echo
  } > "$FILES_LOG"

  echo "[+] Tools log saved to:  $TOOLS_LOG"
  echo "[+] Files summary saved to: $FILES_LOG"
  echo "[+] Run log saved to:    $RUN_LOG"
}

































INSTL
CVRS
PCAP
STR
VOL
VOL_PROFILE
VOL_PROCS
VOL_NET
VOL_REG
RESULTS
log_run_summary
