"""Verify public downloads and automated builds respect supported platforms."""
from pathlib import Path
import json
import re
import subprocess

for filename in ['docs/index.html', 'docs/support.html', 'README.md', 'README_zh.md']:
    text = Path(filename).read_text()
    assert 'apps.apple.com' not in text, filename
    assert not re.search(r'https?://[^\s"<>)]*\.(?:dmg|ipa)', text), filename
html = Path('docs/index.html').read_text()
metadata = json.loads(re.search(r'<script type="application/ld\+json">(.*?)</script>', html, re.S)[1])
assert metadata['operatingSystem'] == 'Windows, Linux, Android'
assert 'releases/download/mobile-android-v1.0.10/MD-Preview-Android.apk' in html
for filename in ['.github/workflows/ci.yml', '.github/workflows/release.yml']:
    text = Path(filename).read_text()
    assert 'build-macos' not in text and 'apple-darwin' not in text, filename
    assert 'build-windows:' in text and 'build-linux:' in text, filename
for filename in ['bundle.sh', 'release-sign.sh', 'scripts/generate-appcast.sh']:
    result = subprocess.run(['bash', filename], capture_output=True, text=True)
    assert result.returncode == 1 and 'suspended' in result.stderr, filename
for filename in ['mobile/scripts/build-release.sh', 'mobile/scripts/verify-release-readiness.sh', 'scripts/verify.sh']:
    assert 'xcodebuild' not in Path(filename).read_text(), filename
assert 'nohup' not in Path('hooks/pre-push').read_text()
print('PASS: public downloads, Windows/Linux workflow, Apple entrypoint blocking, Android-only mobile release')
