require "kemal"
require "./db"

# ---------------------------------------------------------------------------
# Bootstrap: create schema + seed on first run (idempotent, fast)
# ---------------------------------------------------------------------------
RecipeDB.setup!
RecipeDB.seed!

# ---------------------------------------------------------------------------
# Server configuration
# ---------------------------------------------------------------------------
Kemal.config.port = (ENV["PORT"]?.try(&.to_i) || 3000)
Kemal.config.host_binding = "0.0.0.0"

# ---------------------------------------------------------------------------
# Helper: nil-if-blank
# ---------------------------------------------------------------------------
def presence(s : String?) : String?
  return nil if s.nil? || s.empty?
  s
end

# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

# Health check
get "/health" do
  "ok"
end

# Home — redirect to recipe list
get "/" do |env|
  env.redirect "/recipes"
end

# List all recipes
get "/recipes" do |env|
  recipes = RecipeDB.all
  render "src/views/recipes/index.ecr"
end

# Show create form
get "/recipes/new" do |env|
  errors = {} of String => String
  form = {
    "name"         => "",
    "description"  => "",
    "ingredients"  => "",
    "instructions" => "",
    "category"     => "Uncategorized",
    "servings"     => "",
    "prep_minutes" => "",
    "cook_minutes" => "",
    "difficulty"   => "medium",
  }
  render "src/views/recipes/new.ecr"
end

# Handle create form submission
post "/recipes" do |env|
  body = env.params.body

  name         = body["name"]?.try(&.strip) || ""
  raw_desc     = body["description"]?.try(&.strip)
  description  = (raw_desc && !raw_desc.empty?) ? raw_desc : nil
  ingredients  = body["ingredients"]?.try(&.strip) || ""
  instructions = body["instructions"]?.try(&.strip) || ""
  category     = body["category"]?.try(&.strip) || "Uncategorized"
  raw_serv     = body["servings"]?.try(&.strip)
  servings     = (raw_serv && !raw_serv.empty?) ? raw_serv.to_i? : nil
  raw_prep     = body["prep_minutes"]?.try(&.strip)
  prep_minutes = (raw_prep && !raw_prep.empty?) ? raw_prep.to_i? : nil
  raw_cook     = body["cook_minutes"]?.try(&.strip)
  cook_minutes = (raw_cook && !raw_cook.empty?) ? raw_cook.to_i? : nil
  difficulty   = body["difficulty"]?.try(&.strip) || "medium"

  errors = {} of String => String

  errors["name"] = "Recipe name is required." if name.empty?
  errors["ingredients"] = "At least one ingredient is required." if ingredients.empty?
  errors["instructions"] = "Instructions are required." if instructions.empty?
  errors["difficulty"] = "Difficulty must be easy, medium, or hard." unless {"easy", "medium", "hard"}.includes?(difficulty)

  unless errors.empty?
    form = {
      "name"         => name,
      "description"  => description || "",
      "ingredients"  => ingredients,
      "instructions" => instructions,
      "category"     => category,
      "servings"     => servings.try(&.to_s) || "",
      "prep_minutes" => prep_minutes.try(&.to_s) || "",
      "cook_minutes" => cook_minutes.try(&.to_s) || "",
      "difficulty"   => difficulty,
    }
    render "src/views/recipes/new.ecr"
  else
    RecipeDB.create(
      name: name,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      category: category,
      servings: servings,
      prep_minutes: prep_minutes,
      cook_minutes: cook_minutes,
      difficulty: difficulty
    )
    env.redirect "/recipes"
  end
end

# Show recipe detail
get "/recipes/:id" do |env|
  id = env.params.url["id"].to_i32?
  if id.nil?
    env.response.status_code = 404
    next "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><title>Not Found</title><link rel='stylesheet' href='/style.css'></head><body style='background:#15181e;color:#e4e7ec;font-family:system-ui;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;'><div style='text-align:center;'><h1 style='font-size:3rem;margin:0;'>404</h1><p>Recipe not found.</p><a href='/recipes' style='color:#4d73d8;'>Back to recipes</a></div></body></html>"
  end

  recipe = RecipeDB.find(id)
  if recipe.nil?
    env.response.status_code = 404
    next "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><title>Not Found</title><link rel='stylesheet' href='/style.css'></head><body style='background:#15181e;color:#e4e7ec;font-family:system-ui;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;'><div style='text-align:center;'><h1 style='font-size:3rem;margin:0;'>404</h1><p>Recipe not found.</p><a href='/recipes' style='color:#4d73d8;'>Back to recipes</a></div></body></html>"
  end

  render "src/views/recipes/show.ecr"
end

# ---------------------------------------------------------------------------
# Start server
# ---------------------------------------------------------------------------
puts "==> Recipes server listening on #{Kemal.config.host_binding}:#{Kemal.config.port}"
Kemal.run
