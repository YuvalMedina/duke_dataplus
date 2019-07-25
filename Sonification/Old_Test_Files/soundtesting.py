import argparse
import random
from pythonosc import osc_message_builder
from pythonosc import udp_client
import socket
import time


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    for x in range(1):
        client.send_message("/print", 500)
        time.sleep(1)
