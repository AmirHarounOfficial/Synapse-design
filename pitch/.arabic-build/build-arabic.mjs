import fs from 'node:fs/promises';
import path from 'node:path';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import { FileBlob, PresentationFile } from 'file:///C:/Users/amirt/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';
const require = createRequire('C:/Users/amirt/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/package.json');
const JSZip = require('jszip');
const xml = require('xml-js');
const root = 'D:/work/Synapse Health App/pitch';
const build = path.join(root, '.arabic-build');
const source = path.join(root, 'SchooKeep_Pitch_Deck.pptx');
const skill = 'C:/Users/amirt/.codex/plugins/cache/openai-primary-runtime/presentations/26.909.12148/skills/presentations';
process.env.RUNTIME_NODE_MODULES = 'C:/Users/amirt/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const array = v => v === undefined ? [] : Array.isArray(v) ? v : [v];
const arabicDigits = s => s.replace(/[0-9]/g, n => '٠١٢٣٤٥٦٧٨٩'[Number(n)]);

const copy = [
  [
    'الصحة المدرسية المتصلة', 'SchooKeep',
    'منصة مشتركة للصحة المدرسية والتواصل مع الأسرة وسلامة الطلاب',
    'تنسيق أفضل للرعاية\nمسؤوليات أوضح\nمجتمع مدرسي واحد',
    'عرض توضيحي لتطبيق Flutter\nلقطات من التطبيق ببيانات تجريبية محلية',
    'إدارة المدرسة', 'تجربة ولي الأمر',
  ],
  [
    'التحدي', 'فجوات التنسيق في الرعاية',
    'يعالج التطبيق فجوات تبادل المعلومات خلال اليوم الدراسي',
    'معلومات متفرقة',
    'تتوزع ملاحظات العيادة والموافقات وحالة الدواء وتعليمات الاستلام بين إجراءات مختلفة.',
    'قرارات عاجلة',
    'تتطلب الحالات الصحية من الممرضة والأسرة والمعلم والإدارة العمل انطلاقاً من المعلومات نفسها.',
    'رؤية محدودة',
    'تحتاج المدرسة إلى متابعة واضحة للعمليات وسجل يبيّن من اتخذ الإجراء ومتى.',
  ],
  [
    'الحل', 'مساحة عمل موحدة للصحة المدرسية',
    'واجهات جوال مخصصة لكل دور تجمع فرق المدرسة ضمن نموذج عمل واحد',
    'تنسيق الرعاية', 'زيارات العيادة وإعطاء الجرعات ومراجعة الطبيب والسجلات الصحية للطلاب.',
    'التواصل مع الأسرة', 'الموافقات والمستندات والتاريخ الصحي وتقارير الأدوية والمصرح لهم بالاستلام.',
    'متابعة الإجراءات', 'تحليلات الإدارة وصلاحيات الموظفين والتنبيهات المدرسية وسجلات التدقيق.',
  ],
  [
    'نطاق المنتج', 'تجارب تخدم المدرسة بأكملها',
    'إحدى عشرة تجربة حسب الدور، مع تسجيل دخول وحالات تشغيل مشتركة',
    'مدير المدرسة', 'نائب المدير', 'الممرضة', 'الطبيب', 'ولي الأمر', 'المعلم',
    'المرشد الطلابي', 'السكرتارية', 'المقصف', 'الأمن', 'سائق الحافلة',
    'تتضمن مكتبة المنتج ١٤٨ لقطة شاشة مرتبطة بمسارات التطبيق.',
  ],
  [
    'الإدارة المدرسية', 'رؤية شاملة للصحة المدرسية',
    'نظرة يومية تجمع أنشطة الرعاية والمستندات والتنبيهات ومتابعة الموظفين',
    'متابعة العمل اليومي', 'جمع أولويات اليوم في شاشة واحدة للإدارة.',
    'الموظفون والصلاحيات', 'إدارة فرق العمل المسؤولة عن تقديم الخدمة.',
    'التحليلات والتقارير', 'مراجعة الاتجاهات ودعم التخطيط على مستوى المدرسة.',
    'نظرة يومية', 'تحليلات الصحة', 'إدارة الموظفين',
  ],
  [
    'الرعاية الصحية', 'مساحة عمل مخصصة للممرضة',
    'تشمل العمليات البحث عن الطلاب والزيارات والتوثيق وتصعيد الحالات الطارئة',
    'المعلومات الصحية', 'الوصول إلى المعلومات الصحية ضمن سجل الطالب.',
    'توثيق الزيارات', 'تنظيم نشاط العيادة اليومي وتفاصيل الزيارات.',
    'تصعيد الحالات', 'إظهار الخطوات العاجلة التالية ضمن مسار العمل.',
    'زيارات العيادة', 'زيارة جديدة', 'تصعيد حالة طارئة',
  ],
  [
    'إدارة الأدوية', 'متابعة الجرعات ومخزون الأدوية',
    'تعرض الواجهة الجرعات اليومية وحالات التعارض ومخزون الصيدلية',
    'تخطيط الجرعات', 'مراجعة مهام الأدوية في شاشة مخصصة للجرعات.',
    'التأكيد والتنبيه', 'تنظيم الإجراءات عبر شاشات تأكيد الجرعات وتنبيهات التعارض.',
    'متابعة المخزون', 'تخصيص شاشة لمتابعة مخزون الأدوية.',
    'قائمة الأدوية', 'تنبيه التعارض', 'مخزون الصيدلية',
  ],
  [
    'إشراف الطبيب', 'مراجعة طبية تتجاوز العيادة',
    'مساحة عمل للطبيب تدعم مراجعة البروتوكولات والحالات المحالة والمواعيد',
    'مراجعة البروتوكولات', 'قسم مخصص لمراجعة بروتوكولات الأدوية.',
    'الحالات المحالة', 'إبراز الحالات التي تتطلب متابعة طبية إضافية.',
    'تنظيم المواعيد', 'عرض جدول الطبيب ضمن التطبيق.',
    'الرئيسية للطبيب', 'مراجعة البروتوكولات', 'الحالات المحالة',
  ],
  [
    'تجربة الأسرة', 'الأسرة ضمن مسار الرعاية',
    'يجمع تطبيق ولي الأمر الصحة والأدوية والمستندات في تجربة جوال مألوفة',
    'الرئيسية للأسرة', 'نقطة بداية واضحة لولي الأمر خلال اليوم الدراسي.',
    'السجل الصحي والدوائي', 'إبقاء الأسرة على اطلاع بأنشطة رعاية الطفل.',
    'المستندات في مكان واحد', 'الوصول بسهولة إلى مستندات الصحة المدرسية.',
    'الرئيسية لولي الأمر', 'السجل الصحي', 'المستندات',
  ],
  [
    'الموافقات والاستلام', 'ربط الطلب باستجابة ولي الأمر',
    'تربط شاشات الموافقة والاستلام المصرح به بين إجراءات المدرسة وولي الأمر',
    'الاستجابة للطوارئ', 'شاشة مخصصة لموافقة ولي الأمر في الحالات الطارئة.',
    'المصرح لهم بالاستلام', 'تنظيم قائمة الأشخاص المصرح لهم باستلام الطالب.',
    'رمز الاستلام', 'عرض هوية الاستلام القابلة للمسح في تطبيق الأسرة.',
    'الرد على طلب الموافقة', 'المصرح لهم بالاستلام', 'رمز الاستلام',
  ],
  [
    'المتابعة الصفية', 'المعلومات الصحية خلال اليوم الدراسي',
    'واجهات للمعلم تركز على الحضور والاعتبارات الصحية والإحالات والإعفاءات',
    'متابعة الحضور', 'عرض صفي يدعم متابعة العمل اليومي.',
    'الاعتبارات الصحية', 'إظهار احتياجات الطلاب ذات الصلة للمعلم.',
    'الإحالة إلى العيادة', 'مسار واضح لإحالة الطالب إلى العيادة المدرسية.',
    'الحضور', 'الاعتبارات الصحية', 'الإحالة إلى العيادة',
  ],
  [
    'سلامة الطلاب', 'تنسيق الوصول والمغادرة',
    'واجهات تشغيل مخصصة لفرق الأمن والنقل',
    'التحقق عند الاستلام', 'تنظيم عمل البوابة عبر قائمة الاستلام والتحقق اليدوي.',
    'عمليات النقل', 'مسارات الحافلة والصعود وسجل الرحلات لدعم السائق.',
    'مسؤولية مشتركة', 'ربط المدرسة وموظفي النقل وأولياء الأمور المصرح لهم.',
    'قائمة الاستلام', 'التحقق اليدوي', 'مسار الحافلة',
  ],
  [
    'سلامة الغذاء', 'معلومات أوضح لقرارات المقصف',
    'توسّع تنبيهات الحساسية ونقاط البيع نطاق المنتج خارج العيادة',
    'تنبيهات الحساسية', 'شاشات تنبيه مخصصة للعاملين في المقصف.',
    'العمليات اليومية', 'إتاحة نقطة البيع ضمن تجربة الموظف.',
    'ميزانية الأسرة', 'عرض ميزانية المقصف في تطبيق ولي الأمر.',
    'تنبيهات المقصف', 'نقطة البيع', 'ميزانية الأسرة',
  ],
  [
    'الدعم المدرسي', 'دعم فرق التنسيق والمتابعة',
    'توسّع شاشات المرشد والسكرتارية نطاق العمل المدرسي',
    'دعم الطلاب', 'سجلات المرشد وتقاريره لمتابعة الرعاية المستمرة.',
    'تنسيق المكتب', 'واجهات للسكرتارية تشمل الطلاب والرسائل واستيراد البيانات.',
    'الفرز والمتابعة', 'قوائم انتظار توضح المهام التي تحتاج إلى متابعة.',
    'لوحة المرشد', 'رسائل المكتب', 'طلبات المساعد الآلي',
  ],
  [
    'الحوكمة', 'وضوح الصلاحيات والجاهزية',
    'تدعم واجهات الصلاحيات والتدقيق والجاهزية وضوح المسؤوليات',
    'صلاحيات الأدوار', 'عرض نموذج الوصول في مصفوفة مخصصة.',
    'سجل التدقيق', 'متابعة أنشطة النظام المسجلة.',
    'جاهزية العيادة', 'متابعة جاهزية العيادة ومعداتها ضمن العمليات المدرسية.',
    'الصلاحيات', 'سجل التدقيق', 'جاهزية العيادة',
  ],
  [
    'التصميم للسوق المحلي', 'تصميم يراعي البيئة المدرسية',
    'يدعم التطبيق العربية والإنجليزية وحالات تشغيل تناسب سياق المدرسة',
    'دعم اللغتين', 'نصوص عربية وإنجليزية وتخطيطات من اليمين إلى اليسار في التطبيق.',
    'تنبيهات المدرسة', 'تعرض شاشات الطقس القيود المشتركة على الأنشطة.',
    'أوضاع التشغيل', 'تشمل التجربة وضع رمضان وحالة خارج أوقات الدوام.',
    'تنبيه الطقس', 'وضع رمضان', 'خارج أوقات الدوام',
  ],
  [
    'فرضية النموذج التجاري', 'اشتراك على مستوى المدرسة',
    'نموذج مقترح للتحقق في التجارب، دون أسعار نهائية معتمدة',
    'ترخيص المدرسة', 'اشتراك سنوي حسب حجم المدرسة أو عدد الطلاب. تختبر التجارب استعداد المدارس للدفع.',
    'التنفيذ', 'خدمات الإعداد والتدريب ودعم الإطلاق، مع تحديد نطاق التكاملات بصورة مستقلة.',
    'التوسع ضمن المجموعة', 'التوسع من مدرسة إلى مجموعة مدارس بعد إثبات الاستخدام والقيمة التشغيلية.',
  ],
  [
    'مقترح التجربة', 'تجربة التشغيل قبل التوسع',
    'تجربة مقترحة لمدة ثمانية أسابيع بمقاييس ومسؤوليات متفق عليها',
    'الأسبوعان ١ و٢\nالتهيئة', 'توثيق الإجراءات الحالية وتأكيد الأدوار ومراجعة التعامل مع البيانات وتحديد خط أساس.',
    'الأسابيع ٣ إلى ٦\nالتشغيل', 'تجربة العيادة والموافقات والتواصل مع الأسرة ضمن مجموعة محددة وخطة دعم منتظمة.',
    'الأسبوعان ٧ و٨\nالتقييم', 'قياس الاستخدام واكتمال التوثيق وزمن الاستجابة للموافقات وإتمام إجراءات التنسيق.',
  ],
  [
    'الخطوة التالية', 'المدرسة المناسبة للتجربة',
    'التحقق من القيمة مع الأشخاص الذين سيستخدمون النظام يومياً',
    'البحث عن شريك للتطوير',
    'فريق إدارة مدرسية وممرضة ومجموعة من أولياء الأمور يشاركون في تصميم الإطلاق وتحديد النجاح.',
    'الاتفاق على نطاق التجربة\nتعيين مسؤول للتشغيل\nاختيار المقاييس المناسبة',
  ],
  [
    'الأدلة ونطاق العرض', 'ما يوضحه هذا العرض',
    'توثق اللقطات تجربة التطبيق الحالية، ولا تثبت نتائج تجارية أو سريرية',
    'طريقة التقاط الشاشات',
    'نسخة الويب من Flutter بإعدادات الإصدار، وعرض جوال بعرض ٣٩٣ وارتفاع ٨٥٢ بكسل. خادم Laravel محلي ببيانات تجريبية وحساب الإدارة المقدم. أيقونات أصلية وخط Arial بديل للخطوط المحمّلة عبر الشبكة.',
    'حدود العرض',
    'تعرض الشاشات بيانات تجريبية، وتستخدم بعض المسارات معرّفات أو حالات ثابتة. لم تُختبر الخرائط والخدمات الخارجية. لا يثبت العرض تشغيل الإنتاج أو النتائج السريرية أو شهادات الأمان أو الانتشار التجاري أو الأسعار أو التكاملات.',
    'المرفقات: مكتبة لقطات مفهرسة حسب المسار، ومعرض في المتصفح، وعرض PowerPoint قابل للتحرير.',
  ],
];

