#!/usr/bin/python3

import argparse
import os
import subprocess
from pathlib import Path

ROOT = Path(os.path.realpath(__file__)).parent
CONFIG_PATH = ROOT.joinpath("./config/frpc.toml")
APP_NAME = "frpc"
DEAMON_NAME = "frpcd"


def func_config(args):
    try:
        subprocess.run(["sudo", "vim", f"{CONFIG_PATH}"], check=True)
        print(
            f"Configuration updated. Please run '{APP_NAME} restart' to apply the changes."
        )
    except FileNotFoundError:
        print(f"Can not open {CONFIG_PATH}")
    except subprocess.CalledProcessError:
        print("Fail to open config file")


def func_start(args):
    try:
        subprocess.run(["sudo", "systemctl", "start", DEAMON_NAME], check=True)
        print("Clashd start success")
    except subprocess.CalledProcessError:
        print("Fail to start clash daemon")


def func_stop(args):
    try:
        subprocess.run(["sudo", "systemctl", "stop", DEAMON_NAME], check=True)
        print("Clashd stopped")
    except subprocess.CalledProcessError:
        print("Fail to stop clash daemon")


def func_enable(args):
    try:
        subprocess.run(["sudo", "systemctl", "enable", DEAMON_NAME], check=True)
        print("Success")
    except subprocess.CalledProcessError:
        print("Fail")


def func_restart(args):
    try:
        subprocess.run(["sudo", "systemctl", "restart", DEAMON_NAME], check=True)
        print("Success")
    except subprocess.CalledProcessError:
        print("Fail")


def func_status(args):
    try:
        subprocess.run(["sudo", "systemctl", "status", DEAMON_NAME], check=True)
        print("Success")
    except subprocess.CalledProcessError:
        print("Fail")


def main():
    parser = argparse.ArgumentParser(description="frpc tools")
    subparsers = parser.add_subparsers(help="commands")

    # config command
    config_parser = subparsers.add_parser("config", help="open config file")
    config_parser.set_defaults(func=func_config)

    # start command
    start_parser = subparsers.add_parser("start", help="start clash daemon")
    start_parser.set_defaults(func=func_start)

    # stop command
    stop_parser = subparsers.add_parser("stop", help="stop daemon")
    stop_parser.set_defaults(func=func_stop)

    # enable command
    enable_parser = subparsers.add_parser("enable", help="enable  daemon")
    enable_parser.set_defaults(func=func_enable)

    # restart command
    config_parser = subparsers.add_parser("restart", help="restart daemon")
    config_parser.set_defaults(func=func_restart)

    # status command
    status_parser = subparsers.add_parser("status", help="")
    status_parser.set_defaults(func=func_status)

    args = parser.parse_args()
    if hasattr(args, "func"):
        args.func(args)


if __name__ == "__main__":
    main()
