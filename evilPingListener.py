#!/usr/bin/env python3

import socket
import struct

class evilPingListener:
    def __init__(self, srcip, output):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
        self.src_ip = srcip
        self.output = output

    def write_output(self, data):
        with open(self.output, 'wb') as w:
            w.write(data)
            w.flush()
        w.close()

        return True

    def listen(self):
        addr = [None]
        data = b''
        run = True

        print(f"[*] Start listening...")

        while addr[0] != self.src_ip:
            packet, addr = self.sock.recvfrom(1024)

        print(f"[*] Received ICMP packet test from {addr[0]}")

        while run:
            packet, addr = self.sock.recvfrom(1024)

            if addr[0] == self.src_ip:
                icmp_header = packet[20:28]
                icmp_type, icmp_code, icmp_checksum, icmp_id, icmp_seq = struct.unpack("bbHHh", icmp_header)
                icmp_data = packet[28:][16:32]

                if b'ENDOFEVILPING' in icmp_data:
                    run = False
                else:
                    data += icmp_data

                # print(f"Received ICMP packet from {addr}: type={icmp_type}, code={icmp_code}, id={icmp_id}, seq={icmp_seq}, data={icmp_data}")
                print(f"[+] Received data from {addr[0]}: {icmp_data}")

        self.write_output(data)
        return True

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='ICMP listener for Evil Ping by @bayufedra on github')
    parser.add_argument('-o', '--output', default='output.txt', type=str, help='Output file')
    parser.add_argument('-s', '--src-ip', required=True, type=str, help='Source IP of ICMP sender')
    args = parser.parse_args()

    sip = args.src_ip
    out = args.output

    run = evilPingListener(sip, out)
    run.listen()