const zip = await JSZip.loadAsync(await fs.readFile(source));
const doc = xml.xml2js(await zip.file('ppt/presentation.xml').async('string'), {compact:true});
const size = doc['p:presentation']['p:sldSz']._attributes;
const width = Number(size.cx) / 9525;
const p = await PresentationFile.importPptx(await FileBlob.load(source));
if (p.slides.items.length !== copy.length) throw new Error('Unexpected source slide count');
for (let i=0;i<p.slides.items.length;i++) {
  const slide = p.slides.items[i];
  const slideXml = xml.xml2js(await zip.file(`ppt/slides/slide${i+1}.xml`).async('string'), {compact:true});
  const metadata = new Map(array(slideXml['p:sld']['p:cSld']['p:spTree']['p:sp']).map(s => [s['p:nvSpPr']['p:cNvPr']._attributes.id, s]));
  let index = 0;
  for (const sh of slide.shapes.items) {
    const old = sh.text.toString();
    const pos = sh.position;
    sh.position = {...pos, left:width-pos.left-pos.width};
    if (!old) continue;
    let translated;
    if (old.startsWith('SchooKeep  |')) translated = 'SchooKeep     عرض المنتج     ٥ أكتوبر ٢٠٢٦';
    else if (/^\d+$/.test(old)) translated = arabicDigits(old);
    else translated = copy[i][index++];
    if (translated === undefined) throw new Error(`Missing translation ${i+1}: ${old}`);
    const original = metadata.get(sh.id);
    const paragraph = array(original['p:txBody']['a:p'])[0];
    const props = paragraph['a:pPr']?.['a:defRPr'] ?? array(paragraph['a:r'])[0]?.['a:rPr'];
    const font = props?._attributes ?? {};
    sh.text = translated.split('\n').map(t => ({runs:[t], spaceAfter:i===17 && translated.includes('\n') ? 0 : 1000}));
    sh.text.style = {
      typeface:'Arial', fontSize:Number(font.sz ?? 2000)/100*4/3,
      bold:font.b==='1', color:'#'+(props?.['a:solidFill']?.['a:srgbClr']?._attributes.val ?? '142822'),
      alignment:'right', verticalAlignment:'top', autoFit:'none', wrap:'square',
      insets:{left:0,right:0,top:0,bottom:0},
    };
  }
  if (index !== copy[i].length) throw new Error(`Unused translations on slide ${i+1}: ${index}/${copy[i].length}`);
  for (const image of slide.images.items) {
    const frame = image.frame;
    image.frame = {...frame, left:width-frame.left-frame.width};
  }
  slide.speakerNotes.textFrame.setText('نسخة عربية من العرض الأصلي، مع تخطيط من اليمين إلى اليسار. لقطات الواجهة محفوظة كما ظهرت في النسخة الأصلية. توثق اللقطات نسخة Flutter مع خادم Laravel محلي وبيانات تجريبية وحساب الإدارة المقدم. لا يثبت العرض نتائج تجارية أو سريرية.');
}
await fs.mkdir(build,{recursive:true});
const exported = path.join(build,'arabic-export.pptx');
await (await PresentationFile.exportPptx(p)).save(exported);

