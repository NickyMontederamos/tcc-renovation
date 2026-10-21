#!/usr/bin/env python3
import argparse, subprocess, sys, yaml
p=argparse.ArgumentParser()
p.add_argument('--inventory', required=True)
a=p.parse_args()
with open(a.inventory, encoding='utf-8') as f: inv=yaml.safe_load(f)['services']
ps=subprocess.run(['ps','-eo','args='],capture_output=True,text=True,check=True).stdout
failed=0
for name,cfg in inv.items():
    desired=int(cfg['desired_replicas'])
    observed=sum(1 for line in ps.splitlines() if name in line and 'service_replicas.py' not in line)
    ok=observed==desired
    print(f"{'PASS' if ok else 'FAIL'} {name} desired={desired} observed={observed}")
    failed += 0 if ok else 1
sys.exit(1 if failed else 0)
