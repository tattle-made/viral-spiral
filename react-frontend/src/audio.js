import * as Tone from 'tone'

// F#m scale notes across two octaves
const CLICK_NOTES = ['F#2', 'A2', 'C#3', 'B1', 'D2']
const ARPEGGIO_NOTES = ['F#4', 'A4', 'C#5', 'E5']

let clickSynth = null
let arpSynth = null
let audioStarted = false
let arpDebounceTimer = null

async function ensureAudio() {
  if (!audioStarted) {
    await Tone.start()
    audioStarted = true
  }
}

function getClickSynth() {
  if (!clickSynth) {
    clickSynth = new Tone.Synth({
      oscillator: { type: 'sine' },
      envelope: { attack: 0.01, decay: 0.25, sustain: 0.0, release: 0.3 },
      volume: -10,
    }).toDestination()
  }
  return clickSynth
}

function getArpSynth() {
  if (!arpSynth) {
    arpSynth = new Tone.Synth({
      oscillator: { type: 'triangle' },
      envelope: { attack: 0.01, decay: 0.12, sustain: 0.05, release: 0.25 },
      volume: -14,
    }).toDestination()
  }
  return arpSynth
}

export async function playButtonClick() {
  try {
    await ensureAudio()
    const note = CLICK_NOTES[Math.floor(Math.random() * CLICK_NOTES.length)]
    getClickSynth().triggerAttackRelease(note, '8n')
  } catch (_) {}
}

export async function playScoreChange() {
  // Debounce: multiple scores changing in one update should fire once
  clearTimeout(arpDebounceTimer)
  arpDebounceTimer = setTimeout(async () => {
    try {
      await ensureAudio()
      const s = getArpSynth()
      const now = Tone.now()
      ARPEGGIO_NOTES.forEach((note, i) => {
        s.triggerAttackRelease(note, '16n', now + i * 0.09)
      })
    } catch (_) {}
  }, 20)
}
