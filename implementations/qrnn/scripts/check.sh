#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
lake build Qrnn Qrnn.Smoke Qrnn.BPTTAudit Qrnn.InitializationAudit > goal-1/build.log 2>&1
cat goal-1/build.log
lake env lean Qrnn/AxiomAudit.lean > goal-1/axioms.txt
python3 - <<'PY_CHECK'
from pathlib import Path
import hashlib
import json
import re
import subprocess

sources = [Path("Qrnn.lean"), *sorted(Path("Qrnn").glob("*.lean"))]
for source in sources:
    text = source.read_text()
    assert not re.search(r"\b(sorry|admit|sorryAx|native_decide)\b|^\s*(axiom|unsafe)\b", text, re.M), source
    assert not re.search(r"^import Mathlib$|set_option.*(maxHeartbeats|maxRecDepth)", text, re.M), source
    if source.name != "Qrnn.lean":
        assert not re.search(r"^import Qrnn$", text, re.M), source
public = Path("Qrnn.lean").read_text()
assert not any(name in public for name in ("AxiomAudit", "BPTTAudit", "InitializationAudit", "Smoke"))
assert "import Qrnn." not in Path("Qrnn/BPTT.lean").read_text()
assert Path("Qrnn/Forward.lean").read_text().startswith("import Qrnn.ActivationCore\n")
expected = re.findall(r"^#print axioms (\S+)$", Path("Qrnn/AxiomAudit.lean").read_text(), re.M)
reported = re.findall(r"^'([^']+)' depends on axioms: \[([^\]]*)\]$",
                      Path("goal-1/axioms.txt").read_text(), re.M)
assert len(reported) == len(expected) and {name for name, _ in reported} == set(expected)
allowed = {"propext", "Classical.choice", "Quot.sound"}
for name, axioms in reported:
    assert {item.strip() for item in axioms.split(",") if item.strip()} <= allowed, (name, axioms)
assert Path("lean-toolchain").read_text().strip() == "leanprover/lean4:v4.32.0"
manifest = json.loads(Path("lake-manifest.json").read_text())
mathlib = next(package for package in manifest["packages"] if package["name"] == "mathlib")
assert mathlib["rev"] == "81a5d257c8e410db227a6665ed08f64fea08e997"
assert mathlib["inputRev"] == "v4.32.0"
assert hashlib.sha256(Path("Quaternion_Recurrent_Neural_Networks.md").read_bytes()).hexdigest() ==     "a70b427cf99dad35a370b42e0a1fe47223ba89b979d12f9e6c3bd6c67c396717"
version = subprocess.check_output(["lake", "env", "lean", "--version"], text=True).strip()
assert "4.32.0" in version
print(f"Validated {len(sources)} source modules and {len(reported)} main-result axiom reports.")
print(version)
print("Pins, preserved paper, proof-hole scans and import boundaries passed.")
PY_CHECK
git diff --check -- .
