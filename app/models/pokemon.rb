class Pokemon < ApplicationRecord
  # Definimos los caminos de evolución para los iniciales de Paldea y Kanto
  EVOLUTION_PATHS = {
    "Sprigatito" => { target: "Floragato", level: 16 },
    "Floragato" => { target: "Meowscarada", level: 36 },
    "Fuecoco" => { target: "Crocalor", level: 16 },
    "Crocalor" => { target: "Skeledirge", level: 36 },
    "Quaxly" => { target: "Quaxwell", level: 16 },
    "Quaxwell" => { target: "Quaquaval", level: 36 },
    "Bulbasaur" => { target: "Ivysaur", level: 16 },
    "Ivysaur" => { target: "Venusaur", level: 32 },
    "Charmander" => { target: "Charmeleon", level: 16 },
    "Charmeleon" => { target: "Charizard", level: 36 },
    "Squirtle" => { target: "Wartortle", level: 16 },
    "Wartortle" => { target: "Blastoise", level: 36 },
    "Pikachu" => { target: "Raichu", level: 22 }
  }.freeze

  # Determina dinámicamente la URL del sprite animado de Pokémon Showdown
  def sprite_url
    self.class.sprite_url_for(species)
  end

  # Método de clase que puede usarse con cualquier nombre de especie
  def self.sprite_url_for(species_name)
    return "" if species_name.blank?

    retro_species = [
      "bulbasaur", "ivysaur", "venusaur",
      "charmander", "charmeleon", "charizard",
      "squirtle", "wartortle", "blastoise",
      "pikachu", "raichu"
    ]
    
    # Normalizamos el nombre de la especie (minúsculas, sin espacios)
    species_key = species_name.downcase.strip.gsub(' ', '')
    
    if retro_species.include?(species_key)
      "https://play.pokemonshowdown.com/sprites/gen5ani/#{species_key}.gif"
    else
      "https://play.pokemonshowdown.com/sprites/ani/#{species_key}.gif"
    end
  end

  # Validaciones para asegurar que los datos guardados sean coherentes
  validates :name, presence: true
  validates :species, presence: true
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :hunger, numericality: { only_integer: true, in: 0..100 }
  validates :happiness, numericality: { only_integer: true, in: 0..100 }

  # Callback para ajustar límites de estadísticas antes de validar
  before_validation :clip_stats

  # Callback para procesar subidas de nivel y evolución antes de guardar
  before_save :level_up_if_possible!

  # Acción para alimentar al Pokémon
  # Reduce el hambre (hacia 0) y da un poco de experiencia
  def feed!
    self.hunger -= 20
    self.experience += 15
    self.last_interaction = Time.current
    save!
  end

  # Acción para jugar con el Pokémon
  # Aumenta la felicidad (hacia 100), incrementa el hambre por el ejercicio y da experiencia
  def play!
    self.happiness += 20
    self.hunger += 10
    self.experience += 25
    self.last_interaction = Time.current
    save!
  end

  # Devuelve el estado de ánimo (mood) según sus estadísticas
  def mood
    if hunger > 80
      "Hambriento 😩"
    elsif happiness < 30
      "Aburrido 😢"
    elsif hunger > 50
      "Hambriento 🙂"
    elsif happiness > 80
      "¡Muy Feliz! 😄"
    else
      "Feliz 🙂"
    end
  end

  private

  # Clampea los valores de hambre y felicidad para que no excedan el rango 0-100
  def clip_stats
    self.hunger = hunger.clamp(0, 100) if hunger
    self.happiness = happiness.clamp(0, 100) if happiness
    self.experience = 0 if experience && experience < 0
    self.level = 1 if level && level < 1
  end

  # Lógica para subir de nivel si la experiencia supera el umbral requerido
  # Usamos una fórmula clásica: 100 puntos de experiencia por nivel actual.
  def level_up_if_possible!
    experience_needed = level * 100
    while experience >= experience_needed
      self.experience -= experience_needed
      self.level += 1
      experience_needed = level * 100
    end
    evolve_if_possible!
  end

  # Comprueba si el nivel actual es suficiente para que la especie evolucione
  def evolve_if_possible!
    path = EVOLUTION_PATHS[species]
    if path && level >= path[:level]
      self.species = path[:target]
    end
  end
end
