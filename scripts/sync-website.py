"""Copy the browser distribution into an existing MPFWebsite checkout."""
from pathlib import Path
import shutil, sys, zipfile
source=Path(__file__).resolve().parents[1]
site=Path(sys.argv[1]).resolve()
if not (site/'works/digital-natives/index.html').is_file():
    raise SystemExit('Expected an MPFWebsite checkout with the existing Digital Natives page.')
target=site/'works/digital-natives/tools'
target.mkdir(exist_ok=True)
for name in ['src','vendor','assets','docs']:
    shutil.copytree(source/name,target/name,dirs_exist_ok=True)
for name in ['index.html','style.css','LICENSE']:
    shutil.copy2(source/name,target/name)
html=(target/'index.html').read_text()
html=html.replace('class="wordmark" href="./"','class="wordmark" href="../"')
html=html.replace('<footer>','<footer><a href="../">About Digital Natives</a> · <a href="about.html">Source &amp; licences</a> · ')
(target/'index.html').write_text(html)
shutil.copy2(source/'website-about.html',target/'about.html')
downloads=target/'downloads';downloads.mkdir(exist_ok=True)
with zipfile.ZipFile(downloads/'digital-natives-source.zip','w',zipfile.ZIP_DEFLATED) as archive:
    roots=['src','vendor','assets','docs','tests','scripts','archive/processing']
    files=[source/name for name in ['README.md','LICENSE','package.json','server.js','index.html','style.css','Start Digital Natives.command','website-about.html','.gitignore']]
    for name in roots:
        files.extend(p for p in (source/name).rglob('*') if p.is_file() and p.name not in ['HEC_FromObjFile.pde','.DS_Store'])
    for p in sorted(set(files)):
        archive.write(p,Path('digital-natives')/p.relative_to(source))
print('Website tools and source download updated:',target)
