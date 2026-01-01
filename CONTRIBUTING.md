# Contributing to Jenkins Docker Agent

Thank you for considering contributing to this project! 🎉

## How to Contribute

### Reporting Issues
- Use the GitHub issue tracker
- Describe the issue clearly
- Include steps to reproduce
- Mention your environment (OS, Docker version, etc.)

### Suggesting Enhancements
- Open an issue with the "enhancement" label
- Describe the feature and its benefits
- Provide examples if possible

### Pull Requests

1. **Fork the Repository**
   ```bash
   git clone https://github.com/eddiegaeta/jenkins_docker_agent.git
   cd jenkins_docker_agent
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow the existing code style
   - Update documentation as needed
   - Test your changes

4. **Test the Build**
   ```bash
   ./build.sh test your-username
   docker run --rm your-username/jenkins-docker-agent:test bash -c "
       docker --version &&
       kubectl version --client &&
       helm version
   "
   ```

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```
   
   Use conventional commit format:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation
   - `chore:` for maintenance
   - `refactor:` for code refactoring

6. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then open a Pull Request on GitHub

## Adding New Tools

When adding new tools to the Dockerfile:

1. Add installation steps in the appropriate section
2. Add version check in the verification section
3. Update the README.md tools list
4. Update CHANGELOG.md
5. Test the build

Example:
```dockerfile
# Install new-tool
RUN wget https://example.com/new-tool && \
    install -o root -g root -m 0755 new-tool /usr/local/bin/new-tool && \
    rm new-tool

# In verification section
RUN new-tool --version
```

## Code Review Process

- All PRs require review
- Changes must pass build tests
- Documentation must be updated
- Keep PRs focused and atomic

## Questions?

Open an issue or start a discussion on GitHub.

Thank you for contributing! 🙏
