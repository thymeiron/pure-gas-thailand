import type { Metadata } from 'next';
import 'leaflet/dist/leaflet.css';
import './globals.css';
export const metadata: Metadata = {
  title: 'PURE GAS Thailand | แผนที่เบนซิน 95 แท้',
  description: 'แผนที่ชุมชนค้นหาปั๊มเบนซิน 95 ไม่มีเอทานอลทั่วประเทศไทย พร้อมรายงานและยืนยันจากผู้ใช้',
};
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="th"><body>{children}</body></html>;
}
