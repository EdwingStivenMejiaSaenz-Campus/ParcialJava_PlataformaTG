/* Carga fragmentada a Supabase a través de JSP/JSTL, sin servlet propio ni código Java. */
(function(){'use strict';
const bytesPerChunk=48*1024;
const fileBytes=ab=>{let binary='';const data=new Uint8Array(ab);for(let i=0;i<data.length;i++)binary+=String.fromCharCode(data[i]);return btoa(binary)};
const message=(node,s)=>{node.textContent=s;};
document.querySelectorAll('[data-upload-uts]').forEach(form=>{
form.addEventListener('submit',async ev=>{
ev.preventDefault();const file=form.querySelector('input[type=file]').files[0],info=form.querySelector('[data-estado]'),button=form.querySelector('button[type=submit]');
if(!file){message(info,'Selecciona un archivo.');return;}
if(!file.size||file.size>20*1024*1024){message(info,'Tamaño permitido: desde 1 byte hasta 20 MB.');return;}
if(!self.crypto||!crypto.randomUUID){message(info,'La carga exige un navegador moderno y conexión segura.');return;}
const token=crypto.randomUUID(),partes=Math.ceil(file.size/bytesPerChunk);button.disabled=true;
const send=async(payload)=>{let body=new URLSearchParams({csrf:form.elements.csrf.value,token,...payload});const r=await fetch(form.dataset.destino,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body});const response=(await r.text()).trim();if(!r.ok||response!=='OK')throw new Error('El servidor rechazó la operación: '+response.slice(0,100));};
try{message(info,'Preparando archivo...');await send({accion:'iniciar',proyecto_id:form.elements.proyecto_id.value,tipo:form.elements.tipo.value,nombre:file.name.slice(0,180),mime:file.type||'application/octet-stream',tamano:String(file.size),partes:String(partes)});
for(let n=0;n<partes;n++){const buf=await file.slice(n*bytesPerChunk,(n+1)*bytesPerChunk).arrayBuffer();await send({accion:'parte',numero:String(n),fragmento:fileBytes(buf)});message(info,`Cargando: ${Math.floor((n+1)/partes*100)} %`);}
await send({accion:'finalizar'});message(info,'Archivo guardado correctamente.');location.reload();
}catch(e){message(info,e.message);}finally{button.disabled=false;}
});
});
})();
