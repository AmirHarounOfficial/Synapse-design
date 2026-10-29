const { chromium } = require('C:/Users/amirt/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname,'../flutter_app/build/web');
const out = path.join(__dirname,'screenshots');
fs.mkdirSync(out,{recursive:true});
const source=fs.readFileSync(path.resolve(__dirname,'../flutter_app/lib/features/dev/navigation_map_screen.dart'),'utf8');
const routes=[...source.matchAll(/labelEn: '([^']+)'.*?route: '([^']+)'/g)].map(m=>({label:m[1],route:m[2],name:m[2].replace(/^\//,'').replace(/[^a-z0-9-]/gi,'-')}));
for(const [label,route] of [['Weather advisory state','/system/weather-advisory'],['Ramadan mode','/system/ramadan'],['After-hours lock','/system/after-hours']]){
 if(!routes.some(r=>r.route===route))routes.push({label,route,name:route.slice(1).replaceAll('/','-')});
}
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 const context=await browser.newContext({viewport:{width:393,height:852},deviceScaleFactor:2});
 await context.route('**/*',async r=>{
   const url=new URL(r.request().url());
   if(url.hostname==='127.0.0.1')return r.continue();
   if(url.hostname==='api.schookeep.com'){
    const response=await r.fetch({url:'http://127.0.0.1:8006'+url.pathname+url.search});
    return r.fulfill({response});
   }
   if(url.hostname==='www.gstatic.com'&&url.pathname.includes('flutter-canvaskit')){
    const relative=url.pathname.split('/').slice(3).join('/');
    return r.fulfill({body:fs.readFileSync(path.join(root,'canvaskit',relative)),contentType:relative.endsWith('.wasm')?'application/wasm':'application/javascript'});
   }
   if(url.hostname==='fonts.gstatic.com')return r.fulfill({body:fs.readFileSync('C:/Windows/Fonts/arial.ttf'),contentType:'font/ttf'});
   return r.abort();
 });
 const page=await context.newPage();
 if(process.env.PITCH_EMAIL){
  await page.goto('http://127.0.0.1:5184/#/login');
  await page.waitForTimeout(3000);
  await page.mouse.click(150,370);
  await page.keyboard.type(process.env.PITCH_EMAIL);
  await page.mouse.click(150,435);
  await page.keyboard.type(process.env.PITCH_PASSWORD);
  await page.mouse.click(180,540);
  await page.waitForTimeout(3000);
  console.log('Login destination: '+page.url());
 }
 const results=[];
 const deckSource=fs.readFileSync(path.join(__dirname,'build_deck.py'),'utf8');
 const settleNames=['parent-app-home','physician-dashboard','physician-protocols','nurse-clinic','nurse-medications-inventory','parent-app-cafeteria-budget','security-pickups','security-manual-verification','bus-route','counselor-home','secretary-chatbot'];
 const selected=process.argv.includes('--settle')?routes.filter(r=>settleNames.includes(r.name)):process.argv.includes('--extra')?routes.filter(r=>r.route.startsWith('/system/')||r.route.includes('full-qrcode')):process.argv.includes('--deck')?routes.filter(r=>deckSource.includes("'"+r.name+"'")):routes;
 for(const item of selected){
  try{
   const captureRoute=item.route.replace(/\/(?:med|stu|staff|doc|visit|proto|report|thread|tag|person)-1$/,'/1');
   await page.goto('http://127.0.0.1:5184/#'+captureRoute);
   await page.waitForTimeout(process.argv.includes('--settle')?12000:process.argv.includes('--deck')||process.argv.includes('--extra')?3500:1000);
   await page.waitForLoadState('networkidle',{timeout:20000}).catch(()=>{});
   await page.waitForTimeout(600);
   await page.screenshot({path:path.join(out,item.name+'.png')});
   results.push({...item,file:item.name+'.png'});
   if(results.length%20===0)console.log('Captured '+results.length+' screens');
  }catch(e){results.push({...item,error:e.message.slice(0,150)});}
 }
 if(process.argv.includes('--deck')||process.argv.includes('--extra')||process.argv.includes('--settle')){
  const manifest=JSON.parse(fs.readFileSync(path.join(__dirname,'screenshots.json'),'utf8'));
  for(const entry of results){if(!manifest.some(r=>r.name===entry.name))manifest.push(entry);}
  fs.writeFileSync(path.join(__dirname,'screenshots.json'),JSON.stringify(manifest,null,2));
 }else fs.writeFileSync(path.join(__dirname,'screenshots.json'),JSON.stringify(results,null,2));
 console.log('Complete: '+results.filter(r=>r.file).length+' screenshots. Local seeded backend; Arial font fallback.');
 await browser.close();
})();
