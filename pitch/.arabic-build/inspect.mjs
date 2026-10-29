import fs from 'node:fs/promises';
import { FileBlob, PresentationFile } from 'file:///C:/Users/amirt/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';
const source = 'D:/work/Synapse Health App/pitch/SchooKeep_Pitch_Deck.pptx';
const p = await PresentationFile.importPptx(await FileBlob.load(source));
const snapshot = await p.inspect({kind:'slide,textbox,shape,image', maxChars:150000});
await fs.writeFile('D:/work/Synapse Health App/pitch/.arabic-build/source.ndjson', snapshot.ndjson);
const list = p.slides.items.map((s,i) => ({slide:i+1, shapes:s.shapes.items.map(sh => ({id:sh.id, text:sh.text.toString(), position:sh.position, style:sh.text.style})), images:s.images.items.map(im=>({id:im.id,frame:im.frame}))}));
await fs.writeFile('D:/work/Synapse Health App/pitch/.arabic-build/source.json', JSON.stringify(list,null,2));
console.log('Imported slides:',p.slides.items.length);
