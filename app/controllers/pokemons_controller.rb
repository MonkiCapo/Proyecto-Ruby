class PokemonsController < ApplicationController
  before_action :set_pokemon, only: [:show, :feed, :play]

  # GET /pokemons/:id o GET /
  def show
    # Si no se especifica ID, tomamos el último Pokémon creado.
    if @pokemon.nil?
      @pokemon = Pokemon.last
      if @pokemon.nil?
        # Si no hay ningún Pokémon creado en la base de datos, obligamos a elegir un inicial.
        redirect_to new_pokemon_path and return
      else
        redirect_to pokemon_path(@pokemon) and return
      end
    end

    # Cargamos todos los Pokémon para el selector de cambio rápido en la vista
    @all_pokemons = Pokemon.all
  end

  # GET /pokemons/new
  def new
    @starters = starters_list
    @pokemon = Pokemon.new
  end

  # POST /pokemons
  def create
    @pokemon = Pokemon.new(pokemon_params)
    # Asignamos estadísticas base de Tamagotchi
    @pokemon.level = 1
    @pokemon.experience = 0
    @pokemon.hunger = 50
    @pokemon.happiness = 50

    if @pokemon.save
      redirect_to pokemon_path(@pokemon), notice: "¡Felicidades! Has elegido a #{@pokemon.name} como tu compañero de aventuras."
    else
      @starters = starters_list
      render :new, status: :unprocessable_entity
    end
  end

  # POST /pokemons/:id/feed
  def feed
    if @pokemon.feed!
      flash[:notice] = "¡Alimentaste a #{@pokemon.name}! Su hambre disminuyó y ganó experiencia."
    else
      flash[:alert] = "No se pudo alimentar a #{@pokemon.name}."
    end
    redirect_to pokemon_path(@pokemon)
  end

  # POST /pokemons/:id/play
  def play
    if @pokemon.play!
      flash[:notice] = "¡Jugaste con #{@pokemon.name}! Su felicidad aumentó, pero ahora tiene un poco más de hambre."
    else
      flash[:alert] = "No se pudo jugar con #{@pokemon.name}."
    end
    redirect_to pokemon_path(@pokemon)
  end

  private

  def set_pokemon
    if params[:id].present?
      @pokemon = Pokemon.find(params[:id])
    end
  end

  def pokemon_params
    params.require(:pokemon).permit(:name, :species)
  end

  def starters_list
    [
      { species: "Bulbasaur", type: "Planta / Veneno", region: "Kanto" },
      { species: "Charmander", type: "Fuego", region: "Kanto" },
      { species: "Squirtle", type: "Agua", region: "Kanto" },
      { species: "Pikachu", type: "Eléctrico", region: "Kanto" },
      { species: "Sprigatito", type: "Planta", region: "Paldea" },
      { species: "Fuecoco", type: "Fuego", region: "Paldea" },
      { species: "Quaxly", type: "Agua", region: "Paldea" }
    ].map do |starter|
      starter.merge(sprite: Pokemon.sprite_url_for(starter[:species]))
    end
  end
end
