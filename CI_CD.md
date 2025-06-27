# CI/CD Pipeline

This project includes a comprehensive CI/CD pipeline using GitHub Actions for automated testing, security scanning, and deployment.

## 🔄 CI/CD Pipeline Overview

### Continuous Integration (CI)

- Runs on every push to `main` and `develop` branches
- Executes tests, linting, and security checks
- Builds and tests Docker images
- Generates code coverage reports

### Continuous Deployment (CD)

- **Development**: Auto-deploys on push to `develop` branch
- **Production**: Deploys on tag push (e.g., `v1.0.0`)

## 📋 Workflow Files

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` and `develop` branches
- Pull requests to `main` and `develop` branches

**Jobs:**

#### Test Job
- **Environment:** Ubuntu with PHP 8.4, Node.js 22, Redis
- **Database:** SQLite in-memory
- **Steps:**
  - Setup PHP 8.4 with extensions
  - Setup Node.js 22
  - Install Composer and NPM dependencies
  - Run database migrations
  - Build assets with Vite
  - Execute Pest tests with coverage
  - Upload coverage to Codecov

#### Lint Job
- **Environment:** Ubuntu with PHP 8.4
- **Steps:**
  - Install Composer dependencies
  - Run PHP CS Fixer
  - Run PHPStan static analysis
  - Run Psalm static analysis (if configured)

#### Security Job
- **Environment:** Ubuntu with PHP 8.4
- **Steps:**
  - Run Composer security audit
  - Run PHP security checker
  - Run PHP CS Fixer security rules
  - Run PHPStan security analysis
  - Upload security report

#### Docker Build Job
- **Dependencies:** test, lint, security jobs
- **Steps:**
  - Build Laravel application Docker image
  - Build Nginx Docker image
  - Test Docker images
  - Test Laravel application in container

#### Dependency Scan Job
- **Environment:** Ubuntu with Node.js 22
- **Steps:**
  - Install NPM dependencies
  - Run NPM audit for security vulnerabilities
  - Continue on error to prevent workflow failures

### 2. Security Scan Workflow (`.github/workflows/security.yml`)

**Triggers:**
- Scheduled: Every Monday at 2 AM
- Push to `main` and `develop` branches
- Pull requests to `main` and `develop` branches

**Permissions:**
- `security-events: write`
- `actions: read`
- `contents: read`

**Jobs:**

#### Security Scan Job
- **Environment:** Ubuntu with PHP 8.4
- **Steps:**
  - Install Composer dependencies
  - Run Composer security audit
  - Run PHP security checker
  - Run PHP CS Fixer security rules
  - Run PHPStan security analysis (Level 8)
  - Run Psalm security analysis
  - Upload security report

#### Container Scan Job
- **Environment:** Ubuntu
- **Steps:**
  - Setup Docker Buildx
  - Build Docker image
  - Run Trivy vulnerability scanner
  - Upload scan results as artifact

#### Code Scan Job
- **Environment:** Ubuntu
- **Steps:**
  - Run basic code analysis
  - Check for dangerous functions (eval, exec, shell_exec)
  - Generate security report

### 3. Container Scan Workflow (`.github/workflows/container-scan.yml`)

**Triggers:**
- Push to `main` and `develop` branches
- Pull requests to `main` and `develop` branches

**Jobs:**

#### Container Vulnerability Scan
- **Environment:** Ubuntu
- **Steps:**
  - Setup Docker Buildx
  - Build Docker image
  - Run Trivy vulnerability scanner
  - Upload results to GitHub Security tab

### 4. Code Scan Workflow (`.github/workflows/code-scan.yml`)

**Triggers:**
- Push to `main` and `develop` branches
- Pull requests to `main` and `develop` branches

**Jobs:**

#### CodeQL Analysis
- **Environment:** Ubuntu
- **Steps:**
  - Initialize CodeQL
  - Autobuild project
  - Perform CodeQL analysis
  - Upload results to GitHub Security tab

### 5. CD Workflow (`.github/workflows/cd.yml`)

**Triggers:**
- Push tags (e.g., `v1.0.0`)

**Jobs:**

#### Deploy to Production
- **Environment:** Ubuntu
- **Steps:**
  - Setup kubectl
  - Deploy to production using Helm
  - Run health checks
  - Notify deployment status

## 🔒 Security Features

### Automated Security Scanning

1. **Dependency Scanning**
   - Composer audit for PHP dependencies
   - NPM audit for JavaScript dependencies
   - Automated vulnerability detection

2. **Container Security**
   - Trivy vulnerability scanner
   - Base image security analysis
   - Runtime security checks

3. **Code Security**
   - PHPStan security analysis
   - Psalm security analysis
   - CodeQL static analysis
   - Basic security function detection

4. **Infrastructure Security**
   - Kubernetes security policies
   - Network policies
   - Security contexts

## 📊 Monitoring & Reporting

### Code Coverage
- Pest test coverage reports
- Codecov integration
- Coverage thresholds enforcement

### Security Reports
- Automated security artifact generation
- GitHub Security tab integration
- Vulnerability tracking

### Build Status
- GitHub Actions status badges
- Deployment notifications
- Error reporting and alerting

## 🛠️ Configuration

### Environment Variables

Required secrets for CI/CD:

```bash
# Kubernetes
KUBECONFIG_PROD
KUBECONFIG_STAGING

# Security
SNYK_TOKEN (optional)

# Notifications
SLACK_WEBHOOK (optional)
DISCORD_WEBHOOK (optional)
```

### Workflow Configuration

Each workflow can be customized via:

- **Matrix builds** for multiple PHP/Node.js versions
- **Conditional jobs** based on file changes
- **Parallel execution** for faster builds
- **Caching** for dependencies and build artifacts

## 🚀 Best Practices

### Performance Optimization

1. **Dependency Caching**
   - Composer cache
   - NPM cache
   - Docker layer caching

2. **Parallel Execution**
   - Independent jobs run in parallel
   - Matrix builds for multiple environments
   - Optimized job dependencies

3. **Resource Management**
   - Appropriate runner sizes
   - Timeout configurations
   - Memory limits

### Security Best Practices

1. **Secrets Management**
   - Use GitHub Secrets for sensitive data
   - Rotate secrets regularly
   - Minimal permissions principle

2. **Vulnerability Scanning**
   - Regular dependency updates
   - Automated security scanning
   - Quick vulnerability response

3. **Access Control**
   - Branch protection rules
   - Required status checks
   - Code review requirements

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Laravel Testing Guide](https://laravel.com/docs/testing)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Helm Security](https://helm.sh/docs/topics/security/) 