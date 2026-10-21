#!/usr/bin/env python3
"""Verify observed vs desired singletons for the SlickLab control plane.

Each service in the inventory declares ONE check type, because the fleet is a
mix of Docker containers and port-bound host processes that a single `ps` scan
cannot see uniformly:

  check: {container: <name>}   running container with that exact name (0/1)
  check: {port: <n>}           a LISTEN socket exists on that TCP port (0/1)
  check: {process: <pattern>}  distinct PIDs whose cmdline contains <pattern>

Read-only. Exit non-zero if any service's observed count != desired_replicas.
"""
import argparse, subprocess, sys, yaml


def sh(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def running_containers():
    return set(sh(['docker', 'ps', '--format', '{{.Names}}']).split())


def listening_ports():
    ports = set()
    for line in sh(['ss', '-lntnH']).splitlines():
        parts = line.split()
        if len(parts) >= 4:
            local = parts[3]                # e.g. 127.0.0.1:8100 or [::]:443
            port = local.rsplit(':', 1)[-1]
            if port.isdigit():
                ports.add(int(port))
    return ports


def process_pids(pattern):
    pids = set()
    for line in sh(['ps', '-eo', 'pid=,args=']).splitlines():
        line = line.strip()
        if not line or 'service_replicas.py' in line:
            continue
        pid, _, args = line.partition(' ')
        if pattern in args:
            pids.add(pid)
    return len(pids)


def observe(check, containers, ports):
    if 'container' in check:
        return 1 if check['container'] in containers else 0
    if 'port' in check:
        return 1 if int(check['port']) in ports else 0
    if 'process' in check:
        return process_pids(str(check['process']))
    raise SystemExit(f"service has no valid check: {check!r}")


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--inventory', required=True)
    a = p.parse_args()
    with open(a.inventory, encoding='utf-8') as f:
        inv = yaml.safe_load(f)['services']
    containers, ports = running_containers(), listening_ports()
    failed = 0
    for name, cfg in inv.items():
        desired = int(cfg['desired_replicas'])
        check = cfg.get('check', {'process': name})
        observed = observe(check, containers, ports)
        ok = observed == desired
        crit = ' CRITICAL' if cfg.get('critical') else ''
        print(f"{'PASS' if ok else 'FAIL'} {name} desired={desired} observed={observed} via={check}{crit if not ok else ''}")
        failed += 0 if ok else 1
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