// Native PowerPoint bidi properties are not exposed by the text-style facade.
const resultZip = await JSZip.loadAsync(await fs.readFile(exported));
let rtlParagraphs = 0;
for (const name of Object.keys(resultZip.files).filter(n => /^ppt\/(slides\/slide|notesSlides\/notesSlide)\d+\.xml$/.test(n))) {
  const tree = xml.xml2js(await resultZip.file(name).async('string'), {compact:true});
  const walk = node => {
    if (!node || typeof node !== 'object') return;
    for (const [key, value] of Object.entries(node)) {
      if (key === 'a:p') for (const paragraph of array(value)) {
        const text = array(paragraph['a:r']).map(r=>r['a:t']?._text ?? '').join('');
        if (!text) continue;
        paragraph['a:pPr'] ??= {};
        paragraph['a:pPr']._attributes = {...paragraph['a:pPr']._attributes, rtl:'1', algn:'r'};
        for (const r of array(paragraph['a:r'])) {
          r['a:rPr'] ??= {};
          r['a:rPr']._attributes = {...r['a:rPr']._attributes, lang:'ar-AE', altLang:'en-US'};
          r['a:rPr']['a:cs'] = {_attributes:{typeface:'Arial'}};
        }
        rtlParagraphs++;
      }
      if (key !== '_attributes') for (const child of array(value)) walk(child);
    }
  };
  walk(tree);
  resultZip.file(name,xml.js2xml(tree,{compact:true}));
}
const candidatePath = path.join(build,'candidate.pptx');
await fs.writeFile(candidatePath,await resultZip.generateAsync({type:'nodebuffer',compression:'DEFLATE'}));
const {finalizePresentation} = await import(pathToFileURL(path.join(skill,'container_tools/artifact_tool_utils.mjs')).href);
const finalPath = path.join(root,'arabic','SchooKeep_Pitch_Deck_Arabic_RTL_v2.pptx');
await fs.mkdir(path.dirname(finalPath),{recursive:true});
const result = await finalizePresentation({
  workspaceDir:root,candidatePath,finalPath,
  pythonExecutable:'C:/Users/amirt/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe',
  integrityValidatorPath:path.join(skill,'container_tools/inspect_presentation_package_integrity.py'),
  layoutValidatorPath:path.join(skill,'container_tools/inspect_presentation_layout_geometry.py'),
  layoutArgs:['--expected-slide-size-emu',`${size.cx},${size.cy}`,'--validate-bullet-geometry','--validate-heading-fit'],
  explicitTotalSlideCount:20,
  fontPolicy:{basis:'design',families:['Arial']},
  verifyArtifactToolImport:true,
  receiptPath:path.join(build,'validation-v2.json'),
});
console.log(JSON.stringify({finalPath,rtlParagraphs,result}));
