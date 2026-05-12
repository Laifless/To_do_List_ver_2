# Hunter System

> *"Arise."*

App promemoria e gym tracker ispirata a **Solo Leveling**. Completa quest, entra nei dungeon, scala i rank da **E** fino a **SSS**.

---

## Indice

- [Funzionalità](#funzionalità)
- [Struttura del progetto](#struttura-del-progetto)
- [Sistema XP doppio](#sistema-xp-doppio)
- [Rank E → SSS](#rank-e--sss)
- [Muscle Tier System](#muscle-tier-system)
- [Setup](#setup)
- [Permessi Android](#permessi-android)
- [Dipendenze](#dipendenze)
- [Bug fixati](#bug-fixati)
- [Idee future](#idee-future)

---

## Funzionalità

### Quest Log
Tre tipologie di quest:

- **Daily** — obiettivi giornalieri ripetibili (studio, corsa, lettura…)
- **Adventure** — obiettivi one-shot a lungo termine
- **Gym (Dungeon)** — schede di allenamento con tracciamento serie/peso

Ogni quest può avere un reminder con notifica programmata all'orario scelto.

### Dungeon System
Crea schede scegliendo esercizi dalla libreria integrata o aggiungendone di custom. Per ogni esercizio imposti le serie target. Durante l'allenamento puoi loggare peso e reps per ogni set, usare il timer di recupero (60 / 90 / 120 secondi) con countdown visivo, vedere lo storico per esercizio con grafico del peso nel tempo, e il record personale viene evidenziato in oro.

### Status Window
Pannello del personaggio con due livelli separati (Quest e Dungeon), rank corrente con titolo, barre XP indipendenti, statistiche generali, Muscle Map interattiva e tabella rank per muscolo.

### Muscle Map
Silhouette anatomica anteriore e posteriore del corpo. Ogni gruppo muscolare si colora in base al suo tier, calcolato sul volume cumulativo (peso × reps nel tempo). Tocca un muscolo per vedere tier corrente, barra di avanzamento e kg mancanti al tier successivo.

### Animazione Level-Up
Finestra stile Solo Leveling con schermo scurito, glow pulsante, shimmer diagonale, numero del livello che si conta su, e doppio buzz aptico. Il colore della finestra cambia in base al tipo: **oro** per le quest, **viola** per i dungeon. Se cambi rank, appare il riquadro con il nuovo titolo.

### Boot Screen
All'avvio, sequenza terminale con righe che appaiono una per una:
```
> initializing hunter system...
> loading quest registry...
> mounting dungeon archive...
> calibrating mana flow...
> SYSTEM ONLINE
```

---

## Struttura del progetto

```
lib/
├── main.dart                          # Entry point, AppRoot, MaterialApp
│
├── core/
│   ├── colors.dart                    # Palette centralizzata (AppColors)
│   ├── theme.dart                     # ThemeData + stili tipografici
│   ├── notifications.dart             # NotificationService con zonedSchedule
│   └── haptics.dart                   # SystemFeedback per ogni evento
│
├── models/
│   ├── set_log.dart                   # Singolo set loggato (data, peso, reps)
│   ├── exercise_blueprint.dart        # Definizione esercizio + lista default
│   ├── gym_task.dart                  # Esercizio in una scheda (storico, record)
│   ├── quest.dart                     # Quest (daily / gym / adventure)
│   └── hunter_rank.dart              # HunterRank E→SSS, LevelSystem, MuscleTier
│
├── providers/
│   └── system_provider.dart          # Stato globale, persistenza, stream level-up
│
├── widgets/
│   ├── glow_box.dart                  # Container con doppio glow
│   ├── glow_fab.dart                  # FAB con glow pulsante
│   ├── section_header.dart
│   ├── system_window.dart             # Finestra sci-fi con bracket angolari
│   ├── level_up_overlay.dart          # Overlay animato level-up (oro/viola)
│   ├── muscle_graph.dart              # Silhouette anatomica con tier colorati
│   ├── boot_screen.dart               # Loading stile terminale
│   └── slide_route.dart               # PageRoute con slide da destra
│
└── screens/
    ├── main_scaffold.dart             # Bottom nav + listener stream level-up
    ├── quest_log_screen.dart          # Lista daily e adventure
    ├── dungeon_keys_screen.dart       # Lista schede gym
    ├── dungeon_maker_screen.dart      # Creazione scheda con selezione esercizi
    ├── active_dungeon_screen.dart     # Sessione allenamento attiva con timer
    ├── exercise_history_screen.dart   # Storico set + grafico peso
    ├── skill_book_screen.dart         # Libreria esercizi per gruppo muscolare
    └── status_screen.dart             # Pannello personaggio completo
```

---

## Sistema XP doppio

Quest Level e Dungeon Level sono completamente indipendenti — ognuno ha il proprio livello, rank, e barra XP. Lo stream di level-up emette `({int level, bool isDungeon})` così l'overlay sa quale colore usare.

| Azione | XP guadagnati |
|--------|--------------|
| Quest daily/adventure completata | +50 XP |
| Dungeon (gym) completato | +300 XP |
| Ogni 10 kg di volume sollevato | +1 XP |

La curva di crescita usa `XP per livello N = 100 × N × 1.2^(N-1)` — esponenziale ma non brutale. I primi livelli si raggiungono in giorni, i rank alti richiedono mesi.

---

## Rank E → SSS

| Rank | Lv. min | Titolo | Colore |
|------|---------|--------|--------|
| E | 1 | Weakest Hunter | Grigio |
| D | 5 | Awakened | Verde |
| C | 10 | Competent | Azzurro |
| B | 20 | Elite Hunter | Viola |
| A | 35 | National Asset | Arancione |
| S | 60 | Shadow Monarch | Rosso |
| SS | 90 | Absolute Being | Rosa brillante |
| SS+ | 120 | Beyond Limit | Bianco caldo |
| SSS | 150 | Ruler of Rulers | Bianco puro |

Quando raggiungi il livello minimo di un rank superiore, l'overlay mostra il rank-up con il nuovo titolo.

---

## Muscle Tier System

Ogni gruppo muscolare ha un tier basato sul **volume cumulativo** (peso × reps, sommato nel tempo). Il calcolo avviene in `logSet()` — ogni set aggiunge `(weight × reps)` alla mappa `_muscleVolume[targetMuscle]`.

Riferimento: 4 serie × 10 reps × 60 kg = 2.400 kg per sessione per muscolo.

| Tier | Soglia | Tempo indicativo |
|------|--------|-----------------|
| Bronze | 1.000 kg | Prima sessione |
| Silver | 5.000 kg | ~1 settimana |
| Gold | 20.000 kg | ~1 mese |
| Platinum | 60.000 kg | ~3 mesi |
| Diamond | 120.000 kg | ~6 mesi |
| Ruby | 240.000 kg | ~1 anno |
| Crystal | 480.000 kg | ~2 anni |
| Elite | 700.000 kg | ~3 anni |
| Champion | 1.200.000 kg | ~5 anni |
| Celestial | 1.900.000 kg | ~8 anni |
| Titan | 2.400.000 kg | ~10+ anni |

Il widget `MuscleGraph` genera a runtime un SVG con i colori dei tier iniettati negli attributi `style` di ogni path muscolare, e usa `SvgPicture.string` di `flutter_svg` per renderizzarlo. Sopra l'SVG ci sono zone tap invisibili che attivano il tooltip per ogni muscolo.

---

## Setup

**1. Installa le dipendenze**
```bash
flutter pub get
```

**2. Aggiungi i permessi Android** (sezione sotto)

**3. Avvia**
```bash
flutter run
```

### Configurazione `android/app/build.gradle.kts`

Il plugin `flutter_local_notifications` richiede il desugaring Java 8:

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

### Icona app

L'icona è inclusa come PNG 1024×1024. Per generare tutte le dimensioni:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#04040F"
  adaptive_icon_foreground: "assets/icon/icon.png"
```

```bash
dart run flutter_launcher_icons
```

---

## Permessi Android

Aggiungi in `android/app/src/main/AndroidManifest.xml` dentro `<manifest>`:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

---

## Dipendenze

```yaml
dependencies:
  provider: ^6.1.2
  shared_preferences: ^2.2.3
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4
  flutter_timezone: ^3.0.1
  flutter_svg: ^2.0.10          # Muscle graph SVG dinamico
```

---

## Bug fixati

**Notifiche non schedulate** — `show()` ignorava `scheduledTime` e mostrava la notifica subito. Corretto con `zonedSchedule()` e i package `timezone` + `flutter_timezone`.

**Memory leak nel timer recupero** — `Timer.periodic` veniva creato dentro `StatefulBuilder.builder`, uno nuovo a ogni rebuild. Corretto con `_LogSetDialog` come `StatefulWidget` dedicato con timer in `dispose()`.

**Crash `_dependents.isEmpty`** — `context.watch` in `MainScaffold` durante il primo frame di `loadData()`. Corretto con `AppRoot` che usa `Selector<SystemProvider, bool>` su un nodo dell'albero separato. `MainScaffold` viene istanziato solo quando `isLoading` è già `false`.

**Dialog serie ignorato** — `setState()` dal context del builder del dialog veniva ignorato su Android. Corretto con `_SetsDialog` come `StatefulWidget` dedicato con stepper +/−, che restituisce il valore via `Navigator.pop(context, value)` + `await`.

**Cascade `.map()` scartata** — `..map()` con cascade notation restituisce la lista originale, non i widget. Corretto con `for` loop inline dentro `children:[]`.

**Overflow silhouette su A72** — il viewBox `160×340` lasciava margini troppo stretti su schermi ad alta densità. Corretto con viewBox `168×340`, corpo centrato a `cx=84`, `SizedBox` a 150dp e `ClipRect` per sicurezza.

**`withOpacity()` deprecato** — sostituito ovunque con `AppColors.alpha()` che usa `withValues(alpha:)`.

---

## Idee future

- **Streak giornalieri** — aggiungere `int streakDays` e `DateTime lastDailyReset` al provider. La struttura è già pronta.
- **Suoni custom** — file audio in `assets/sounds/` per level-up, quest complete e timer scaduto.
- **Achievements** — titoli sbloccabili per milestone: "100 set loggati", "Volume > 10.000 kg", "30 daily di fila".
- **Esportazione CSV** — storico allenamenti esportabile per analisi esterne.
- **Widget homescreen** — daily del giorno direttamente nella home Android con il package `home_widget`.
- **Animazione SSS speciale** — il rank SSS merita un effetto distinto rispetto al semplice glow blu/viola.
