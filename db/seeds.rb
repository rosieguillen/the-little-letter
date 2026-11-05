# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

catalogue = {
  "Notebooks & Planners" => [
    ["Lined Notebook", 1295],
    ["Dot Grid Journal", 1695],
    ["Weekly Planner", 1995],
    ["Pocket Memo Book", 695],
    ["Project Pad", 1095]
  ],
  "Pens & Pencils" => [
    ["Fine Gel Pen", 495],
    ["Mechanical Pencil", 795],
    ["Brush Pen", 695],
    ["Highlighter Duo", 895],
    ["Graphite Pencil Set", 1095]
  ],
  "Desk Accessories" => [
    ["Pen Tray", 1495],
    ["Page Flags", 495],
    ["Desk Mat", 2495],
    ["Binder Clip Set", 795],
    ["Washi Tape Roll", 595]
  ],
  "Gift Sets" => [
    ["Letter Writing Kit", 2495],
    ["Study Set", 2295],
    ["Desk Essentials Set", 2995],
    ["Journaling Set", 2795],
    ["Thank You Card Set", 1895]
  ]
}

colours = ["Fern", "Oat", "Ink", "Clay", "Lilac"]

catalogue.each do |category_name, products|
  category = Category.find_or_create_by!(slug: category_name.parameterize) do |record|
    record.name = category_name
  end

  products.each do |name, price_cents|
    colours.each do |colour|
      category.products.find_or_create_by!(name: "#{colour} #{name}") do |product|
        product.description = "#{name} in #{colour.downcase}, from The Little Letter."
        product.price_cents = price_cents
      end
    end
  end
end