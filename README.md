# Microservices Template - Cloud Computing

This project serves as a **base template** for developing microservices in Java with Spring Boot, designed for educational purposes in Cloud Computing courses.

** IMPORTANT:** This is an initial template. Students must complete the functionalities according to the course plan, including:
- **Dockerfiles** (Week 2) - Create Dockerfiles for each microservice
- **Docker Compose** (Week 2) - Create docker-compose.yml to orchestrate all services
- Additional unit tests
- CI/CD pipelines (Week 10)
- And other functionalities as per the course plan

**Note:** Students must implement Dockerfiles and complete `docker-compose.yml` as part of Week 2 (see course materials).

## Project Overview

This is a microservices-based application demonstrating a modern cloud-native architecture. The project consists of four main services:

1. **API Gateway** - Single entry point for all client requests using Spring Cloud Gateway
2. **User Service** - Manages user data and operations
3. **Product Service** - Manages product catalog and inventory
4. **Order Service** - Manages orders with inter-service communication (Kafka + OpenFeign)

## Lab CI/CD Delivery

This repository contains a Java Spring Boot microservices project with GitHub Actions workflows for continuous integration, Docker image publishing, AWS OIDC authentication, Terraform automation, reusable workflows, environment-gated deployment, and release reporting.

### Repository Structure

```text
.
├── .github/workflows/
│   ├── hello.yml              # Basic GitHub Actions context test
│   ├── ci.yml                 # Maven validate, compile and test for product-service
│   ├── image.yml              # Build and push product-service Docker image
│   ├── aws-test.yml           # Test AWS authentication through OIDC
│   ├── terraform.yml          # Terraform plan on PR and apply on main
│   ├── reusable-image.yml     # Reusable Docker build/push workflow
│   └── release.yml            # Tag-based release using the reusable workflow
├── api-gateway/               # Spring Cloud Gateway service
├── user-service/              # User microservice and Dockerfile
├── product-service/           # Product microservice and Dockerfile
├── order-service/             # Order microservice and Dockerfile
├── terraform/                 # AWS infrastructure as code
├── docker-compose.yml
└── pom.xml                    # Maven aggregator POM
```

### Workflow Explanations

- `hello.yml`: runs on every push and can also be started manually. It prints repository, branch, commit and actor information.
- `ci.yml`: runs on pull requests and pushes to `main`. It validates the Maven POM, compiles and runs tests for `product-service`.
- `image.yml`: runs on pushes to `main` and manually. It builds and pushes the `product-service` Docker image to Docker Hub.
- `aws-test.yml`: runs manually and verifies that GitHub Actions can assume the AWS IAM role through OIDC.
- `terraform.yml`: runs `terraform plan` for pull requests that change `terraform/**`; on pushes to `main`, it runs `terraform apply`.
- `reusable-image.yml`: reusable workflow called by other workflows to build and push a service Docker image.
- `release.yml`: runs when a tag matching `v*` is pushed. It builds the release image, waits for production environment approval, writes a job summary and optionally sends a Slack notification.

### Required GitHub Secrets

```text
DOCKERHUB_USERNAME   Docker Hub username used to publish images
DOCKERHUB_TOKEN      Docker Hub personal access token
AWS_ROLE_TO_ASSUME   IAM role ARN used by GitHub Actions OIDC
SLACK_WEBHOOK        Optional Slack incoming webhook for release notifications
```

The AWS role ARN used in this lab follows this format:

```text
arn:aws:iam::893385061704:role/gha-deployer
```

### How to Trigger Workflows

- Push to any branch: triggers `hello.yml`.
- Open or update a pull request: triggers `ci.yml`.
- Push to `main`: triggers `ci.yml`, `image.yml`, and workflows with matching path filters.
- Change files under `terraform/**` in a pull request: triggers a Terraform plan and comments the result on the PR.
- Merge Terraform changes to `main`: triggers Terraform apply.
- Run `AWS OIDC Test` manually from the GitHub Actions tab to test AWS identity.
- Push a release tag such as `v1.0.0` to trigger `release.yml`:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Docker Hub Repositories

