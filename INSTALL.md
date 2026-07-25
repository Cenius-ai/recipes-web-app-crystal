# Installation Guide

## 1. Prerequisites

- Crystal 1.x
- Shards (Crystal’s dependency manager)

## 2. Get the Code

Clone the project repository to your local machine.

```bash
git clone <repository-url>
cd recipes-web-app
```

## 3. Install Dependencies

Run `install.sh` or execute the shard command directly:

```bash
shards install
```

## 4. Environment Variables

Copy the example environment file and adjust as needed:

```bash
cp .env.example .env
```

The only configurable variable is:
- `PORT` – HTTP server port (default `3000`).

## 5. Database Setup

An SQLite database file (`recipes.db`) will be created automatically in the project root when the application first starts. No manual migrations are required.

## 6. Development Run

Start the server with:

```bash
crystal run src
```

This binds to `0.0.0.0:3000`.

## 7. Production Build

Compile an optimised binary:

```bash
shards build
```

The executable is placed in `bin/app`.

## 8. Testing

Tests are located in the `spec/` directory and can be executed with:

```bash
crystal spec
```

## 9. Troubleshooting

- **Crystal not found**: Ensure Crystal 1.x is installed and in your `PATH`.
- **Shards install fails**: Verify your internet connection and that `shard.yml` is valid.
- **Port already in use**: Change the `PORT` environment variable or stop the other process occupying port 3000.
- **Database errors**: Delete `recipes.db` if it becomes corrupted; it will be recreated empty on next run.