#!/usr/bin/env python3
import argparse, ssl, sys, time, urllib.request, urllib.error, yaml
p=argparse.ArgumentParser()
p.add_argument('--inventory', required=True)
p.add_argument('--timeout', type=float, default=10)
a=p.parse_args()
with open(a.inventory, encoding='utf-8') as f: data=yaml.safe_load(f)
failed=0
ctx=ssl.create_default_context()
for e in data.get('endpoints',[]):
    start=time.time()
    try:
        req=urllib.request.Request(e['url'], method='GET', headers={'User-Agent':'tcc-acceptance/1.0'})
        with urllib.request.urlopen(req, timeout=a.timeout, context=ctx) as r:
            status=r.status; final=r.geturl()
    except urllib.error.HTTPError as ex:
        status=ex.code; final=ex.geturl()
    except Exception as ex:
        print(f"FAIL {e['name']} error={type(ex).__name__}")
        failed+=1; continue
    elapsed=time.time()-start
    ok=status==int(e['expected_status'])
    print(f"{'PASS' if ok else 'FAIL'} {e['name']} status={status} expected={e['expected_status']} final={final} seconds={elapsed:.3f}")
    failed += 0 if ok else 1
sys.exit(1 if failed else 0)
