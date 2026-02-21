# Contributing Guide

Thank you for your interest in contributing to Bashmenu! This document provides guidelines for contributing to the project.

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **Clear description** of the problem
2. **Steps to reproduce** the error
3. **Expected behavior** vs actual behavior
4. **System information**:
   - Bash version
   - Linux distribution
   - Bashmenu version

### Suggesting Enhancements

To suggest new features:

1. Check that a similar issue doesn't exist
2. Clearly describe the proposed functionality
3. Explain why it would be useful
4. Provide usage examples if possible

### Pull Requests

1. **Fork** the repository
2. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/my-new-feature
   ```
3. **Make your changes** following the style guides
4. **Test** your changes thoroughly
5. **Commit** with descriptive messages:
   ```bash
   git commit -m "Add: new feature X"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/my-new-feature
   ```
7. **Open a Pull Request** with detailed description

## 📝 Style Guides

### Bash Code

- Use **4 spaces** for indentation (no tabs)
- Variable names in **UPPERCASE** for globals
- Variable names in **lowercase** for locals
- Use `local` for variables inside functions
- Clear and concise comments
- Validate all user inputs
- Handle errors appropriately

### Function Example

```bash
# Brief function description
my_function() {
    local parameter="$1"
    local result=""
    
    # Validate input
    if [[ -z "$parameter" ]]; then
        print_error "Parameter required"
        return 1
    fi
    
    # Function logic
    result=$(process "$parameter")
    
    # Return result
    echo "$result"
    return 0
}
```

### Commit Messages

Recommended format:

```
Type: Brief description (max 50 characters)

Detailed description if necessary (max 72 characters per line)

- Additional point 1
- Additional point 2
```

Commit types:
- `Add:` - New functionality
- `Fix:` - Bug fix
- `Update:` - Update existing functionality
- `Remove:` - Code removal
- `Docs:` - Documentation changes
- `Refactor:` - Code refactoring
- `Test:` - Adding or modifying tests

## 🧪 Testing

Before submitting a PR:

1. **Test installation**:
   ```bash
   sudo ./install.sh
   ```

2. **Test basic functionality**:
   ```bash
   bashmenu
   ```

3. **Test with different configurations**:
   - Different themes
   - With and without permissions
   - With custom scripts

4. **Verify syntax**:
   ```bash
   bash -n src/*.sh
   ```

## 📚 Documentation

When adding new features:

1. Update **README.md** if necessary
2. Add comments in code
3. Document function parameters
4. Include usage examples

## 🔒 Security

If you find a security vulnerability:

1. **DO NOT** open a public issue
2. Contact the maintainer directly
3. Provide complete details of the problem
4. Wait for confirmation before disclosing

## 📋 PR Checklist

Before submitting your Pull Request, verify:

- [ ] Code follows style guides
- [ ] All files have appropriate headers
- [ ] Functions are documented
- [ ] Tests added if applicable
- [ ] Documentation is updated
- [ ] Commits have descriptive messages
- [ ] Code has been tested locally
- [ ] No conflicts with main branch

## 🎯 Contribution Areas

Areas where help is needed:

- **Documentation**: Improve guides and examples
- **Example Scripts**: Add more useful scripts
- **Themes**: Create new visual themes
- **Tests**: Add test cases
- **Translations**: Translate documentation
- **Optimization**: Improve performance

## 💬 Communication

- **Issues**: For bugs and suggestions
- **Pull Requests**: For code contributions
- **Discussions**: For general questions

## 📜 Code of Conduct

- Be respectful to other contributors
- Accept constructive criticism
- Focus on what's best for the project
- Maintain a collaborative environment

## 🙏 Acknowledgments

All contributions are valued and appreciated. Thank you for helping improve Bashmenu!

---

**Note**: By contributing, you agree that your contributions will be licensed under the project's MIT License.
