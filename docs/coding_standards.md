# MCP Coding Standards

## Controller Pattern

Controllers should follow this pattern for clean, maintainable code:

```ruby
class ExampleController < ApplicationController
  def action
    return render_bad_request if missing_required_params?
    
    result = perform_action
    
    return render_success(result) if result[:success]
    render_error(result)
  end

  private

  def missing_required_params?
    # Parameter validation logic
  end

  def perform_action
    # Core business logic
  end

  def render_bad_request
    render json: { success: false, error: "Error message" }, 
           status: :bad_request
  end

  def render_success(result)
    render json: result
  end

  def render_error(result)
    render json: result, status: :unprocessable_entity
  end
end
```

### Key Principles:
1. Use early returns to reduce nesting
2. Extract repeated logic into private methods
3. Keep the main action method focused and readable
4. Separate concerns (validation, business logic, rendering)
5. Use consistent response formats
6. Make methods small and single-purpose

### Benefits:
- Improved readability
- Easier testing
- Better maintainability
- Consistent error handling
- Clear separation of concerns

## Testing Standards

### RSpec Usage
We exclusively use RSpec for testing. Minitest and Test::Unit are not allowed in this codebase.

### Test Structure
```ruby
RSpec.describe ClassName, type: :type do
  let(:variable) { setup_value }
  
  before do
    # Setup code
  end

  after do
    # Cleanup code
  end

  describe '#method_name' do
    context 'when condition' do
      it 'does something' do
        # Test code
        expect(result).to be_expected_value
      end
    end
  end
end
```

### Testing Guidelines:
1. Use `describe` for classes and methods
2. Use `context` for different scenarios/conditions
3. Use `let` for variable definitions
4. Use `before`/`after` hooks for setup/cleanup
5. Write descriptive test names
6. Use RSpec's expectation syntax (`expect` instead of `assert`)
7. Group related tests using contexts
8. Use proper test types (`:request`, `:model`, etc.)

### Example Test:
```ruby
RSpec.describe ExampleController, type: :request do
  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new record' do
        expect {
          post example_path, params: valid_params
        }.to change(Example, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error' do
        post example_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

### Why RSpec?
- More expressive syntax
- Better readability
- Rich set of matchers
- Better organization with contexts
- More flexible test structure
- Better support for BDD practices 