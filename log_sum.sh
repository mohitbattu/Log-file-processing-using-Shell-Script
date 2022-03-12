#!/bin/bash

# Note Please place your blacklist and log file under the same directory of bash file.
# Before Running the script ensure to change the location present in the directory variable.

# Variables Declaration

files=${!#}
argcount=$#
val=($*)
range=(2 3 4 5)

if [[ $files != "-" ]] && [[ $files != "thttpd.log" ]]; then
  if [[ ${range[*]} =~ ${argcount} ]]; then
    echo "Enter the log file name and specify the extenstion format too: "
    read -r "filename"
    val[${#val[@]}-1]=$filename
  else
   echo "Enter the log file name and specify the extenstion format too: "
   read -r "filename"
   val+=("$filename")
   argcount=$(( argcount + 1 ))
   fi
elif [[ $files = "-" ]]; then
    echo "Enter the log file name and specify the extenstion format too: "
    read -r "filename"
    val[${#val[@]}-1]=$filename
else 
    filename=${val[${#val[@]}-1]}
fi

len=${#val[@]}
directory=/home/mohit/Desktop/Shell_Programming_Lab_1_Assignment/
params=(-c -2 -r -F -t)
optn=(-n)
# Functions Declaration

# cleaning for common result
function preCleaningforResult(){
   # Below Awk is used for summing and ordered the data in decreasing order of each status codes.
   local getting=$(awk '$9 >= 200 && $9 <= 500 {print $9, $1}' "$filename" | sort -nr | uniq -c | sort -rn | sort -nrk1,1 |awk '{ if (data[$2] eq 0 && $2 eq $2)} {data[$2]=data[$2]+$1} END { for(var in data) { print var, "\t\t", data[var]}}' | sort -nrk2 | awk 'BEGIN { ORS=" " }{ print $1 }') 
   local dat=( "$getting" ) # (Storing and Reordering the Status codes in decreasing order)
   awk '$9 >= 200 && $9 <= 500 {print $9, $1}' "$filename" | sort -nr | uniq -c | sort -rn | sort -nrk1,1 > tmp.txt # (sorting the Data according to the highest count)
   for a in $dat
   do
   local arch=$(awk -v n="$a" '{if($2 == n) print}' tmp.txt)
   echo "${arch}" >> "data.txt"
   done
   rm tmp.txt
}
# cleaning for Failures
function preCleaningforFailures(){
   local gett=$(awk '$9 >= 400 && $9 <= 500 {print $9, $1}' "$filename" | sort -nr | uniq -c | sort -rn | sort -nrk1,1 |awk '{ if (data[$2] eq 0 && $2 eq $2)} {data[$2]=data[$2]+$1} END { for(var in data) { print var, "\t\t", data[var]}}' | sort -nrk2 | awk 'BEGIN { ORS=" " }{ print $1 }')
   local dat=( "$gett" )
   awk '$9 >= 400 && $9 <= 500 {print $9, $1}' "$filename"| sort -nr | uniq -c | sort -rn | sort -nrk1,1 > tmp.txt 
   for a in $dat
   do
   local arch=$(awk -v n="$a" '{if($2 == n) print}' tmp.txt)
   echo "${arch}" >> "data.txt"
   done
   rm tmp.txt
}
# Blacklisting Function
# Please wait for few minutes if requested for full search of the data.( log_sum.sh (-c|-2|-r|-F|-t) [-e] <filename> )
function blacklist(){
if [[ $data =~ ^[0-9]+$ ]]; then
awk '{ print $2 "\t\t" $1 }' "$tmpfile"| awk 'NR <='+"$data" > c.txt
else
awk '{ print $2 "\t\t" $1 }' "$tmpfile" > c.txt
fi
val=$(awk '{print $1}' c.txt | awk 'BEGIN { ORS=" " }{ print $1 }')
stored=( "$val" )
for a in $stored
do
# Below function is used to remove full stops at the end of the domain name and empty spaces present in the output.
c="$(nslookup "$a" | grep "name =" | cut -d " " -f 3 | sed -r 's/.$//' | grep -Ev "^$")"

if  [ "$c" != "" ]; then
    b=$(grep "$c" blacklistv2.txt)
    if [ "$b" != "" ]; then
        echo "Blacklisted!" >> ce.txt
    else
        echo " " >> ce.txt
  fi
else 
     echo " "  >> ce.txt
fi
done
paste c.txt ce.txt > fce.txt
rm c.txt ce.txt
}

# most number of request connection attempts
function highestRequestsCounting(){
    echo "Please wait for few seconds to minutes if you used an extension -e"
    printf "\tIP\t\tRequests \n"
    awk '{ print $1 }' "$filename" | sort -nr | uniq -c | sort -nr > tmp.txt
    if [[ ${params[*]} =~ ${val[$len/2 - 1]} ]] && [ $argcount != 4 ] && [ $argcount != 5 ] && [ $argcount != 3 ]; then 
    awk '{print $2 "\t\t" $1}' tmp.txt
    elif [ $argcount -eq 3 ] && [[ ${params[*]} =~ ${val[$len/2 - 1]} ]]; then
    tmpfile="tmp.txt"
    blacklist
    awk '{ print $1 "\t\t" $2,$3 }' fce.txt
    rm fce.txt
    elif [[ ${val[$len - 2]} =~ ^[0-9]+$ ]]; then
    local data=${val[$len - 2]}
    awk '{ print $2 "\t\t" $1 }' tmp.txt | awk 'NR <='+"$data"
    elif [[ ${val[$len - 4]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    tmpfile="tmp.txt"
    data=${val[$len - 4]}
    blacklist
    awk '{ print $1 "\t\t" $2,$3 }' fce.txt | awk 'NR <='+"$data"
    rm fce.txt
    elif [[ ${val[$len - 3]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    tmpfile="tmp.txt"
    data=${val[$len - 3]}
    blacklist
    awk '{ print $1 "\t\t" $2,$3}' fce.txt | awk 'NR <='+"$data"
    rm fce.txt
    else
    local data=${val[$len/2 - 1]}
    awk '{ print $2 "\t\t" $1 }' tmp.txt | awk 'NR <='+"$data"
    fi
    rm tmp.txt
}

# most successful attempts
function successfulAttempts(){
   echo "Please wait for few seconds to minutes if you used an extension -e"
   printf "\tIP\t\tSuccessfulAttempts\n"
   awk '$9 >= 200 && $9 < 400 {print $1,$9}' "$filename" | awk '{ print $1 }' | sort -nr | uniq -c | sort -nr > tmp.txt
    if [[ ${params[*]} =~ ${val[$len/2 - 1]} ]] && [ $argcount != 4 ] && [ $argcount != 5 ] && [ $argcount != 3 ]; then 
    awk '{print $2 "\t\t" $1}' tmp.txt
    elif [ $argcount -eq 3 ] && [[ ${params[*]} =~ ${val[$len/2 - 1]} ]]; then
    tmpfile="tmp.txt"
    blacklist
    awk '{ print $1 "\t\t" $2,$3 }' fce.txt
    rm fce.txt
    elif [[ ${val[$len - 2]} =~ ^[0-9]+$ ]]; then
    local data=${val[$len - 2]}
    awk '{ print $2 "\t\t" $1 }' tmp.txt | awk 'NR <='+"$data"
    elif [[ ${val[$len - 4]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    tmpfile="tmp.txt"
    data=${val[$len - 4]}
    blacklist
    awk '{ print $1 "\t\t" $2,$3 }' fce.txt | awk 'NR <='+"$data"
    rm fce.txt
    elif [[ ${val[$len - 3]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    tmpfile="tmp.txt"
    data=${val[$len - 3]}
    blacklist
    awk '{ print $1 "\t\t" $2,$3 }' fce.txt | awk 'NR <='+"$data"
    rm fce.txt
    else
    local data=${val[$len/2 - 1]}
    awk '{ print $2 "\t\t" $1 }' tmp.txt | awk 'NR <='+"$data"
    fi
    rm tmp.txt
}

# most unsuccessful attempts
function unsuccessfulAttempts(){
   echo "Please wait for few seconds to minutes if you used an extension -e"
    printf "Status\t\tIP\n"
    preCleaningforFailures
    if [[ ${params[*]} =~ ${val[$len/2 - 1]} ]] && [ $argcount != 4 ] && [ $argcount != 5 ] && [ $argcount != 3 ]; then 
    awk '{print $2 "\t" $3}' data.txt
    elif [ $argcount -eq 3 ] && [[ ${params[*]} =~ ${val[$len/2 - 1]} ]]; then
    awk '{ print $2 "\t" $3 }' data.txt > tmp1.txt
    tmpfile="tmp1.txt"
    blacklist
    awk '{ print $2 "\t" $1,$3 }' fce.txt
    rm tmp1.txt fce.txt
    elif [[ ${val[$len - 2]} =~ ^[0-9]+$ ]]; then
    local data=${val[$len - 2]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data"
    elif [[ ${val[$len - 4]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    data=${val[$len - 4]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data" > tmp1.txt
    tmpfile="tmp1.txt"
    blacklist
    awk '{ print $2 "\t" $1,$3 }' fce.txt | awk 'NR <='+"$data"
    rm tmp1.txt fce.txt
    elif [[ ${val[$len - 3]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    data=${val[$len - 3]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data" > tmp1.txt
    tmpfile="tmp1.txt"
    blacklist
    awk '{ print $2 "\t" $1,$3 }' fce.txt | awk 'NR <='+"$data"
    rm tmp1.txt fce.txt
    else
    local data=${val[$len/2 - 1]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data"
    fi
    rm data.txt
}

# common result 
function commonResultCode(){
    echo "Please wait for few seconds to minutes if you used an extension -e"
    printf "Status\t\tIP\n"
    preCleaningforResult
    if [[ ${params[*]} =~ ${val[$len/2 - 1]} ]] && [ $argcount != 4 ] && [ $argcount != 5 ] && [ $argcount != 3 ]; then 
    awk '{print $2 "\t" $3}' data.txt
    elif [ $argcount -eq 3 ] && [[ ${params[*]} =~ ${val[$len/2 - 1]} ]]; then
    awk '{ print $2 "\t" $3 }' data.txt > tmp1.txt
    tmpfile="tmp1.txt"
    blacklist
    awk '{ print $2 "\t" $1,$3 }' fce.txt
    rm tmp1.txt fce.txt
    elif [[ ${val[$len - 2]} =~ ^[0-9]+$ ]]; then
    local data=${val[$len - 2]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data"
    elif [[ ${val[$len - 4]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    data=${val[$len - 4]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data" > tmp1.txt
    tmpfile="tmp1.txt"
    blacklist
    awk '{ print $2 "\t" $1,$3 }' fce.txt | awk 'NR <='+"$data"
    rm tmp1.txt fce.txt
    elif [[ ${val[$len - 3]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
    data=${val[$len - 3]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data" > tmp1.txt
    tmpfile="tmp1.txt"
    blacklist
    awk '{ print $2 "\t" $1,$3 }' fce.txt | awk 'NR <='+"$data"
    rm tmp1.txt fce.txt
    else
    local data=${val[$len/2 - 1]}
    awk '{ print $2 "\t" $3 }' data.txt | awk 'NR <='+"$data"
    fi
    rm data.txt
}

# Total Bytes sent
function totalBytes(){
   echo "Please wait for few seconds to minutes if you used an extension -e"
   printf "\tIP\tBytes\n"
   awk '{if ($10 !="-")print $10, $1}' thttpd.log | sort -rn | awk '{ if (data[$2] eq 0 && $2 eq $2)} {data[$2]=data[$2]+$1} END { for(var in data) { print var, "\t\t", data[var]}}' | sort -nrk 2 > tmp.txt
   if [[ ${params[*]} =~ ${val[$len/2 - 1]} ]] && [ $argcount != 4 ] && [ $argcount != 5 ] && [ $argcount != 3 ]; then 
   awk '{print $1 "\t" $2}' tmp.txt
   elif [ $argcount -eq 3 ] && [[ ${params[*]} =~ ${val[$len/2 - 1]} ]]; then
   awk '{print $2 "\t" $1}' tmp.txt > tmp1.txt
   tmpfile="tmp1.txt"
   blacklist
   awk '{ print $1 "\t" $2,$3 }' fce.txt
   rm fce.txt tmp1.txt
   elif [[ ${val[$len - 2]} =~ ^[0-9]+$ ]]; then
   local data=${val[$len - 2]}
   awk '{ print $1 "\t" $2 }' tmp.txt | awk 'NR <='+"$data"
   elif [[ ${val[$len - 4]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
   awk '{print $2 "\t" $1}' tmp.txt > tmp1.txt
   tmpfile="tmp1.txt"
   data=${val[$len - 4]}
   blacklist
   awk '{ print $1 "\t" $2,$3 }' fce.txt | awk 'NR <='+"$data"
   rm fce.txt tmp1.txt
   elif [[ ${val[$len - 3]} =~ ^[0-9]+$ ]] && [ $argcount -eq 5 ]; then
   awk '{print $2 "\t" $1}' tmp.txt > tmp1.txt
   tmpfile="tmp1.txt"
   data=${val[$len - 3]}
   blacklist
   awk '{ print $1 "\t" $2,$3 }' fce.txt | awk 'NR <='+"$data"
   rm fce.txt tmp1.txt
   else
   local data=${val[$len/2 - 1]}
   awk '{ print $1 "\t" $2 }' tmp.txt | awk 'NR <='+"$data"
   fi
   rm tmp.txt
}

# Switching
function switching(){
   case "$condition" in
        -c) highestRequestsCounting
        ;;
        -2) successfulAttempts 
        ;; 
        -r) commonResultCode
        ;;
        -F) unsuccessfulAttempts 
        ;;
        -t) totalBytes
        ;;
         *) echo "Invalid Operation Authorized" 
        ;;
      esac
}

# Main Driver Code
if [ $argcount -ge 2 ] &&  [ -r $directory"$filename" ] && [[ "${params[*]}" =~ ${val[$len -2]} ]] && ! [[ ${val[$len -2]} =~ ^[0-9]+$ ]]; then
   if ! [[ "${params[*]}" =~ ${val[0]} ]] && [ $argcount != 4 ] || [[ ${val[0]} =~ ^[0-9]+$ ]];  
      then echo "Please specify your command in this specified format: log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
      -n: Limit the number of results to N
      -c: Which IP address makes the most number of connection attempts?
      -2: Which address makes the most number of successful attempts?
      -r: What are the most common results codes and where do they come
      from?
      -F: What are the most common result codes that indicate failure (no
      auth, not found etc) and where do they come from?
      -t: Which IP number get the most bytes sent to them?
      <filename> refers to the logfile.
      "
   else
   # log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename> || log_sum.sh (-c|-2|-r|-F|-t) [-n N] <filename>
      if [ $argcount = 4 ]; then
         case $1 in
            -n)condition=${val[ $len - 2 ]}
                 switching
                 ;;
            *) echo "Please specify your command in this specified format: log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
            -n: Limit the number of results to N
            -c: Which IP address makes the most number of connection attempts?
            -2: Which address makes the most number of successful attempts?
            -r: What are the most common results codes and where do they come
            from?
            -F: What are the most common result codes that indicate failure (no
            auth, not found etc) and where do they come from?
            -t: Which IP number get the most bytes sent to them?
            <filename> refers to the logfile.
            "
         esac
      else
      condition=${val[ $len - 2 ]}
      switching
      fi
   fi
elif [ $argcount -ge 2 ] && [ -r $directory"$filename" ] && [[ ${val[2]} =~ ^[0-9]+$ ]]; then
     if [[ ${optn[*]} =~ ${val[1]} ]] && [[ ${params[*]} =~ ${val[0]} ]] && [ $argcount -eq 4 ]; then
     # log_sum.sh (-c|-2|-r|-F|-t) [-n N] <filename>
     case ${val[$len - 3]} in
         -n) condition=${val[0]}
          switching
         ;;
      *) echo "Please specify your command in this specified format: log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
      -n: Limit the number of results to N
      -c: Which IP address makes the most number of connection attempts?
      -2: Which address makes the most number of successful attempts?
      -r: What are the most common results codes and where do they come
      from?
      -F: What are the most common result codes that indicate failure (no
      auth, not found etc) and where do they come from?
      -t: Which IP number get the most bytes sent to them?
      <filename> refers to the logfile.
      "
      ;;
      esac
     elif [ $argcount -eq 5 ] && [ -r $directory"$filename" ] &&  [[ ${val[2]} =~ ^[0-9]+$ ]] && [[ ${val[1]} = ${optn[0]} ]]; then
     # log_sum.sh (-c|-2|-r|-F|-t) [-n N] [-e] <filename>
         case ${val[$len - 2]} in
         -e) condition=${val[0]}
         switching
         ;;
         *) echo "Please specify your command in this specified format: log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
         -n: Limit the number of results to N
         -c: Which IP address makes the most number of connection attempts?
         -2: Which address makes the most number of successful attempts?
         -r: What are the most common results codes and where do they come
         from?
         -F: What are the most common result codes that indicate failure (no
         auth, not found etc) and where do they come from?
         -t: Which IP number get the most bytes sent to them?
         <filename> refers to the logfile.
         "
    esac
     else
          echo "Please specify your command in this specified format: log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
          -n: Limit the number of results to N
          -c: Which IP address makes the most number of connection attempts?
          -2: Which address makes the most number of successful attempts?
          -r: What are the most common results codes and where do they come
           from?
          -F: What are the most common result codes that indicate failure (no
          auth, not found etc) and where do they come from?
          -t: Which IP number get the most bytes sent to them?
          <filename> refers to the logfile.
          "
     fi
   elif [ $argcount -eq 5 ] && [ -r $directory"$filename" ] &&  [[ ${val[1]}  =~ ^[0-9]+$ ]] && [[ ${val[0]} = ${optn[0]} ]]; then
   # log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
    case ${val[$len - 2]} in
         -e) condition=${val[$len/2]}
         switching
         ;;
         *) echo "Please specify your command in this specified format: log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
         -n: Limit the number of results to N
         -c: Which IP address makes the most number of connection attempts?
         -2: Which address makes the most number of successful attempts?
         -r: What are the most common results codes and where do they come
         from?
         -F: What are the most common result codes that indicate failure (no
         auth, not found etc) and where do they come from?
         -t: Which IP number get the most bytes sent to them?
         <filename> refers to the logfile.
         "
    esac
   elif [ $argcount -eq 3 ] && [ -r $directory"$filename" ]; then
   # log_sum.sh (-c|-2|-r|-F|-t) [-e] <filename>
   # Please wait for the data to be collected as it takes more time for searching and matching with the balcklist file.
    case ${val[$len - 2]} in
         -e) condition=${val[0]}
         echo "Requesting to Search for the Blacklisting on the whole data might take few minutes. Please wait we are processing the data."
         switching
         ;;
         *) echo "Please specify your command in this specified format: log_sum.sh (-c|-2|-r|-F|-t) [-e] <filename>
         -n: Limit the number of results to N
         -c: Which IP address makes the most number of connection attempts?
         -2: Which address makes the most number of successful attempts?
         -r: What are the most common results codes and where do they come
         from?
         -F: What are the most common result codes that indicate failure (no
         auth, not found etc) and where do they come from?
         -t: Which IP number get the most bytes sent to them?
         <filename> refers to the logfile.
         "
    esac
else
echo "Please specify your command in this specified format: log_sum.sh [-n N] (-c|-2|-r|-F|-t) [-e] <filename>
-n: Limit the number of results to N
-c: Which IP address makes the most number of connection attempts?
-2: Which address makes the most number of successful attempts?
-r: What are the most common results codes and where do they come
from?
-F: What are the most common result codes that indicate failure (no
auth, not found etc) and where do they come from?
-t: Which IP number get the most bytes sent to them?
<filename> refers to the logfile.
"
fi
exit 0