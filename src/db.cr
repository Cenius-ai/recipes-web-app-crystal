require "db"
require "sqlite3"

# Database path — relative to project root
DB_PATH = "./recipes.db"

struct Recipe
  property id : Int32
  property name : String
  property description : String?
  property ingredients : String
  property instructions : String
  property category : String
  property servings : Int32?
  property prep_minutes : Int32?
  property cook_minutes : Int32?
  property difficulty : String
  property created_at : String
  property updated_at : String

  def initialize(
    @id = 0,
    @name = "",
    @description = nil,
    @ingredients = "",
    @instructions = "",
    @category = "Uncategorized",
    @servings = nil,
    @prep_minutes = nil,
    @cook_minutes = nil,
    @difficulty = "medium",
    @created_at = "",
    @updated_at = ""
  )
  end
end

module RecipeDB
  # Open a connection with WAL mode and foreign keys enabled
  def self.open
    DB.open("sqlite3:#{DB_PATH}") do |db|
      db.exec "PRAGMA foreign_keys = ON"
      db.exec "PRAGMA journal_mode = WAL"
      yield db
    end
  end

  # Create tables if they don't exist
  def self.setup!
    open do |db|
      db.exec <<-SQL
        CREATE TABLE IF NOT EXISTS recipes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          ingredients TEXT NOT NULL,
          instructions TEXT NOT NULL,
          category TEXT NOT NULL DEFAULT 'Uncategorized',
          servings INTEGER,
          prep_minutes INTEGER,
          cook_minutes INTEGER,
          difficulty TEXT NOT NULL DEFAULT 'medium'
            CHECK(difficulty IN ('easy', 'medium', 'hard')),
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
      SQL
    end
  end

  # Seed sample recipes if the database is empty (idempotent)
  def self.seed!
    return if count > 0

    recipes = [
      {
        name: "Classic Margherita Pizza",
        description: "A timeless Neapolitan pizza with San Marzano tomatoes, fresh mozzarella, and basil — simple ingredients, extraordinary flavor.",
        ingredients: "2 cups bread flour\n1 tsp active dry yeast\n1 tsp salt\n¾ cup warm water\n1 tbsp olive oil\n½ cup San Marzano tomato sauce\n8 oz fresh mozzarella, sliced\n10 fresh basil leaves\n1 tbsp extra virgin olive oil\nPinch of sea salt",
        instructions: "Dissolve yeast in warm water and let sit for 5 minutes until foamy.\nCombine flour and salt, then add yeast mixture and olive oil. Knead for 8 minutes until smooth.\nCover dough and let rise in a warm spot for 1 hour or until doubled.\nPreheat oven to 500°F (260°C) with a pizza stone or inverted baking sheet inside.\nStretch dough into a 12-inch round on floured parchment paper.\nSpread tomato sauce evenly, leaving a 1-inch border. Arrange mozzarella slices on top.\nSlide pizza onto the hot stone and bake for 8–10 minutes until crust is golden and cheese bubbles.\nRemove from oven, scatter fresh basil, drizzle with olive oil, and sprinkle sea salt. Slice and serve immediately.",
        category: "Italian",
        servings: 4,
        prep_minutes: 90,
        cook_minutes: 10,
        difficulty: "medium",
      },
      {
        name: "Spaghetti Carbonara",
        description: "Rome's iconic pasta — silky egg-and-cheese sauce clinging to al dente spaghetti, studded with crispy guanciale and cracked black pepper.",
        ingredients: "1 lb dry spaghetti\n6 oz guanciale, diced\n4 large egg yolks\n2 large whole eggs\n1½ cups finely grated Pecorino Romano\n2 tsp freshly cracked black pepper\nSalt for pasta water",
        instructions: "Bring a large pot of salted water to a boil. Cook spaghetti 1 minute less than package directions.\nWhile pasta cooks, render guanciale in a cold skillet over medium heat until crispy and golden, about 8–10 minutes. Remove from heat.\nIn a bowl, whisk together egg yolks, whole eggs, Pecorino Romano, and black pepper until smooth.\nReserve 1 cup of pasta water, then drain the spaghetti.\nOff heat, toss spaghetti with guanciale and its rendered fat. Let cool for 30 seconds so eggs don't scramble.\nPour egg mixture over pasta and toss vigorously, adding splashes of reserved pasta water until the sauce is creamy and coats every strand.\nPlate immediately, topping with extra Pecorino and a final crack of black pepper.",
        category: "Italian",
        servings: 4,
        prep_minutes: 10,
        cook_minutes: 20,
        difficulty: "medium",
      },
      {
        name: "Chicken Tikka Masala",
        description: "Tender marinated chicken pieces simmered in a spiced tomato-cream sauce — Britain's beloved curry, rich with garam masala and fenugreek.",
        ingredients: "1½ lb boneless chicken thighs, cubed\n1 cup plain yogurt\n2 tbsp garam masala, divided\n1 tsp turmeric\n2 tsp ground cumin\n2 tsp ground coriander\n1 tsp Kashmiri chili powder\n3 tbsp ghee or butter\n1 large onion, finely diced\n4 garlic cloves, minced\n2-inch piece ginger, grated\n1½ cups tomato puree\n1 cup heavy cream\n1 tsp dried fenugreek leaves (kasuri methi)\nFresh cilantro for garnish\nSteamed basmati rice to serve",
        instructions: "Combine yogurt, 1 tbsp garam masala, turmeric, cumin, coriander, and chili powder. Add chicken, coat well, and marinate at least 2 hours (overnight is best).\nThread chicken onto skewers and broil on high for 12–15 minutes, turning once, until charred at edges. Set aside.\nMelt ghee in a large pan over medium heat. Sauté onion until deeply golden, about 10 minutes.\nAdd garlic and ginger, cook 1 minute until fragrant.\nStir in remaining garam masala, then add tomato puree. Simmer for 15 minutes, stirring occasionally, until thickened.\nPour in cream and crushed fenugreek leaves. Simmer 5 minutes more.\nAdd broiled chicken pieces and any juices. Simmer 5–8 minutes until chicken is cooked through and sauce is velvety.\nSeason with salt, garnish with cilantro, and serve over steamed basmati rice.",
        category: "Asian",
        servings: 4,
        prep_minutes: 30,
        cook_minutes: 40,
        difficulty: "medium",
      },
      {
        name: "Beef Tacos",
        description: "Quick weeknight beef tacos with seasoned ground beef, fresh pico de gallo, and creamy avocado — ready in under 30 minutes.",
        ingredients: "1 lb ground beef\n1 tbsp chili powder\n1 tsp ground cumin\n1 tsp smoked paprika\n½ tsp garlic powder\n½ tsp onion powder\n¼ tsp cayenne pepper\nSalt to taste\n8 small corn tortillas\n1 cup diced tomatoes\n½ cup diced white onion\n¼ cup chopped cilantro\n1 lime, juiced\n1 avocado, sliced\n½ cup crumbled cotija cheese\nHot sauce to taste",
        instructions: "Brown ground beef in a large skillet over medium-high heat, breaking it up as it cooks, about 6–8 minutes. Drain excess fat.\nAdd chili powder, cumin, paprika, garlic powder, onion powder, cayenne, and salt. Stir and cook 2 more minutes.\nMake quick pico: combine diced tomatoes, onion, cilantro, and lime juice in a bowl. Season with a pinch of salt.\nWarm tortillas in a dry skillet for 30 seconds per side until pliable and lightly charred.\nAssemble tacos: spoon beef onto each tortilla, top with pico de gallo, avocado slices, and crumbled cotija.\nServe with hot sauce and extra lime wedges on the side.",
        category: "Mexican",
        servings: 4,
        prep_minutes: 10,
        cook_minutes: 15,
        difficulty: "easy",
      },
      {
        name: "Guacamole",
        description: "Chunky, fresh guacamole with ripe avocados, lime, and a kick of jalapeño — the essential Mexican dip that never disappoints.",
        ingredients: "3 ripe Hass avocados\n1 small white onion, finely diced\n2 Roma tomatoes, seeded and diced\n1 jalapeño, minced (seeds removed for mild)\n⅓ cup chopped cilantro\nJuice of 2 limes\n½ tsp kosher salt\n1 garlic clove, minced (optional)",
        instructions: "Halve avocados, remove pits, and scoop flesh into a large bowl.\nAdd lime juice and salt. Mash with a fork to desired consistency — leave some chunks for texture.\nFold in diced onion, tomatoes, jalapeño, cilantro, and garlic if using.\nTaste and adjust salt and lime juice. A little extra lime keeps it bright.\nServe immediately with warm tortilla chips. Press plastic wrap directly onto the surface if storing to prevent browning.",
        category: "Mexican",
        servings: 6,
        prep_minutes: 15,
        cook_minutes: 0,
        difficulty: "easy",
      },
      {
        name: "Pad Thai",
        description: "Thailand's most famous street-food noodle dish — chewy rice noodles, succulent shrimp, crunchy peanuts, and that unmistakable tamarind tang.",
        ingredients: "8 oz flat rice noodles\n2 tbsp tamarind paste\n3 tbsp fish sauce\n2 tbsp [redacted] sugar (or brown sugar)\n1 tbsp rice vinegar\n3 tbsp vegetable oil\n8 oz large shrimp, peeled\n2 eggs, lightly beaten\n1 cup bean sprouts\n3 green onions, sliced into 2-inch pieces\n¼ cup roasted peanuts, crushed\n1 lime, cut into wedges\nRed chili flakes to taste",
        instructions: "Soak rice noodles in warm water for 20–30 minutes until pliable but not soft. Drain well.\nStir tamarind paste, fish sauce, sugar, and vinegar together until sugar dissolves. Set sauce aside.\nHeat 1 tbsp oil in a wok over high heat. Sear shrimp for 1–2 minutes per side until pink. Remove and set aside.\nAdd remaining oil to wok. Pour in beaten eggs and scramble quickly.\nAdd drained noodles and the prepared sauce. Toss constantly for 2 minutes until noodles absorb the sauce.\nReturn shrimp to wok, add bean sprouts and green onions. Toss for 30 seconds to wilt slightly.\nPlate and top with crushed peanuts, extra bean sprouts, lime wedges, and chili flakes.",
        category: "Asian",
        servings: 3,
        prep_minutes: 25,
        cook_minutes: 10,
        difficulty: "medium",
      },
      {
        name: "Chocolate Lava Cake",
        description: "Individual molten chocolate cakes with a gooey center that flows when you break through the tender shell — pure dessert theater.",
        ingredients: "6 oz high-quality dark chocolate (70%), chopped\n½ cup unsalted butter, cubed\n2 large eggs\n2 large egg yolks\n¼ cup granulated sugar\n2 tbsp all-purpose flour\nPinch of sea salt\nButter and cocoa powder for ramekins\nPowdered sugar and fresh raspberries for serving",
        instructions: "Preheat oven to 425°F (220°C). Butter four 6-oz ramekins and dust with cocoa powder.\nMelt chocolate and butter together in a heatproof bowl over simmering water. Stir until smooth, then let cool slightly.\nIn a separate bowl, whisk eggs, egg yolks, and sugar until thick and pale, about 2 minutes.\nFold chocolate mixture into eggs, then sift flour and salt over the top and fold gently until no streaks remain.\nDivide batter evenly among ramekins. Place on a baking sheet.\nBake for exactly 12 minutes — edges should be firm but centers should jiggle slightly.\nLet rest 30 seconds, then run a knife around the edges and invert onto plates.\nDust with powdered sugar and serve immediately with raspberries.",
        category: "Desserts",
        servings: 4,
        prep_minutes: 15,
        cook_minutes: 12,
        difficulty: "hard",
      },
      {
        name: "Tiramisu",
        description: "Italy's beloved no-bake dessert — espresso-soaked ladyfingers layered with whipped mascarpone cream and a dusting of cocoa.",
        ingredients: "6 large egg yolks\n¾ cup granulated sugar\n1¼ cups mascarpone cheese, room temperature\n2 cups heavy whipping cream\n2 cups strong espresso, cooled\n3 tbsp coffee liqueur (or dark rum)\n40–48 ladyfinger biscuits\n¼ cup unsweetened cocoa powder\n2 oz dark chocolate, shaved",
        instructions: "Whisk egg yolks and sugar in a heatproof bowl over simmering water until pale and thick, about 8 minutes. Remove from heat and let cool.\nBeat mascarpone into the cooled egg mixture until smooth.\nIn a separate bowl, whip heavy cream to stiff peaks. Gently fold into mascarpone mixture in three additions.\nCombine cooled espresso and coffee liqueur in a shallow dish.\nBriefly dip each ladyfinger into espresso mixture (1–2 seconds per side — don't soak) and line the bottom of a 9×13 dish.\nSpread half the mascarpone cream over the ladyfinger layer.\nRepeat with another layer of dipped ladyfingers and remaining cream.\nCover and refrigerate at least 6 hours, preferably overnight.\nBefore serving, dust generously with cocoa powder and scatter shaved chocolate on top.",
        category: "Desserts",
        servings: 8,
        prep_minutes: 30,
        cook_minutes: 0,
        difficulty: "medium",
      },
      {
        name: "Minestrone Soup",
        description: "A hearty Italian vegetable soup loaded with beans, pasta, and seasonal vegetables in a savory tomato broth — nourishing and endlessly adaptable.",
        ingredients: "3 tbsp olive oil\n1 onion, diced\n2 carrots, diced\n2 celery stalks, diced\n3 garlic cloves, minced\n1 zucchini, diced\n1 cup green beans, cut into 1-inch pieces\n1 can (15 oz) cannellini beans, drained\n1 can (15 oz) diced tomatoes\n6 cups vegetable broth\n1 tsp dried oregano\n1 tsp dried basil\n½ tsp dried thyme\n1 bay leaf\n¾ cup small pasta (ditalini or elbows)\n2 cups baby spinach\nSalt and black pepper to taste\nGrated Parmesan for serving",
        instructions: "Heat olive oil in a large pot over medium heat. Sauté onion, carrots, and celery until softened, about 8 minutes.\nAdd garlic and cook 1 minute until fragrant.\nStir in zucchini and green beans, cook 3 minutes.\nAdd cannellini beans, diced tomatoes with their juices, broth, oregano, basil, thyme, and bay leaf. Bring to a boil.\nReduce heat and simmer for 20 minutes, stirring occasionally.\nAdd pasta and cook until al dente, about 8–10 minutes.\nRemove bay leaf. Stir in spinach until wilted, about 1 minute.\nSeason generously with salt and pepper. Ladle into bowls and top with Parmesan.",
        category: "Italian",
        servings: 6,
        prep_minutes: 15,
        cook_minutes: 40,
        difficulty: "easy",
      },
      {
        name: "Chicken Enchiladas",
        description: "Rolled corn tortillas stuffed with seasoned shredded chicken, smothered in red enchilada sauce, and baked under a blanket of melted cheese.",
        ingredients: "1½ lb chicken breasts\n1 tsp cumin\n1 tsp chili powder\n½ tsp garlic powder\nSalt to taste\n2 tbsp vegetable oil\n12 corn tortillas\n2 cups red enchilada sauce\n2 cups shredded Mexican blend cheese\n½ cup sour cream\n¼ cup diced green chilies\n¼ cup sliced black olives\nFresh cilantro and diced red onion for garnish",
        instructions: "Season chicken with cumin, chili powder, garlic powder, and salt. Cook in a skillet with oil over medium heat until done, about 6 minutes per side. Shred with two forks.\nPreheat oven to 375°F (190°C). Spread ½ cup enchilada sauce in a 9×13 baking dish.\nMix shredded chicken with ½ cup enchilada sauce, sour cream, and green chilies.\nWarm tortillas briefly in the microwave so they're pliable. Spoon chicken mixture down the center of each, roll tightly, and place seam-side down in the dish.\nPour remaining enchilada sauce over the rolls. Top with shredded cheese and sliced olives.\nBake for 20–25 minutes until bubbly and cheese is golden.\nGarnish with cilantro and red onion. Serve hot.",
        category: "Mexican",
        servings: 5,
        prep_minutes: 20,
        cook_minutes: 30,
        difficulty: "medium",
      },
      {
        name: "Thai Green Curry",
        description: "Fragrant coconut milk curry with tender chicken, bamboo shoots, and Thai basil — vibrant green from fresh herbs and packed with aromatic heat.",
        ingredients: "1½ lb boneless chicken thighs, sliced\n2 tbsp vegetable oil\n3 tbsp green curry paste\n2 cans (14 oz each) coconut milk\n1 cup bamboo shoots, sliced\n1 red bell pepper, sliced\n1 cup Thai basil leaves\n2 tbsp fish sauce\n1 tbsp [redacted] sugar\n2 kaffir lime leaves, torn\n1 cup jasmine rice\nFresh cilantro and sliced red chili for garnish",
        instructions: "Cook jasmine rice according to package directions. Keep warm.\nHeat oil in a wok or large pan over medium-high heat. Fry green curry paste for 1–2 minutes until intensely fragrant.\nPour in half the coconut milk and simmer until oil separates and glistens on top, about 5 minutes.\nAdd chicken and cook, stirring, until no longer pink on the outside, about 4 minutes.\nPour in remaining coconut milk, bamboo shoots, bell pepper, and kaffir lime leaves. Simmer 10 minutes.\nSeason with fish sauce and [redacted] sugar. Taste — it should be salty, sweet, and spicy in balance.\nRemove from heat and stir in Thai basil until wilted.\nServe over jasmine rice, garnished with cilantro and sliced red chili.",
        category: "Asian",
        servings: 4,
        prep_minutes: 15,
        cook_minutes: 25,
        difficulty: "medium",
      },
      {
        name: "Apple Crumble",
        description: "Warm, cinnamon-spiced apples beneath a buttery, golden oat topping — the quintessential comfort dessert, best served with vanilla ice cream.",
        ingredients: "6 medium Granny Smith apples, peeled and sliced\n½ cup granulated sugar\n1 tbsp lemon juice\n1 tsp ground cinnamon\n¼ tsp ground nutmeg\n1 cup all-purpose flour\n¾ cup rolled oats\n¾ cup packed brown sugar\n½ cup cold unsalted butter, cubed\n½ tsp salt\nVanilla ice cream for serving",
        instructions: "Preheat oven to 375°F (190°C). Butter a 9-inch baking dish.\nToss apple slices with granulated sugar, lemon juice, cinnamon, and nutmeg. Spread evenly in the dish.\nIn a bowl, combine flour, oats, brown sugar, and salt. Cut in cold butter with your fingers or a pastry cutter until the mixture resembles coarse crumbs with pea-sized butter bits.\nSprinkle crumble topping evenly over the apples — don't press it down.\nBake for 40–45 minutes until topping is deeply golden and apple juices bubble up around the edges.\nLet cool for 10 minutes. Serve warm with a generous scoop of vanilla ice cream.",
        category: "Desserts",
        servings: 6,
        prep_minutes: 20,
        cook_minutes: 45,
        difficulty: "easy",
      },
    ]

    open do |db|
      db.transaction do |tx|
        recipes.each do |r|
          tx.connection.exec(
            "INSERT INTO recipes (name, description, ingredients, instructions, category, servings, prep_minutes, cook_minutes, difficulty, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))",
            r[:name], r[:description], r[:ingredients], r[:instructions],
            r[:category], r[:servings], r[:prep_minutes], r[:cook_minutes], r[:difficulty]
          )
        end
      end
      puts "Seeded #{recipes.size} recipes."
    end
  end

  # Count total recipes
  def self.count : Int32
    open do |db|
      db.scalar("SELECT COUNT(*) FROM recipes").as(Int64).to_i32
    end
  end

  # Build a Recipe from a result set row
  private def self.recipe_from_row(rs : DB::ResultSet) : Recipe
    Recipe.new(
      id: rs.read(Int32),
      name: rs.read(String),
      description: rs.read(String?),
      ingredients: rs.read(String),
      instructions: rs.read(String),
      category: rs.read(String),
      servings: rs.read(Int32?),
      prep_minutes: rs.read(Int32?),
      cook_minutes: rs.read(Int32?),
      difficulty: rs.read(String),
      created_at: rs.read(String),
      updated_at: rs.read(String),
    )
  end

  # Fetch all recipes ordered by newest first
  def self.all : Array(Recipe)
    open do |db|
      list = [] of Recipe
      db.query("SELECT id, name, description, ingredients, instructions, category, servings, prep_minutes, cook_minutes, difficulty, created_at, updated_at FROM recipes ORDER BY created_at DESC") do |rs|
        rs.each do
          list << recipe_from_row(rs)
        end
      end
      list
    end
  end

  # Find a recipe by id, or nil
  def self.find(id : Int32) : Recipe?
    open do |db|
      db.query("SELECT id, name, description, ingredients, instructions, category, servings, prep_minutes, cook_minutes, difficulty, created_at, updated_at FROM recipes WHERE id = ?", id) do |rs|
        if rs.move_next
          recipe_from_row(rs)
        end
      end
    end
  end

  # Create a recipe, returning the saved record
  def self.create(
    name : String,
    description : String?,
    ingredients : String,
    instructions : String,
    category : String,
    servings : Int32?,
    prep_minutes : Int32?,
    cook_minutes : Int32?,
    difficulty : String
  ) : Recipe
    open do |db|
      db.exec(
        "INSERT INTO recipes (name, description, ingredients, instructions, category, servings, prep_minutes, cook_minutes, difficulty, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))",
        name, description, ingredients, instructions, category, servings, prep_minutes, cook_minutes, difficulty
      )
      id = db.scalar("SELECT last_insert_rowid()").as(Int64).to_i32
      find(id).not_nil!
    end
  end
end
