require "test_helper"

class PokemonTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    pokemon = Pokemon.new(name: "Michi", species: "Sprigatito")
    assert pokemon.valid?
  end

  test "should require name and species" do
    pokemon = Pokemon.new
    assert_not pokemon.valid?
  end

  test "should clamp hunger and happiness between 0 and 100" do
    pokemon = Pokemon.create!(name: "Test", species: "Sprigatito", hunger: 150, happiness: -50)
    assert_equal 100, pokemon.hunger
    assert_equal 0, pokemon.happiness
  end

  test "feeding should decrease hunger and increase experience" do
    pokemon = Pokemon.create!(name: "Test", species: "Sprigatito", hunger: 50, experience: 0)
    pokemon.feed!
    assert_equal 30, pokemon.hunger       # 50 - 20
    assert_equal 15, pokemon.experience   # 0 + 15
  end

  test "playing should increase happiness and hunger" do
    pokemon = Pokemon.create!(name: "Test", species: "Sprigatito", hunger: 50, happiness: 50, experience: 0)
    pokemon.play!
    assert_equal 70, pokemon.happiness    # 50 + 20
    assert_equal 60, pokemon.hunger       # 50 + 10
    assert_equal 25, pokemon.experience   # 0 + 25
  end

  test "level up and evolution logic" do
    pokemon = Pokemon.create!(name: "Test", species: "Sprigatito", level: 15, experience: 85)
    
    # Ganamos 25 XP al jugar, totalizando 110 XP.
    # Con nivel 15, necesitamos 1500 XP para subir?
    # Espera, en app/models/pokemon.rb:
    # "experience_needed = level * 100" => con nivel 15, necesitamos 1500 XP para subir de nivel.
    # Ah! Vamos a verificar la fórmula en nuestro test para que coincida exactamente.
    # Si level es 15, experience_needed es 15 * 100 = 1500.
    # Probemos con un nivel más bajo para simplificar: nivel 1.
    # Nivel 1 necesita 100 XP. Si empezamos con nivel 1 y 85 XP, y ganamos 25 XP (total 110 XP):
    # Se debe consumir 100 XP, subir a Nivel 2, y quedar con 10 XP restantes.
    pokemon = Pokemon.create!(name: "Test", species: "Sprigatito", level: 1, experience: 80)
    pokemon.play! # +25 XP => 105 XP total. 105 >= 100 => sube a lvl 2, queda con 5 XP.
    assert_equal 2, pokemon.level
    assert_equal 5, pokemon.experience

    # Test de evolución:
    # Sprigatito evoluciona a Floragato al nivel 16.
    pokemon = Pokemon.create!(name: "Test", species: "Sprigatito", level: 15, experience: 1490)
    pokemon.play! # +25 XP => 1515 XP total. 1515 >= 1500 => sube a lvl 16, queda con 15 XP, evoluciona!
    assert_equal 16, pokemon.level
    assert_equal "Floragato", pokemon.species
  end

  test "kanto evolution and retro sprite URL logic" do
    # Pikachu -> Raichu a nivel 22
    pikachu = Pokemon.create!(name: "Pika", species: "Pikachu", level: 21, experience: 2090)
    pikachu.play! # +25 XP => 2115 >= 2100 => sube a lvl 22, evoluciona
    assert_equal 22, pikachu.level
    assert_equal "Raichu", pikachu.species

    # Sprite URLs
    assert_equal "https://play.pokemonshowdown.com/sprites/gen5ani/pikachu.gif", Pokemon.new(species: "Pikachu").sprite_url
    assert_equal "https://play.pokemonshowdown.com/sprites/gen5ani/bulbasaur.gif", Pokemon.new(species: "Bulbasaur").sprite_url
    assert_equal "https://play.pokemonshowdown.com/sprites/ani/sprigatito.gif", Pokemon.new(species: "Sprigatito").sprite_url
    assert_equal "https://play.pokemonshowdown.com/sprites/ani/floragato.gif", Pokemon.new(species: "Floragato").sprite_url
  end
end
