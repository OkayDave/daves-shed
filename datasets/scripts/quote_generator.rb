# frozen_string_literal: true
require 'json'

TAGS = %w[
  discipline growth mindset resilience action focus success fear creativity consistency purpose confidence identity
]

TONES = %w[calm aggressive philosophical punchy intense melancholic]

TEMPLATES = [
  # contrast
  "Discipline is choosing %{a} over %{b}.",
  "You don’t need more %{a}, you need more %{b}.",
  "%{a} grows when %{b} is uncomfortable.",
  "%{a} is the cost of %{b}.",

  # consequence
  "Every %{a} you avoid becomes %{b} later.",
  "Ignore %{a} long enough and it becomes %{b}.",
  "%{a} delayed is %{b} multiplied.",

  # identity / philosophy
  "You become what you repeatedly %{a}.",
  "%{a} is not something you find, it’s something you build.",
  "Your %{a} reveals your %{b}.",
  "%{a} is a mirror of %{b}.",

  # time / inevitability
  "%{a} compounds quietly into %{b}.",
  "Given enough time, %{a} becomes %{b}.",
  "%{a} is just %{b} stretched over time.",

  # punchy / aggressive
  "%{a} doesn’t care how you feel.",
  "No one is coming to fix your %{a}.",
  "%{a} is earned, not given.",
  "Comfort is the enemy of %{a}.",

  # poetic / slightly darker
  "%{a} grows in the places you avoid looking.",
  "%{a} is forged in silence and revealed in chaos.",
  "%{a} survives where %{b} collapses.",
  "The shadow of %{a} is %{b}.",

  # paradox
  "The more you chase %{a}, the more %{b} escapes you.",
  "Let go of %{a} and %{b} appears.",
  "%{a} begins where %{b} ends.",

  # modern / blunt
  "You’re not stuck, you’re avoiding %{a}.",
  "%{a} is just %{b} with excuses removed.",
  "If it costs your %{a}, it’s too expensive.",
  "%{a} is a decision, not a feeling."
]

WORDS = %w[
  comfort discipline effort focus growth success fear excuses habits consistency attention time energy identity standards pain progress clarity doubt resistance chaos purpose courage failure avoidance truth control momentum
]

# --- FAKE AUTHOR GENERATOR ---

FEMININE_FIRST = %w[
  Aurelia Livia Octavia Valeria Cassia Flavia Sabina Marcellina Lucia Elara Nyra Solene Virelle Kaelis Thessa Ilyra Seraphine
]

MASC_FIRST = %w[
  Marcus Cassius Lucius Tiberius Aelius Darius Corvinus Seneca Alaric Caius Varro
]

NEUTRAL_FIRST = %w[
  Rowan Avery Quinn Sable Arden Lyric Echo Phoenix
]

LAST_NAMES = %w[
  Vale Thorn Voss Aurex Noctis Halcyon Mirex Solis Virex Draven Caelum Nyx Veritas Umbra
]

def generate_author
  roll = rand

  first =
    if roll < 0.6
      FEMININE_FIRST.sample
    elsif roll < 0.85
      MASC_FIRST.sample
    else
      NEUTRAL_FIRST.sample
    end

  last = LAST_NAMES.sample

  "#{first} #{last}"
end

def generate_quote
  template = TEMPLATES.sample
  a, b = WORDS.sample(2)
  template % { a: a, b: b }
end

quotes = []

600.times do |i|
  quotes << {
    id: "q_%04d" % (i + 1),
    quote: generate_quote,
    author: generate_author,
    tags: TAGS.sample(2),
    source: "synthetic",
    year: 2026,
    tone: TONES.sample,
    verified: false
  }
end

File.write("../gen_quotes.json", JSON.pretty_generate(quotes))
puts "Generated #{quotes.size} quotes → ../gen_quotes.json"

