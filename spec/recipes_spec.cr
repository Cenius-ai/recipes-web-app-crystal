require "spec"
require "../src/db"

describe Recipe do
  describe "default initialization" do
    it "sets sensible defaults" do
      r = Recipe.new
      r.id.should eq 0
      r.name.should eq ""
      r.description.should be_nil
      r.ingredients.should eq ""
      r.instructions.should eq ""
      r.category.should eq "Uncategorized"
      r.difficulty.should eq "medium"
      r.created_at.should eq ""
      r.updated_at.should eq ""
    end

    it "has nil optional numeric fields" do
      r = Recipe.new
      r.servings.should be_nil
      r.prep_minutes.should be_nil
      r.cook_minutes.should be_nil
    end
  end

  describe "named-argument construction" do
    it "accepts all fields" do
      r = Recipe.new(
        id: 1,
        name: "Banana Bread",
        description: "Moist and delicious",
        ingredients: "bananas\nflour\nsugar",
        instructions: "Mash bananas.\nMix with flour.\nBake.",
        category: "Desserts",
        servings: 8,
        prep_minutes: 15,
        cook_minutes: 60,
        difficulty: "easy",
        created_at: "2025-01-01",
        updated_at: "2025-01-01",
      )
      r.id.should eq 1
      r.name.should eq "Banana Bread"
      r.description.should eq "Moist and delicious"
      r.ingredients.should eq "bananas\nflour\nsugar"
      r.instructions.should eq "Mash bananas.\nMix with flour.\nBake."
      r.category.should eq "Desserts"
      r.servings.should eq 8
      r.prep_minutes.should eq 15
      r.cook_minutes.should eq 60
      r.difficulty.should eq "easy"
    end

    it "allows nil description" do
      r = Recipe.new(name: "Plain Pasta", ingredients: "pasta", instructions: "boil")
      r.description.should be_nil
    end
  end

  describe "property mutation" do
    it "allows updating name" do
      r = Recipe.new
      r.name = "Updated Name"
      r.name.should eq "Updated Name"
    end

    it "allows updating difficulty" do
      r = Recipe.new
      r.difficulty = "hard"
      r.difficulty.should eq "hard"
    end
  end
end

describe RecipeDB do
  before_each do
    RecipeDB.setup!
    RecipeDB.seed!
  end

  it "count returns an Int32" do
    typeof(RecipeDB.count).should eq Int32
  end

  it "all returns an Array of Recipe with seeded rows" do
    list = RecipeDB.all
    list.should be_a(Array(Recipe))
    list.size.should be >= 12
  end

  it "find returns a Recipe for a valid id" do
    r = RecipeDB.find(1)
    r.should be_a(Recipe)
    r.not_nil!.name.should_not eq ""
  end

  it "find returns nil for nonexistent id" do
    RecipeDB.find(99999).should be_nil
  end

  it "create adds a new recipe and returns it" do
    r = RecipeDB.create(
      name: "Spec Test Pasta",
      description: "A spec-created recipe",
      ingredients: "pasta\nsauce",
      instructions: "Boil.\nServe.",
      category: "Italian",
      servings: 2,
      prep_minutes: 5,
      cook_minutes: 15,
      difficulty: "easy",
    )
    r.should be_a(Recipe)
    r.name.should eq "Spec Test Pasta"
    r.id.should be > 0
  end
end
