# 📸 Visuelles Tutorial - Edubase Viewer Setup

Für beste Screenshot-Qualität: Viewer richtig einstellen!

---

## ✅ RICHTIG - Perfekte Einstellung

```
┌─────────────────────────────────────────────────────────────┐
│ Edubase Viewer                                    ☰ × ─ □   │
├─────────────────────────────────────────────────────────────┤
│  🔍 100%  [Fit to width ▼]  ◄  1 / 98  ►                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌───────────────────────────────────────────────┐        │
│   │                                               │        │
│   │         BUCH INHALT (volle Breite)           │        │
│   │                                               │        │
│   │         • Fit to width aktiviert             │        │
│   │         • Zoom 100-120%                      │        │
│   │         • Keine Seitenleiste                 │        │
│   │         • Ganze Seite sichtbar               │        │
│   │                                               │        │
│   │         ═══════════════════════              │        │
│   │         Text ist gut lesbar                  │        │
│   │         und komplett sichtbar                │        │
│   │         ═══════════════════════              │        │
│   │                                               │        │
│   │                                               │        │
│   └───────────────────────────────────────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Checkliste:**
- ✅ Fit to width oder Fit to page
- ✅ Zoom 100-120% (gut lesbar)
- ✅ Ganze Seite sichtbar
- ✅ Keine Menüs/Sidebar im Weg
- ✅ Controls oben OK (werden weggeschnitten)

---

## ❌ FALSCH - Schlechte Einstellungen

### Problem 1: Seitenleiste offen

```
┌─────────────────────────────────────────────────────────────┐
│ Edubase Viewer                                              │
├────────────┬────────────────────────────────────────────────┤
│            │                                                │
│ Inhalt     │    ┌─────────────────────┐                    │
│ ─────      │    │                     │                    │
│ Kap 1      │    │  BUCH (klein)      │    ❌ Seitenleiste │
│ Kap 2      │    │                     │    verdeckt Inhalt │
│ Kap 3      │    │                     │                    │
│            │    └─────────────────────┘                    │
│            │                                                │
└────────────┴────────────────────────────────────────────────┘
```

**Problem:** Seitenleiste wird mit gespeichert!  
**Lösung:** Schließe Sidebar/Navigation vor Capture

---

### Problem 2: Zu klein (falscher Zoom)

```
┌─────────────────────────────────────────────────────────────┐
│  🔍 60%  [Fit to page ▼]                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                                                             │
│             ┌──────────────────┐                           │
│             │                  │                           │
│             │   BUCH           │   ❌ Zu klein = schlechte │
│             │   (winzig)       │   OCR-Qualität            │
│             │                  │                           │
│             │   Text zu klein  │                           │
│             │   ════════       │                           │
│             │                  │                           │
│             └──────────────────┘                           │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Problem:** Text zu klein für gute OCR!  
**Lösung:** Erhöhe Zoom auf 100-120%

---

### Problem 3: Zu groß (scrollen nötig)

```
┌─────────────────────────────────────────────────────────────┐
│  🔍 150%                                                     │
├─────────────────────────────────────────────────────────────┤
│  ═══════════════════════════════════  ▲                    │
│  BUCH INHALT ist zu groß und         │                    │
│  geht über den sichtbaren Bereich     █  ❌ Teil der Seite │
│  hinaus. Beim Screenshot wird nur     █  wird abgeschnitten│
│  der sichtbare Teil erfasst!          │                    │
│  ═══════════════════════════════════  ▼  ❌ Text fehlt     │
│                                                             │
│  [Unten ist noch mehr, aber nicht sichtbar...]             │
└─────────────────────────────────────────────────────────────┘
```

**Problem:** Seite passt nicht ins Fenster!  
**Lösung:** Nutze "Fit to page" oder niedrigeren Zoom

---

## 🎯 Perfekte Settings - Schritt für Schritt

### Schritt 1: Öffne Edubase Viewer

```bash
./capture.sh
# Browser öffnet sich mit https://app.edubase.ch/#doc/60505/1
```

### Schritt 2: Login (falls nötig)

Logge dich mit deinem Edubase-Account ein.  
Wird gespeichert → nächstes Mal automatisch eingeloggt.

### Schritt 3: Schließe Sidebar

- Klicke auf das Menü-Icon (☰) um Sidebar zu schließen
- Oder drücke Taste (falls vorhanden)
- Nur Buch-Inhalt soll sichtbar sein

### Schritt 4: Stelle Ansicht ein

**Option A: Fit to width**
- Dropdown oben: "Fit to width"
- Seite füllt Browser horizontal
- ✅ Empfohlen für Hochformat-Seiten

**Option B: Fit to page**
- Dropdown oben: "Fit to page"
- Ganze Seite sichtbar
- ✅ Empfohlen für Querformat-Seiten

**Option C: Manueller Zoom**
- Wähle 100% oder 120%
- Stelle sicher, dass ganze Seite sichtbar ist
- ✅ OK wenn Seite komplett sichtbar

### Schritt 5: Prüfe Sichtbarkeit

**Checkliste:**
- [ ] Ganze Seite von oben bis unten sichtbar?
- [ ] Text ist scharf und gut lesbar?
- [ ] Keine Sidebar/Menüs verdecken Inhalt?
- [ ] Kein Scrollen nötig?

**Wenn alle Punkte ✓ → Enter im Terminal drücken!**

---

## 🔧 Tipps für verschiedene Buch-Formate

### Textbücher (viel Text, wenig Bilder)
```
Settings: Fit to width + 110% Zoom
→ Text wird groß = bessere OCR
```

### Bilderbücher / Grafik-lastig
```
Settings: Fit to page + 100% Zoom
→ Bilder komplett sichtbar
```

### Gemischt (Text + Bilder)
```
Settings: Fit to width + 100% Zoom
→ Bester Kompromiss
```

---

## 📊 Vorher/Nachher Vergleich

### VORHER (Schlechte Settings)
```
Zoom: 60%, Sidebar offen
Screenshot: 1920x1080 px
Inhalt: 800x900 px (klein!)
OCR-Qualität: 60% ⭐⭐
```

### NACHHER (Gute Settings)
```
Zoom: 110%, Fit to width, Sidebar zu
Screenshot: 1920x1080 px
Inhalt: 1700x1000 px (groß!)
OCR-Qualität: 95% ⭐⭐⭐⭐⭐
```

**Resultat:** 35% mehr erkannter Text!

---

## ⚡ Pro-Tipps

### 1. Vollbild-Modus (optional)
```
Drücke F11 für Vollbild
→ Mehr Platz = größerer Inhalt = bessere Qualität
→ Funktioniert mit Capture!
```

### 2. High-DPI Display
```
Wenn du 4K Monitor hast:
→ Automatisch bessere Screenshots
→ Keine extra Settings nötig
```

### 3. Multi-Monitor Setup
```
Capture läuft auf Monitor 1
Du kannst auf Monitor 2 arbeiten
→ Perfekt zum Multitasking!
```

---

## ❓ FAQ

**Q: Muss ich jedes Mal neu einstellen?**  
A: Nein! Einstellungen bleiben im Browser gespeichert.

**Q: Was wenn Seite beim Capture springt?**  
A: Normal! Der Script macht Screenshot + Weiterblättern.

**Q: Kann ich während Capture den Browser nutzen?**  
A: Nein, bitte nicht. Terminal/andere Apps: Ja!

**Q: Wie viel Zoom ist optimal?**  
A: 100-120%. Teste mit 2-3 Seiten, dann schau Ergebnis an.

---

**Jetzt bist du bereit! Viel Erfolg! 🚀**
