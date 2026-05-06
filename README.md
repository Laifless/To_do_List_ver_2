# Hunter System

> *"Arise."*

App promemoria e gym tracker ispirata a **Solo Leveling**. Completa quest, entra nei dungeon, scala i rank da **E** fino a **S**.

---

## Indice

- [Funzionalità](#funzionalità)
- [Struttura del progetto](#struttura-del-progetto)
- [Sistema XP e Rank](#sistema-xp-e-rank)
- [Setup](#setup)
- [Permessi Android](#permessi-android)
- [Dipendenze](#dipendenze)
- [Bug fixati](#bug-fixati)
- [Idee future](#idee-future)

---

## Funzionalità

### Quest Log
Gestisci tre tipologie di quest:

- **Daily** — obiettivi giornalieri ripetibili (studio, corsa, lettura...)
- **Adventure** — obiettivi one-shot a lungo termine
- **Gym (Dungeon)** — schede di allenamento con tracciamento serie/peso

Ogni quest può avere un **reminder** con notifica programmata all'orario scelto.

### Dungeon System
Crea schede di allenamento scegliendo esercizi dalla libreria integrata o aggiungendone di custom. Per ogni esercizio imposti le serie target. Durante l'allenamento:

- Logga peso e reps per ogni set
- Timer di recupero (60 / 90 / 120 secondi) con countdown visivo
- Storico per esercizio con grafico del peso nel tempo
- Record personale evidenziato in oro

### Status Window
Pannello del personaggio con:

- Livello attuale con numero enorme animato
- Rank corrente (E → S) con colore dedicato e titolo
- Statistiche: volume totale sollevato, dungeon completati, quest totali/completate
- Barra XP verso il prossimo livello
- Preview del rank successivo con livello minimo richiesto

### Animazione Level-Up
Ogni volta che sali di livello appare una finestra stile Solo Leveling:

- Schermo scurito all'85%
- Finestra blu con glow pulsante e bracket angolari
- Shimmer diagonale che scorre una volta
- Numero del livello che si conta su in tempo reale
- Se cambi rank, appare il riquadro del nuovo rank con titolo
- Doppio buzz aptico

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
├── main.dart                          # Entry point, MaterialApp, Provider
│
├── core/
│   ├── colors.dart                    # Palette centralizzata (niente magic numbers)
│   ├── theme.dart                     # ThemeData + stili tipografici riutilizzabili
│   ├── notifications.dart             # NotificationService con zonedSchedule reale
│   └── haptics.dart                   # SystemFeedback: firma sensoriale per ogni evento
│
├── models/
│   ├── set_log.dart                   # Singolo set loggato (data, peso, reps)
│   ├── exercise_blueprint.dart        # Definizione esercizio + lista default
│   ├── gym_task.dart                  # Esercizio in una scheda (con storico e record)
│   ├── quest.dart                     # Quest (daily / gym / adventure)
│   └── hunter_rank.dart              # Enum rank E→S + classe LevelSystem (XP)
│
├── providers/
│   └── system_provider.dart          # Stato globale, persistenza, stream level-up
│
├── widgets/
│   ├── glow_box.dart                  # Container con bordo e doppio glow
│   ├── glow_fab.dart                  # FAB con glow pulsante animato
│   ├── section_header.dart            # Header sezione con barra colorata
│   ├── system_window.dart             # Finestra sci-fi con bracket e animazione entrata
│   ├── level_up_overlay.dart          # Overlay full-screen level-up
│   ├── boot_screen.dart               # Schermata di caricamento terminale
│   └── slide_route.dart               # PageRoute con slide da destra
│
└── screens/
    ├── main_scaffold.dart             # Bottom nav + listener stream level-up
    ├── quest_log_screen.dart          # Lista daily e adventure
    ├── dungeon_keys_screen.dart       # Lista schede gym
    ├── dungeon_maker_screen.dart      # Creazione scheda con selezione esercizi
    ├── active_dungeon_screen.dart     # Sessione di allenamento attiva
    ├── exercise_history_screen.dart   # Storico set + grafico peso
    ├── skill_book_screen.dart         # Libreria esercizi per gruppo muscolare
    └── status_screen.dart             # Pannello personaggio con rank e XP
```

---

## Sistema XP e Rank

### Formula XP
| Azione | XP guadagnati |
|--------|--------------|
| Quest daily/adventure completata | +50 XP |
| Dungeon (gym) completato | +200 XP |
| Ogni 10 kg di volume sollevato | +1 XP |

### Curva livelli
La soglia XP per salire di livello cresce esponenzialmente:

```
XP per livello N = 100 × N × 1.2^(N-1)
```

Cresce, ma non in modo brutale — i primi livelli si raggiungono in pochi giorni di uso regolare.

### Tabella rank
| Rank | Livello minimo | Titolo | Colore |
|------|---------------|--------|--------|
| E | 1 | Weakest Hunter | Grigio |
| D | 5 | Awakened | Verde |
| C | 10 | Competent | Azzurro |
| B | 20 | Elite Hunter | Viola |
| A | 35 | National Asset | Arancione |
| S | 60 | Shadow Monarch | Rosso |

Quando raggiungi il livello minimo di un rank superiore, il level-up overlay mostra anche il **rank-up** con il nuovo titolo.

---

## Setup

**1. Clona il progetto e installa le dipendenze**
```bash
flutter pub get
```

**2. Aggiungi i permessi Android** (vedi sezione sotto)

**3. Avvia**
```bash
flutter run
```



## Dipendenze

```yaml
dependencies:
  flutter_local_notifications: ^17.2.2   # Notifiche con scheduling reale
  timezone: ^0.9.4                        # Timezone per zonedSchedule
  flutter_timezone: ^3.0.1               # Rileva timezone locale del dispositivo
  provider: ^6.1.2                        # State management
  shared_preferences: ^2.2.3             # Persistenza locale
```

---

## Bug fixati rispetto alla versione originale

**1. Notifiche non programmate**
`scheduleNotification` chiamava `notifPlugin.show()` ignorando `scheduledTime` — la notifica partiva subito. Ora usa `zonedSchedule` con timezone reale tramite i package `timezone` e `flutter_timezone`.

**2. Memory leak nel timer recupero**
Il timer di recupero veniva creato con `Timer.periodic` dentro il `builder` di uno `StatefulBuilder` — ne generava uno nuovo a ogni rebuild. Il dialog è ora uno `StatefulWidget` dedicato (`_LogSetDialog`) con il timer gestito correttamente in `dispose()`.

**3. Timer non cancellabile**
`_startTimer` riceveva il `Timer` per valore — il `cancel()` esterno non aveva effetto. Risolto con il timer come campo dello state, cancellato in `dispose()` e prima di ogni conferma.

**4. `setState` da context del dialog**
In `DungeonMakerScreen._toggleExercise`, `setState` veniva chiamato dall'interno del builder del dialog tramite il suo `ctx`. Su alcune versioni di Flutter questo viene silenziosamente ignorato. Fix: il dialog ora restituisce il valore tramite `Navigator.pop(ctx, sets)` e il `setState` avviene nel `.then()`, quando si è di nuovo nel context del widget padre.

**5. Crash `_dependents.isEmpty is not true`**
`build()` di `MainScaffold` usava `context.watch<SystemProvider>()` e restituiva `BootScreen()` — quando il provider notificava `isLoading = false`, Flutter tentava un rebuild su un context già sporco. Fix: `Consumer` isola il rebuild in un subtree dedicato; la sottoscrizione allo stream level-up ora attende con retry che `isLoading` sia effettivamente `false`.

**6. `withOpacity` deprecato**
Sostituito ovunque con `AppColors.alpha(color, opacity)` che usa `withValues(alpha:)`.

**7. `mounted` check mancante dopo `await`**
Aggiunti tutti i check `if (!mounted) return` dopo operazioni asincrone per evitare crash su widget smontati.



---

## Idee future

- **Streak giornalieri** — la struttura è pronta, basta aggiungere `int streakDays` e `DateTime lastDailyReset` al provider e mostrarlo nello Status Screen.
- **Suoni custom** — file audio in `assets/sounds/` per level-up, quest complete, timer scaduto. Più immersivi di `SystemSound`.
- **Achievements** — titoli sbloccabili per milestone (es. *"100 set loggati"*, *"Volume > 10.000 kg"*, *"30 daily completate di fila"*).
- **Esportazione CSV** — storico degli allenamenti esportabile per analisi esterne.
- **Widget homescreen** — reminder delle daily direttamente nella home Android.
