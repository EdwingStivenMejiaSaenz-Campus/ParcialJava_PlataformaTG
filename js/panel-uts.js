document.addEventListener('DOMContentLoaded',()=>{
 const nav=document.querySelector('.uts-app'); document.querySelectorAll('[data-toggle-nav]').forEach(b=>b.addEventListener('click',()=>nav?.classList.toggle('nav-open')));
 let url=new URL(location.href);let path=url.pathname;
 document.querySelectorAll('.uts-side nav a').forEach(a=>{if(a.pathname===path&&(a.search===url.search||!a.search))a.classList.add('active');});
 document.querySelectorAll('[data-disable-user]').forEach(b=>b.addEventListener('click',()=>{const d=document.getElementById(b.dataset.disableUser);if(!d)return;const s=d.querySelector('select[name=activo]');if(s)s.value='0';d.showModal();}));
 document.querySelectorAll('[data-modal]').forEach(b=>b.addEventListener('click',()=>{let d=document.getElementById(b.dataset.modal);if(d&&typeof d.showModal==='function')d.showModal();}));
 document.querySelectorAll('[data-close-modal]').forEach(b=>b.addEventListener('click',()=>b.closest('dialog')?.close()));
 document.querySelectorAll('dialog').forEach(d=>d.addEventListener('click',e=>{if(e.target===d)d.close();}));
 document.querySelectorAll('[data-filter-table]').forEach(input=>{let table=document.getElementById(input.dataset.filterTable);if(!table||table.hasAttribute('data-paginate'))return;input.addEventListener('input',()=>{let q=input.value.trim().toLocaleLowerCase('es');table.querySelectorAll('tbody tr').forEach(tr=>tr.hidden=!tr.textContent.toLocaleLowerCase('es').includes(q));});});
 document.querySelectorAll('form[data-confirm-send]').forEach(f=>f.addEventListener('submit',e=>{if(!confirm('¿Estás seguro? No podrás editar la respuesta una vez enviada.'))e.preventDefault();}));
 document.querySelectorAll('[data-phase-form]').forEach(el=>el.addEventListener('change',()=>{let f=el.closest('form');let n=f?.querySelector('[data-estado-confirm]');if(n)n.textContent=el.value==='APROBADO'?'Al aprobar se aplican las validaciones académicas del sistema.':'';}));

 const expedienteCache=new Map();
 document.querySelectorAll('[data-detail]').forEach(a=>a.addEventListener('click',async e=>{
  const dialog=document.getElementById('modal-expediente');if(!dialog||!dialog.showModal)return;
  e.preventDefault();const target=dialog.querySelector('[data-modal-content]');target.textContent='Cargando expediente…';dialog.showModal();
  try{let body=expedienteCache.get(a.href);if(!body){const r=await fetch(a.href,{credentials:'same-origin'});if(!r.ok)throw Error('Error de consulta');body=await r.text();expedienteCache.set(a.href,body);}target.innerHTML=body;}catch{target.textContent='No fue posible cargar los detalles. Comprueba la conexión con Supabase.';}
 }));
 document.querySelectorAll('table[data-paginate]').forEach(t=>{
  const tbody=t.querySelector('tbody'),pagination=document.querySelector('[data-pagination]'),sizer=document.querySelector('[data-page-size]'),filter=document.querySelector('[data-filter-table="'+t.id+'"]'),status=document.getElementById('estadoTabla');
  if(!tbody||!pagination)return;let page=1;
  const render=()=>{let all=Array.from(tbody.rows),q=(filter?.value||'').toLocaleLowerCase('es').trim(),st=status?.value||'';
   let rows=all.filter(row=>row.textContent.toLocaleLowerCase('es').includes(q)&&(!st||(row.dataset.owner||'')===st));let count=Math.max(1,Math.ceil(rows.length/Number(sizer?.value||5)));page=Math.max(1,Math.min(page,count));
   all.forEach(r=>r.hidden=true);rows.slice((page-1)*Number(sizer?.value||5),page*Number(sizer?.value||5)).forEach(r=>r.hidden=false);
   const summary=document.querySelector('[data-table-status]');if(summary)summary.textContent='Mostrando la página '+page+' de '+count+' ('+rows.length+' registros)';
   pagination.replaceChildren();for(const [label,toPage] of [['«',1],['‹',page-1],[String(page),page],['›',page+1],['»',count]]){const b=document.createElement('button');b.type='button';b.textContent=label;b.className=toPage===page?'current':'';b.disabled=toPage===page||toPage<1||toPage>count;b.addEventListener('click',()=>{page=toPage;render();});pagination.append(b);}
  };
  filter?.addEventListener('input',()=>{page=1;render()});status?.addEventListener('change',()=>{page=1;render()});sizer?.addEventListener('change',()=>{page=1;render()});render();
 });
 });