Docker images are published using the Docker Hub username stored in `DOCKERHUB_USERNAME`.

Expected image names:

```text
<DOCKERHUB_USERNAME>/product-service:latest
<DOCKERHUB_USERNAME>/product-service:<commit-sha>
<DOCKERHUB_USERNAME>/user-service:<commit-sha>
<DOCKERHUB_USERNAME>/order-service:<commit-sha>
```

Example pull command:

```bash
docker pull <DOCKERHUB_USERNAME>/product-service:latest
```

### Terraform Usage

Terraform files are stored in `terraform/`.

Basic local commands:

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
```

The GitHub Actions workflow runs the same validation steps automatically. On pull requests, it comments the plan output. On `main`, it applies the generated plan automatically, so use it carefully because it can create AWS resources and costs.

### AWS OIDC Setup Summary

GitHub Actions authenticates to AWS without long-lived AWS access keys.

AWS IAM OIDC provider:

```text
URL: https://token.actions.githubusercontent.com
Audience: sts.amazonaws.com
```

IAM role:

```text
Name: gha-deployer
Trusted repository: andresecoferreira/microservices-project-a22304646
Secret name in GitHub: AWS_ROLE_TO_ASSUME
```

The role trust policy allows GitHub Actions jobs from this repository to call `sts:AssumeRoleWithWebIdentity`. The role needs permissions for the AWS services managed by Terraform, such as EC2, VPC, ECR and SQS.

## Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│   API Gateway   │  Port: 8080
│ (Spring Gateway)│
└─────┬───────┬───┬───┘
      │       │   │
      ▼       ▼   ▼
┌──────────┐ ┌──────────────┐ ┌──────────────┐
│   User   │ │   Product   │ │    Order    │
│ Service  │ │   Service   │ │   Service   │
│ Port:    │ │ Port:       │ │ Port:       │
│  8081    │ │  8082       │ │  8083       │
└──────────┘ └──────────────┘ └──────────────┘
      ▲              ▲              │
      │              │              │
      └──────────────┴──────────────┘
              OpenFeign (Sync)
      
      ┌──────────────────────────┐
      │        Kafka             │
      │  (Async Event-Driven)    │
      └──────────────────────────┘
```

## Project Structure

```
microservices-project/
├── api-gateway/          # API Gateway using Spring Cloud Gateway
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/apigateway/
│   │   │   │       ├── ApiGatewayApplication.java
│   │   │   │       └── config/
│   │   │   │           └── GatewayConfig.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
├── user-service/         # User management microservice
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/userservice/
│   │   │   │       ├── UserServiceApplication.java
│   │   │   │       ├── controller/
│   │   │   │       │   ├── UserController.java
│   │   │   │       │   └── GlobalExceptionHandler.java
│   │   │   │       ├── service/
│   │   │   │       │   └── UserService.java
│   │   │   │       ├── repository/
│   │   │   │       │   └── UserRepository.java
│   │   │   │       ├── model/
│   │   │   │       │   └── User.java
│   │   │   │       └── dto/
│   │   │   │           ├── UserRequest.java
│   │   │   │           └── UserResponse.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
├── product-service/      # Product management microservice
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/productservice/
│   │   │   │       ├── ProductServiceApplication.java
│   │   │   │       ├── controller/
│   │   │   │       │   ├── ProductController.java
│   │   │   │       │   └── GlobalExceptionHandler.java
│   │   │   │       ├── service/
│   │   │   │       │   └── ProductService.java
│   │   │   │       ├── repository/
│   │   │   │       │   └── ProductRepository.java
│   │   │   │       ├── model/
│   │   │   │       │   └── Product.java
│   │   │   │       └── dto/
│   │   │   │           ├── ProductRequest.java
│   │   │   │           └── ProductResponse.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
├── order-service/        # Order management microservice (Kafka + OpenFeign)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/orderservice/
│   │   │   │       ├── OrderServiceApplication.java
│   │   │   │       ├── controller/
│   │   │   │       │   ├── OrderController.java
│   │   │   │       │   └── GlobalExceptionHandler.java
│   │   │   │       ├── service/
│   │   │   │       │   └── OrderService.java
│   │   │   │       ├── repository/
│   │   │   │       │   └── OrderRepository.java
│   │   │   │       ├── model/
│   │   │   │       │   ├── Order.java
│   │   │   │       │   ├── OrderItem.java
│   │   │   │       │   └── OrderStatus.java
│   │   │   │       ├── dto/
│   │   │   │       │   ├── OrderRequest.java
│   │   │   │       │   ├── OrderResponse.java
│   │   │   │       │   └── OrderItemRequest.java
│   │   │   │       ├── client/
│   │   │   │       │   ├── UserServiceClient.java (OpenFeign)
│   │   │   │       │   └── ProductServiceClient.java (OpenFeign)
│   │   │   │       ├── event/
│   │   │   │       │   ├── OrderCreatedEvent.java
│   │   │   │       │   └── OrderStatusChangedEvent.java
│   │   │   │       └── config/
│   │   │   │           └── KafkaConfig.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
├── Aulas/                # Course materials and documentation
├── README.md             # This file
└── API_EXAMPLES.md       # API usage examples
```

