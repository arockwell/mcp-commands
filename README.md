# MCP Commands

A Ruby on Rails application that provides a Microservice Command Protocol (MCP) server with file operation commands.

## Features

- File concatenation command
- RESTful API interface
- Comprehensive test coverage using RSpec and FakeFS

## Getting Started

### Prerequisites

- Ruby (version specified in .ruby-version)
- Rails
- Bundler

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mcp-commands.git
cd mcp-commands
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create db:migrate
```

### Running the Server

Start the Rails server:
```bash
rails server
```

## API Documentation

### Concatenate Files

Concatenates multiple files into a single output file.

**Endpoint:** `POST /mcp/concatenate`

**Request Body:**
```json
{
  "files": ["/path/to/file1.txt", "/path/to/file2.txt"],
  "output_path": "/path/to/output.txt"
}
```

**Response:**
```json
{
  "success": true,
  "output_path": "/path/to/output.txt"
}
```

## Testing

Run the test suite:
```bash
bundle exec rspec
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
