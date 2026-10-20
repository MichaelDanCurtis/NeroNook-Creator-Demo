#!/usr/bin/env python3
"""Export only the SDK, authoring tools and reference docs; never host data/builds."""
import hashlib
import json
from pathlib import Path
import sys
import zipfile
sdk=Path(__file__).resolve().parents[1]
output=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else sdk.parent/'build/NeroNook-Creator-Kit-0.1.0.zip'
files=[]
for directory in ['Creator','NookPluginSDK']:
    files += [p for p in (sdk/directory).rglob('*') if p.is_file() and not p.is_symlink() and not any(x in p.parts for x in ['.build','.swiftpm','__pycache__']) and p.name!='.DS_Store']
files += list(sdk.glob('*.md')) + [sdk/'module.py']
output.parent.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(files):archive.write(path,'NeroNook-Creator-Kit/'+str(path.relative_to(sdk)))
    hashes={str(p.relative_to(sdk)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    archive.writestr('NeroNook-Creator-Kit/KIT-SNAPSHOT.json',json.dumps(dict(version='0.1.0',hostBaseline='0.14.0',files=hashes),indent=2))
print(output)