## Technologies Used

- **Java 21** (LTS) - Programming language
- **Spring Boot 3.4.0** - Application framework (latest stable version)
- **Spring Cloud 2024.0.0** - Latest release train for microservices
- **Spring Cloud Gateway** - API Gateway for routing and load balancing
- **Spring Data JPA** - Data persistence abstraction
- **Spring Kafka** - Asynchronous messaging and event-driven communication
- **OpenFeign** - Declarative HTTP client for synchronous inter-service communication
- **H2 Database** - In-memory database for development
- **Apache Kafka** - Distributed event streaming platform
- **JUnit 5 & Mockito** - Unit testing framework
- **Maven** - Dependency management and build tool
- **Lombok 1.18.34** - Reduces boilerplate code (latest version)
- **Spring Boot Actuator** - Monitoring and health checks
- **Jakarta Validation** - Bean validation framework
- **SpringDoc OpenAPI 2.6.0** - API documentation (Swagger UI)
- **Micrometer & Prometheus** - Metrics collection and observability
## Prerequisites

Before running this project, ensure you have the following installed:

- **Java 21** (LTS) - **Required**
  - Check installation: `java -version`
  - **Important:** This project requires Java 21. Java 25+ may have compatibility issues with Lombok.
  - Download from: [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://openjdk.org/)
  - On macOS, you can install via Homebrew: `brew install openjdk@21`
  - Set JAVA_HOME: `export JAVA_HOME=$(/usr/libexec/java_home -v 21)`
- **Maven 3.8+**
  - Check installation: `mvn -version`
  - Download from: [Apache Maven](https://maven.apache.org/download.cgi)
- **Git**
  - Check installation: `git --version`
  - Download from: [Git](https://git-scm.com/downloads)
- **Docker** (Optional, for running Kafka and services via docker-compose)
  - Check installation: `docker --version`
  - Download from: [Docker](https://www.docker.com/get-started)
- **IDE** (Recommended: IntelliJ IDEA, Eclipse, or VS Code)
  - **Note:** If using IntelliJ IDEA, ensure Lombok plugin is installed and annotation processing is enabled

## How to Run Locally

### Option 1: Run Each Service Separately

Open three separate terminal windows:

**Terminal 1 - User Service:**
```bash
cd user-service
mvn spring-boot:run
```

**Terminal 2 - Product Service:**
```bash
cd product-service
mvn spring-boot:run
```

**Terminal 3 - Order Service:**
```bash
cd order-service
mvn spring-boot:run
```

**Terminal 4 - API Gateway:**
```bash
cd api-gateway
mvn spring-boot:run
```

**Important:** Before starting the services, ensure Kafka is running:
```bash
# Using Docker Compose (recommended)
docker-compose up -d zookeeper kafka

# Or install Kafka locally and start it
```

### Option 2: Build and Run JAR Files

```bash
# Build all services
mvn clean package

# Run User Service
cd user-service
java -jar target/user-service-1.0.0.jar

# Run Product Service (in another terminal)
cd product-service
java -jar target/product-service-1.0.0.jar

# Run API Gateway (in another terminal)
cd api-gateway
java -jar target/api-gateway-1.0.0.jar
```

### Service Endpoints

Once all services are running, they will be available at:

- **API Gateway**: http://localhost:8080
- **User Service**: http://localhost:8081
- **Product Service**: http://localhost:8082
- **Order Service**: http://localhost:8083

**Kafka** should be running on:
- **Kafka Broker**: localhost:9092
- **Zookeeper**: localhost:2181

## API Endpoints

### API Gateway (Port 8080)

All requests should go through the API Gateway:

- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product
- `GET /api/orders` - List all orders
- `GET /api/orders/{id}` - Get order by ID
- `GET /api/orders/user/{userId}` - Get orders by user ID
- `POST /api/orders` - Create new order
- `PUT /api/orders/{id}/status` - Update order status

### User Service (Port 8081)

Direct access to User Service (bypassing gateway):

- `GET /users` - List all users
- `GET /users/{id}` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user

### Product Service (Port 8082)

Direct access to Product Service (bypassing gateway):

- `GET /products` - List all products
- `GET /products/{id}` - Get product by ID
- `POST /products` - Create new product
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product

### Order Service (Port 8083)

Direct access to Order Service (bypassing gateway):

- `GET /orders` - List all orders
- `GET /orders/{id}` - Get order by ID
- `GET /orders/user/{userId}` - Get orders by user ID
- `POST /orders` - Create new order
- `PUT /orders/{id}/status?status={status}` - Update order status

## Running Tests

Execute tests for each service:

```bash
# Set Java 21 (if not default)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Run User Service tests
cd user-service
mvn test

# Run Product Service tests
cd product-service
mvn test

# Run Order Service tests
cd order-service
mvn test

# Run API Gateway tests
cd api-gateway
mvn test

# Run all tests from root
mvn test -pl user-service,product-service,order-service,api-gateway
```

### Test Coverage

The project uses **JaCoCo** for coverage. Each module enforces a minimum line coverage (85% for services, 70% for API Gateway). After running `mvn test`, open the report at `target/site/jacoco/index.html` in each module.

- **User Service**: Controller tests (CRUD + validation + exception handler), Service tests (all branches including email-in-use), GlobalExceptionHandler, Application context
- **Product Service**: Controller tests (CRUD + search + exception handler), Service tests (including null stockQuantity branches), OrderEventConsumer (success, product not found, insufficient stock, multiple items, save failure), GlobalExceptionHandler, Application context
- **Order Service**: Controller tests (create, validation, get by id, exception handler), Service tests (create/get/update, user/product not found, insufficient stock), GlobalExceptionHandler, Order model (addOrderItem, calculateTotal), Application context
- **API Gateway**: Application context (loads GatewayConfig)

All tests use:
- **JUnit 5** for test framework
- **Mockito** for mocking dependencies
- **Spring Boot Test** for integration tests
- **JaCoCo** for coverage reports and minimum coverage checks
- **MockMvc** for controller testing
- **Spring Kafka Test** for Kafka integration testing

### Best Practices Implemented

- ✅ **OpenAPI/Swagger Documentation** - Complete API documentation for all services
- ✅ **Observability** - Prometheus metrics via Actuator
- ✅ **Comprehensive Testing** - Unit and integration tests with high coverage
- ✅ **Error Handling** - Global exception handlers with proper HTTP status codes
- ✅ **Validation** - Jakarta Validation for request validation
- ✅ **Modern Dependencies** - Latest stable versions of all frameworks
- ✅ **API Gateway** - Centralized routing with order service support

## Inter-Service Communication

This project demonstrates two types of inter-service communication:

### 1. Synchronous Communication (OpenFeign)

**Order Service** uses OpenFeign to make synchronous HTTP calls to:
- **User Service** - Validates user existence before creating orders
- **Product Service** - Validates products and fetches product details

**Example Flow:**
```
Order Service → (OpenFeign) → User Service: Validate user
Order Service → (OpenFeign) → Product Service: Validate products & get details
Order Service: Create order
```

### 2. Asynchronous Communication (Kafka)

**Order Service** publishes events to Kafka topics:
- `order-created` - Published when a new order is created
- `order-status-changed` - Published when order status changes

**Product Service** consumes events from Kafka:
- Listens to `order-created` topic to update inventory

**Example Flow:**
```
Order Service: Creates order → Publishes OrderCreatedEvent to Kafka
Product Service: Consumes event → Updates product inventory
```

## Microservice Architecture

Each microservice follows a layered architecture pattern:

```
┌─────────────────────┐
│   Controller Layer  │  REST API endpoints
├─────────────────────┤
│   Service Layer     │  Business logic
├─────────────────────┤
│  Repository Layer   │  Data access
├─────────────────────┤
│    Model Layer      │  Entity/Domain models
└─────────────────────┘
```

### Layer Responsibilities

1. **Controller Layer** - Handles HTTP requests/responses, input validation
2. **Service Layer** - Contains business logic, transaction management
3. **Repository Layer** - Data access abstraction, database operations
4. **Model Layer** - Entity classes representing database tables
5. **DTO Layer** - Data Transfer Objects for API communication

## Course Tasks by Week

### Week 2 - Docker and Dockerfile
- [ ] Create Dockerfile for each microservice
- [ ] Create docker-compose.yml for local orchestration
- [ ] Test execution with Docker Compose
- [ ] Implement multi-stage builds for optimization

### Week 3 - DockerHub
- [ ] Build Docker images
- [ ] Push to DockerHub or institutional repository
- [ ] Pull and execute in another environment
- [ ] Tag images with version numbers

### Week 4 - AWS CLI
- [ ] Configure AWS CLI
- [ ] Create automation scripts
- [ ] Test AWS service interactions

### Week 5 - AWS Networking
- [ ] Create VPC and subnets
- [ ] Configure route tables
- [ ] Set up security groups
- [ ] Configure internet gateway

### Week 6 - EC2
- [ ] Create EC2 instance
- [ ] Manual container deployment on EC2
- [ ] Configure security groups for services
- [ ] Test remote access

### Week 7 - Cloud Databases
- [ ] Replace H2 with AWS RDS
- [ ] Configure remote database connection
- [ ] Update connection strings
- [ ] Test database connectivity

### Week 8-9 - Terraform
- [ ] Create infrastructure with Terraform
- [ ] Modularize Terraform code
- [ ] Implement state management
- [ ] Create reusable modules

### Week 10 - CI/CD
- [ ] Create GitHub Actions pipeline
- [ ] Implement automated deployment
- [ ] Add automated testing
- [ ] Configure deployment environments

### Week 11 - SQS (Event-Driven Architecture)
- [ ] Integrate SQS for messaging
- [ ] Implement event-driven architecture
- [ ] Create message producers and consumers
- [ ] Handle asynchronous communication

### Week 12 - Ansible
- [ ] Create Ansible playbooks
- [ ] Automate configuration management
- [ ] Implement infrastructure provisioning
- [ ] Configure application deployment

## API Usage Examples

See **[API_EXAMPLES.md](API_EXAMPLES.md)** for practical API usage examples with curl commands and request/response samples.

## Important Notes

1. **Java Version**: **This project requires Java 21 (LTS)**. Java 25+ has compatibility issues with Lombok. See [COMPILATION.md](COMPILATION.md) for details.
2. **Database**: Currently uses H2 in-memory database. Should be replaced with AWS RDS in Week 7.
3. **Docker (Week 2)**: 
   - **Students must create Dockerfiles** for each service (user-service, product-service, order-service, api-gateway)
   - **Students must complete docker-compose.yml** in the project root (TODO structure is provided)
   - See `Aulas/Week-02/` for detailed instructions
4. **Tests**: Comprehensive unit tests are included (44+ test methods). All tests pass with Java 21.
5. **CI/CD**: Pipelines must be created by students in Week 10.
6. **Kafka**: Required for Order Service. Students will configure this in docker-compose.yml (Week 2).
7. **Inter-Service Communication**: 
   - **Synchronous**: OpenFeign (Order Service → User/Product Services)
   - **Asynchronous**: Kafka (Order Service publishes events, Product Service consumes)
3. **Tests**: Basic tests are included as examples. Students should expand test coverage.
4. **CI/CD**: Pipelines must be created by students in Week 10.
5. **Configuration**: Service URLs are hardcoded for local development. Will be updated when Docker Compose is implemented.

## Health Checks & Observability

Spring Boot Actuator is configured for health monitoring and observability:

### Health Endpoints
- **User Service**: http://localhost:8081/actuator/health
- **Product Service**: http://localhost:8082/actuator/health
- **Order Service**: http://localhost:8083/actuator/health
- **API Gateway**: http://localhost:8080/actuator/health

### Metrics (Prometheus)
- **User Service**: http://localhost:8081/actuator/prometheus
- **Product Service**: http://localhost:8082/actuator/prometheus
- **Order Service**: http://localhost:8083/actuator/prometheus
- **API Gateway**: http://localhost:8080/actuator/prometheus

### API Documentation (Swagger UI)
- **User Service**: http://localhost:8081/swagger-ui.html
- **Product Service**: http://localhost:8082/swagger-ui.html
- **Order Service**: http://localhost:8083/swagger-ui.html
- **API Gateway**: http://localhost:8080/swagger-ui.html

### OpenAPI JSON
- **User Service**: http://localhost:8081/api-docs
- **Product Service**: http://localhost:8082/api-docs
- **Order Service**: http://localhost:8083/api-docs
- **API Gateway**: http://localhost:8080/api-docs

## Development Guidelines

### Code Style
- Follow Java naming conventions
- Use meaningful variable and method names
- Add Javadoc comments for public methods
- Keep methods focused and single-purpose

### Testing
- Write unit tests for service layer
- Write integration tests for controllers
- Aim for at least 70% code coverage
- Use meaningful test method names

### Error Handling
- Use appropriate HTTP status codes
- Provide meaningful error messages
- Log errors appropriately
- Handle exceptions gracefully

## Running with Docker Compose

**⚠️ IMPORTANT:** Students must complete the `docker-compose.yml` file and create Dockerfiles for each service as part of Week 2 exercises.

Once you've completed `docker-compose.yml` and built images from your Dockerfiles:

```bash
# Start all services (Kafka, Zookeeper, and all microservices)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

**Note:** 
- Make sure Docker is installed and running
- You must create Dockerfiles for each service first (Week 2)
- See `Aulas/Week-02/` for detailed instructions

## Troubleshooting

### Kafka Connection Issues
If services cannot connect to Kafka:
```bash
# Check if Kafka is running
docker ps | grep kafka

# Check Kafka logs
docker-compose logs kafka

# Verify Kafka is accessible
telnet localhost 9092
```

### Port Already in Use
If you get a "port already in use" error:
```bash
# Find process using port
lsof -i :8080  # or 8081, 8082

# Kill process
kill -9 <PID>
```

### Database Connection Issues
- Ensure H2 is properly configured in application.yml
- Check database URL and credentials
- Verify Spring Data JPA is properly configured

### Service Communication Issues
- Verify all services are running
- Check API Gateway routing configuration
- Verify service URLs in GatewayConfig.java

## Contributing

This is an educational template. Students should complete functionalities according to the course plan.

## License

This project is for educational purposes.

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Cloud Gateway Documentation](https://spring.io/projects/spring-cloud-gateway)
- [Spring Data JPA Documentation](https://spring.io/projects/spring-data-jpa)
- [Microservices Patterns](https://microservices.io/patterns/)
- [Course Materials](Aulas/README.md)
