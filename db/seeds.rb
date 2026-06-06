# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Crear un Pokémon inicial por defecto si no existe ninguno
Pokemon.find_or_create_by!(name: "Michi Verde") do |p|
  p.species = "Sprigatito"
  p.level = 1
  p.experience = 0
  p.hunger = 50
  p.happiness = 50
end
