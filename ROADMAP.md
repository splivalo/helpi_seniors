# Helpi Senior — Roadmap

> ⚠️ STROGO ZABRANJENO samoinicijativno započeti bilo koji zadatak s Roadmapa.  
> Svaki korak zahtijeva izričitu potvrdu korisnika.

---

## Faza 1 — Foundation (infrastruktura)

- [x] 1.1 Reorganizacija `lib/` folder strukture (feature-first Clean Arch)
- [ ] 1.2 Dodavanje paketa u `pubspec.yaml` (bloc, go_router, dio, etc.)
- [x] 1.3 `AppStrings` i18n (Gemini Hybrid pattern, HR + EN)
- [x] 1.4 Senior-friendly tema (visoki kontrast, veliki fontovi)
- [ ] 1.5 GoRouter setup s placeholder ekranima
- [ ] 1.6 DI setup (GetIt + injectable)
- [ ] 1.7 Dio HTTP klijent s interceptorima

## Faza 2 — Auth

- [ ] 2.1 Login ekran (email + lozinka, senior-friendly)
- [ ] 2.2 Registracija ekran
- [ ] 2.3 Auth Cubit + repository
- [ ] 2.4 Token storage (flutter_secure_storage)
- [ ] 2.5 Auto-login na splash

## Faza 3 — Marketplace

- [ ] 3.1 Student lista ekran (kartice s foto, imenom, ocjenom, cijenom)
- [ ] 3.2 Filter Bottom Sheet (vrsta usluge, datum, blizina)
- [ ] 3.3 Student detalj ekran (bio, recenzije, dostupnost)
- [ ] 3.4 Marketplace Cubit + repository
- [ ] 3.5 Integracija s backendom

## Faza 4 — Booking & Payment

- [ ] 4.1 Slot Picker (kalendar + vremenski slotovi)
- [ ] 4.2 Pregled narudžbe ekran
- [ ] 4.3 Stripe Payment Sheet integracija
- [ ] 4.4 Booking Cubit + repository
- [ ] 4.5 Payment Cubit + Stripe service
- [ ] 4.6 Potvrda narudžbe ekran

## Faza 5 — Chat

- [ ] 5.1 Chat lista ekran
- [ ] 5.2 Chat soba ekran (poruke)
- [ ] 5.3 WebSocket integracija
- [ ] 5.4 Chat Cubit + repository
- [ ] 5.5 Admin-posredovani chat model

## Faza 6 — Reviews & Profile

- [ ] 6.1 Review forma (zvjezdice + komentar)
- [ ] 6.2 Profil ekran seniora
- [ ] 6.3 Edit profil
- [ ] 6.4 Notifikacije ekran

## Faza 7 — Polish & Launch

- [ ] 7.1 Push notifikacije (Firebase FCM)
- [ ] 7.2 Error handling & offline mode
- [ ] 7.3 Performance optimizacija
- [ ] 7.4 Accessibility audit
- [ ] 7.5 Beta testing
- [ ] 7.6 Play Store / App Store deployment
