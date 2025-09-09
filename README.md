# Teachable Courses

A Ruby on Rails application that interfaces with the Teachable API to display courses and user enrollments.

## Prerequisites

- Ruby 3.3.5
- Rails 8.0.2.1
- SQLite3
- Bundler

## Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd teachable
   ```

2. Install dependencies:

   ```bash
   bundle install
   ```

3. Set up the database:

   ```bash
   rails db:create
   rails db:migrate
   ```

4. Set up environment variables:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and add your Teachable API key:
   ```
   TEACHABLE_API_KEY=your_api_key_here
   ```

## Running the Application

Start the Rails server:

```bash
rails server
```

The application will be available at `http://localhost:3000`.

### Available Routes

- `/` - Home page displaying published courses
- `/courses` - List all published courses
- `/courses/:id` - Show course enrollments for a specific course
- `/courses/fetch_user?user_id=:id` - Fetch user details (AJAX endpoint)

## Testing

This application uses RSpec for testing with SimpleCov for code coverage reporting.

### Running Tests

Run all tests:

```bash
bundle exec rspec
```

Run tests for a specific file:

```bash
bundle exec rspec spec/path/to/spec_file.rb
```

Run tests with verbose output:

```bash
bundle exec rspec --format documentation
```

### Code Coverage

The application is configured with SimpleCov to generate code coverage reports with a minimum requirement of 80% coverage.

After running tests, coverage reports are generated in the `coverage/` directory.

#### Viewing Coverage Reports

Open the coverage report in your browser:

```bash
open coverage/index.html
```

The coverage report includes:

- Overall coverage percentage
- File-by-file coverage breakdown
- Line-by-line coverage visualization
- Separate groupings for Adapters and Controllers

## Project Structure

```
app/
├── adapters/
│   └── teachable/
│       └── api_adapter.rb      # Teachable API integration
├── controllers/
│   └── courses_controller.rb   # Course and user endpoints
└── views/
    └── courses/               # Course-related views

spec/
├── adapters/                  # Adapter tests
├── controllers/               # Controller tests
├── support/
│   └── cassettes/            # VCR cassettes for API mocking
├── spec_helper.rb            # RSpec configuration
└── rails_helper.rb           # Rails-specific test configuration
```

## API Integration

The application integrates with the Teachable API through the `Teachable::ApiAdapter` class, which provides methods for:

- Fetching published courses
- Retrieving course enrollments
- Getting user details
