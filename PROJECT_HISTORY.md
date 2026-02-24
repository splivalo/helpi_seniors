# Helpi Senior — Project History

> Kronologija ključnih odluka i izmjena

---

## 2026-02-24 — Inicijalizacija projekta

### Odluka: Dizajn arhitekture i DB sheme

- **Kontekst:** Početak razvoja Helpi Senior mobilne aplikacije za povezivanje seniora i studenata.
- **Odluka:** Definirana kompletna logička shema baze (11 tablica), slojni Flutter arhitektura (Clean Architecture + feature-first), i User Journey u 15 koraka.
- **Ključne tablice:** `users`, `student_profiles`, `student_services`, `availability_slots`, `availability_exceptions`, `bookings`, `payments`, `reviews`, `chat_rooms`, `chat_messages`, `notifications`.
- **Razlog:** Solid foundation prije pisanja ijedne linije produkcijskog koda. Seniori su target korisnici → UX principi definirani od starta (visoki kontrast, veliki gumbi, max 3 koraka).
- **Stack:** Flutter + Bloc/Cubit, Supabase/Node.js backend, PostgreSQL, Stripe, Firebase FCM.
- **Chat model:** Senior ↔ Admin ↔ Student (admin kao posrednik za sigurnost).
- **Status:** ✅ ARCHITECTURE.md kreiran.
