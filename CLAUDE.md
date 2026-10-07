# บริบทสำหรับ Claude Code

- โปรเจกต์: เว็บส่วนตัวสำหรับเรียน DA ของ Om (ภาษาไทย) เผยแพร่ด้วย GitHub Pages ที่ https://okodomoo1125.github.io/da-map/
- โครงสร้าง: ไฟล์เดียว `index.html` (HTML + CSS + JS ฝังทั้งหมด รวมไลบรารี Supabase และตัวแปลง `window.claude` → Supabase)
- ข้อมูล: Supabase project `tppcsgnpbjyzmhhhafpi` ตาราง `public.docs (user_id, id, data jsonb, updated_at)` มี RLS เจ้าของเท่านั้น · รูปอยู่ใน bucket `assets` โฟลเดอร์ตาม user id
- กุญแจในไฟล์เป็น publishable key (เปิดเผยได้) ห้ามใส่ service role key หรือรหัสผ่านใด ๆ ลงใน repo
- ไฟล์ต้นฉบับหลักสร้างจากแชท Claude แล้วส่งมาเป็น `index.html` ใหม่ทั้งไฟล์ ถ้าแก้ในนี้โดยตรง ให้แก้เฉพาะจุด และแจ้ง Om ว่าแก้อะไรเพื่อให้ไฟล์ต้นฉบับในแชทตรงกัน
- ก่อน commit: เปิด index.html ในเบราว์เซอร์ทดสอบหน้าวันนี้ ปฏิทิน สถิติ ว่าไม่มี error ในคอนโซล
- ข้อความ commit เป็นภาษาไทยสั้น ๆ บอกว่าแก้อะไร
