# safevote-ci
# SafeVote - Secure Online Voting System

SafeVote is a secure and user-friendly online voting system designed for local community elections. It enables residents to participate in community decision-making processes through a secure and accessible platform.

## Features

- **Secure Voting**: End-to-end encryption for all votes
- **Audit Trail**: Comprehensive logging for transparency
- **Accessible**: Responsive design works on all devices
- **Real-time Results**: Instant tabulation of votes
- **Multi-factor Authentication**: Enhanced security for voters

## System Architecture

```mermaid
graph TD
    A[Frontend - React SPA] -->|HTTPS| B[Backend - Node.js API]
    B -->|TLS| C[(PostgreSQL Database)]
    B --> D[Redis Cache]
    A -->|CDN| E[CloudFront]
    E -->|S3| F[Static Assets]
    G[Voter] -->|Votes Securely| A
```

## CI/CD Pipeline

The CI/CD pipeline is implemented using GitHub Actions and includes the following stages:

1. **Security Scanning**
   - Dependency vulnerability scanning
   - Static code analysis
   - Secrets detection

2. **Infrastructure as Code**
   - Terraform for infrastructure provisioning
   - Environment-specific configurations
   - State management with S3 backend

3. **Deployment**
   - Blue-green deployment strategy
   - Zero-downtime updates
   - Automated rollback on failure

4. **Testing**
   - Unit tests
   - Integration tests
   - End-to-end tests with Robot Framework

5. **Monitoring**
   - Application performance monitoring
   - Error tracking
   - Security alerts

## Prerequisites

- Node.js 18.x
- Python 3.10+
- Terraform 1.4+
- AWS Account with appropriate permissions
- GitHub repository with GitHub Actions enabled

## Setup Instructions

### 1. Repository Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/safevote.git
   cd safevote
   ```

2. Install dependencies:
   ```bash
   # Install backend dependencies
   npm install
   
   # Install frontend dependencies
   cd frontend
   npm install
   ```

### 2. Environment Variables

Create `.env` files for both frontend and backend:

#### Backend (`.env`):
```env
NODE_ENV=production
PORT=15550
DATABASE_URL=postgresql://user:password@localhost:5432/safevote
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_jwt_secret
ENCRYPTION_KEY=your_encryption_key
```

#### Frontend (`.env`):
```env
REACT_APP_API_URL=https://api.yourdomain.com
REACT_APP_ENV=production
```

### 3. Infrastructure Deployment

1. Initialize Terraform:
   ```bash
   cd infra
   terraform init -backend-config="bucket=your-terraform-state-bucket"
   ```

2. Plan and apply infrastructure:
   ```bash
   terraform plan -var="environment=staging"
   terraform apply -var="environment=staging"
   ```

### 4. CI/CD Configuration

1. Set up the following GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `SLACK_WEBHOOK_URL` (for notifications)
   - `DATABASE_URL` (production)
   - `JWT_SECRET`
   - `ENCRYPTION_KEY`

2. Set up the following GitHub Variables:
   - `AWS_REGION`
   - `S3_BUCKET`
   - `TF_BACKEND_BUCKET`
   - `SUT_IP_ADDRESS`

## Development

### Running Locally

1. Start the development server:
   ```bash
   # Start backend
   npm run dev
   
   # In a new terminal
   cd frontend
   npm start
   ```

2. Access the application at `http://localhost:3000`

### Testing

Run the test suite:

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e
```

## Deployment

### Manual Deployment

1. Push to the `main` branch to trigger the CI/CD pipeline
2. Or manually trigger the workflow from GitHub Actions

### Rollback

To rollback to a previous version:

1. Navigate to GitHub Actions
2. Select the successful workflow run you want to rollback to
3. Click "Re-run jobs" and select "Rollback"

## Monitoring and Logging

- **Application Logs**: View in CloudWatch
- **Performance Metrics**: Monitor with AWS CloudWatch Metrics
- **Error Tracking**: Configured with Sentry
- **Security Monitoring**: AWS GuardDuty and Security Hub

## Security

- All data is encrypted at rest and in transit
- Regular security audits and dependency updates
- Rate limiting and DDoS protection
- Secure secret management with AWS Secrets Manager

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue in the GitHub repository.

## Acknowledgements

- [React](https://reactjs.org/)
- [Node.js](https://nodejs.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Terraform](https://www.terraform.io/)
- [GitHub Actions](https://github.com/features/actions)

---

<div align="center">
  <p>Made with ❤️ by the SafeVote Team</p>
  <p>Last updated: November 2025</p>
</div>
