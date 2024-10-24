# Deploying Serverless Application on AWS using Terraform

## Description

## Serverless Architecture

Serverless architecture is a cloud computing execution model where the cloud provider dynamically manages the allocation of machine resources. This allows developers to build and deploy applications without worrying about the underlying infrastructure. Instead of provisioning servers and managing the server environment, developers can focus on writing code, while the cloud provider handles the scaling, availability, and fault tolerance of the application.

### Need for Serverless Architecture

1. **Cost Efficiency**: With serverless computing, users are charged based on actual resource consumption, which can lead to significant cost savings, especially for variable workloads.
2. **Scalability**: Serverless applications automatically scale up or down based on demand. This means that during peak usage, more resources are allocated, and during low usage, resources are reduced, allowing for optimal performance without manual intervention.
3. **Reduced Operational Overhead**: Developers can focus on writing code rather than managing servers, which speeds up the development process and enhances productivity.
4. **Faster Time to Market**: Serverless architecture allows for rapid development and deployment, making it easier to launch new features and applications quickly.

### AWS Services Used

1. **Amazon S3 (Simple Storage Service)**:
   - S3 is an object storage service that provides highly scalable, durable, and secure storage. It is used to store static assets like HTML, CSS, JavaScript files, and images for web applications.
   - S3 supports static website hosting, making it an ideal solution for serving web applications.

2. **Amazon CloudFront**:
   - CloudFront is a content delivery network (CDN) service that delivers your content with low latency and high transfer speeds.
   - It caches content at edge locations globally, improving the performance and reliability of serving static and dynamic web content.

3. **Amazon API Gateway**:
   - API Gateway is a managed service that enables developers to create, publish, maintain, monitor, and secure APIs at any scale.
   - It acts as a gateway for serverless applications to expose endpoints for Lambda functions, making it easy to manage and integrate APIs.

4. **AWS Lambda**:
   - AWS Lambda is a serverless compute service that lets you run code in response to events without provisioning or managing servers.
   - It allows you to execute code in response to API calls, changes in data, or system events, providing a highly scalable environment for running backend logic.

5. **Amazon DynamoDB**:
   - DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability.
   - It is designed to handle large amounts of data while ensuring high availability and low latency, making it suitable for serverless applications.

6. **Amazon CloudWatch**:
   - CloudWatch is a monitoring and observability service that provides data and insights into your applications and infrastructure.
   - It allows you to collect and track metrics, monitor log files, and set alarms, helping you gain visibility into your serverless application's performance.

## Project Goals

The goal of this project is to demonstrate how to deploy a serverless application on AWS using Terraform, leveraging the services mentioned above to create a highly scalable, cost-effective, and maintainable architecture.
