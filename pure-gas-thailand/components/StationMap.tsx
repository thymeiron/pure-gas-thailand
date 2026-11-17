'use client';
import { MapContainer, TileLayer, CircleMarker, Popup, useMap } from 'react-leaflet';
import { useEffect } from 'react';
import type { Station } from '@/lib/supabase';
function Fly({center}:{center: [number,number]}) { const map = useMap(); useEffect(()=>{map.flyTo(center, Math.max(map.getZoom(), 11), {duration:0.8});},[center, map]); return null; }
export default function StationMap({stations,selected,position,onChoose}:{stations:Station[];selected:Station|null;position:[number,number]|null;onChoose:(s:Station)=>void}) {
  return <MapContainer center={[13.7563,100.5018]} zoom={7} scrollWheelZoom style={{height:'100%',width:'100%'}}>
    <TileLayer attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
    {selected && <Fly center={[selected.latitude,selected.longitude]}/>}
    {position && <><Fly center={position}/><CircleMarker center={position} radius={8} pathOptions={{color:'#2563eb',weight:3,fillColor:'#93c5fd',fillOpacity:0.9}}><Popup>ตำแหน่งของคุณ</Popup></CircleMarker></>}
    {stations.map(s=><CircleMarker key={s.id} center={[s.latitude,s.longitude]} radius={11} pathOptions={{color:'#fefefe',weight:3,fillColor:s.last_verified_at?'#328d58':'#e3a84b',fillOpacity:1}} eventHandlers={{click:()=>onChoose(s)}}><Popup><strong>{s.name}</strong><br/>{s.address||s.province||'ประเทศไทย'}<br/>เบนซิน 95 แท้ — {s.last_verified_at?'เคยยืนยันแล้ว':'รอตรวจสอบล่าสุด'}</Popup></CircleMarker>)}
  </MapContainer>;
}
