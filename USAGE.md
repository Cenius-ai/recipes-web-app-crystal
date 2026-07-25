# Usage

## Starting the Server

In the project directory, run:

```bash
crystal run src
```

Alternatively, build the binary first and then execute it:

```bash
shards build
./bin/app
```

The server listens on `http://0.0.0.0:3000` (or the port set in `PORT`).

## Accessing the Application

Open a web browser and navigate to `http://localhost:3000`.

### Recipe List (Home Page)

The root URL (`/`) displays all stored recipes. Click any recipe to view its details.

### Add a Recipe

Go to `http://localhost:3000/recipes/new`. Fill out the form and submit it. The new recipe will appear in the list.

### Recipe Detail

Each recipe in the list links to `/recipes/:id` where `:id` is the numeric identifier. This page shows the full recipe information.

## Curl Examples

You can interact with the app via command line:

```bash
# Fetch the recipe list (HTML)
curl http://localhost:3000/
```

All other endpoints return HTML pages and are intended for browser usage.