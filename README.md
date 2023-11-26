# 📈 Monolith vs. Microservices Power Consumption Comparison

This project contains both a monolith and micro-services version of the Ticket Monster application (forked from [ticket-monster-msa](https://github.com/ticket-monster-msa/monolith)), and is used to compare the power consumption of the two architectures.

## 🏗️ Project structure

The project is broken up into two parts: the monolith and the microservices. The monolith is located in the `monolith` folder, and the microservices are broken up between three folders:

- `tm-ui-v2` The UI for the microservices
- `backend-v2` The backend for the microservices
- `orders-service` The orders service for the microservices

## 🥅 Goal

The goal of this project is to compare the power consumption of the monolith and microservice architectures, using a bash script that utilises the [Docker Stats API](https://docs.docker.com/engine/api/v1.40/#operation/ContainerStats) to monitor the CPU usage of each running container, and subsequently to calculate the power consumption..

## ✅ Getting started

Two run either the monolith or the microservices, you will need to have Docker installed on your system. Various bash scripts have been created to `start`, `monitor` and `shutdown` both services.

### 💻 Available commands

- `./benchmark.sh --duration <duration> --iterations <iterations>` Runs the entire experiment for the specified duration (in seconds) and number of iterations. The results are saved in the `output` folder.

- `./startup.sh  [--monolith | --microservice | --all]` Starts either the monolith or microservices

- `./monitor.sh [--monolith | --microservice] <duration (optional, defaults to 10s)> [--iterations <number of iterations (optional, defaults to 1)>]` Monitors the specified service for the specified number of iterations, and a specified duration (in seconds). The results are saved in the `output` folder

- `./shutdown.sh` Shuts down any running services

### Useful commands for Dmon System

Using the `v1dmon` system, the following commands are useful:

- `go run dmon.go -i en0 -n bridge0 -f structure`
- `flow -f workflows/workflow.yml -o output`
- `./read_log.sh -f path_to_file.log` to see a cleaned up output of CPU usage by container

### Selenium Commands

Recently added selenium script can be run through instructed to navigate and perfrom actions on the website based on a yaml script. Can be run using the following command:

`python3 web_crawler.py microservice-config.yaml`

> Make sure you have the dependencies installed first `pip install -r dependencies.txt`

### State Diagram

```mermaid
stateDiagram-v2
    direction LR
    state if_more_iterations <<choice>>

    check_prerequisite: Check Prereqsuities
    install_dependencies: Install Dependencies
    commence_monolith: Commence Monolith
    commence_microservice: Commence Microservices
    test_frontend_time: Test Frontend Time
    test_backend_time: Test Backend Time

    start_containers: Start Containers
    shutdown_containers: Shutdown Containers
    monitor_start_containers: Start Containers
    monitor_shutdown_containers: Shutdown Containers

    baseline_monitor_api: Baseline Monitor API
    monitor_api: Monitor API
    baseline_monitor_frontend: Baseline Monitor Frontend
    monitor_frontend: Monitor Frontend
    more_iterations: More Iterations?

    sleep1: Sleep
    sleep2: Sleep
    sleep3: Sleep
    sleep4: Sleep


    [*] --> check_prerequisite
    check_prerequisite --> install_dependencies
    install_dependencies --> commence_monolith
    install_dependencies --> commence_microservice
    commence_monolith --> MonitorSetup
    commence_microservice --> MonitorSetup

    state MonitorSetup {
        [*] --> start_containers
        start_containers --> test_frontend_time
        test_frontend_time --> test_backend_time
        test_backend_time --> shutdown_containers
        shutdown_containers --> [*]
    }

    MonitorSetup --> Monitor

    state Monitor {
        [*] --> monitor_start_containers
        monitor_start_containers --> sleep1
        sleep1 --> baseline_monitor_api
        baseline_monitor_api --> sleep2
        sleep2 --> monitor_api
        monitor_api --> sleep3
        sleep3 --> baseline_monitor_frontend
        baseline_monitor_frontend --> sleep4
        sleep4 --> monitor_frontend
        monitor_frontend --> monitor_shutdown_containers
        monitor_shutdown_containers --> more_iterations
        more_iterations --> if_more_iterations
        if_more_iterations --> monitor_start_containers: yes
        if_more_iterations --> [*]: no
    }
```

# UML Sequence Diagrams

## Scenario 1

```mermaid
sequenceDiagram
    title Scenario 1 - Light User Load Monolith

    User->Monolithic Application: Browse Tickets
    Monolithic Application->Database: Fetch Data
    Database-->Monolithic Application: Data
    Monolithic Application-->User: Data
```

```mermaid
sequenceDiagram
    title Scenario 1 - Light User Load Microservice
    User->Frontend: Browse Tickets
    Frontend->Orders Service: Request Tickets
    Orders Service->Backend: Get Ticket Data
    Backend->Database: Fetch Data
    Database-->Backend: Data
    Backend-->Orders Service: Data
    Orders Service-->Frontend: Data
    Frontend-->User: Data
```

## Scenario 2

```mermaid
sequenceDiagram
    title Scenario 2 - Heavy User Load Monolith

    User->Monolithic Application: Purchase Tickets
    Monolithic Application->Database: Process Purchase
    Database-->Monolithic Application: Data
    User->Monolithic Application: Update Information
    Monolithic Application->Database: Update Information
    Database-->Monolithic Application: Updated Information
    Monolithic Application-->User: Response
```

```mermaid
sequenceDiagram
    title Scenario 2 - Heavy User Load Microservice

    User->Frontend: Purchase Tickets
    Frontend->Orders Service: Create Order
    Orders Service->Backend: Process Purchase
    Backend->Database: Update Order
    Database-->Backend: Order Data
    Backend-->Orders Service: Order Data
    Orders Service-->Frontend: Order Confirmation
    Frontend->Frontend: Update Information
    Frontend->Orders Service: Update User Information
    Orders Service->Backend: Update User Info
    Backend->Database: Update User Record
    Database-->Backend: User Data
    Backend-->Orders Service: User Data
    Orders Service-->Frontend: Updated User Info
    Frontend-->User: Response
```

## Scenario 3

```mermaid
sequenceDiagram
    title Scenario 3 - Heavy Admin Load Monolith
    Admin->Monolithic Application: Create Info
    Monolithic Application->Database: Create Record
    Database-->Monolithic Application: Record Created
    Admin->Monolithic Application: Read Info
    Monolithic Application->Database: Read Record
    Database-->Monolithic Application: Record Data
    Admin->Monolithic Application: Update Info
    Monolithic Application->Database: Update Record
    Database-->Monolithic Application: Record Updated
    Admin->Monolithic Application: Delete Info
    Monolithic Application->Database: Delete Record
    Database-->Monolithic Application: Record Deleted
```

```mermaid
sequenceDiagram
    title Scenario 3 - Heavy Admin Load Microservice
    Admin->Frontend: Create Info
    Frontend->Orders Service: Create Record
    Orders Service->Backend: Create Record
    Backend->Database: Store Record
    Database-->Backend: Record Created
    Backend-->Orders Service: Record Created
    Orders Service-->Frontend: Record Created
    Admin->Frontend: Read Info
    Frontend->Orders Service: Read Record
    Orders Service->Backend: Retrieve Record
    Backend->Database: Fetch Data
    Database-->Backend: Record Data
    Backend-->Orders Service: Record Data
    Orders Service-->Frontend: Record Data
    Admin->Frontend: Update Info
    Frontend->Orders Service: Update Record
    Orders Service->Backend: Update Record
    Backend->Database: Modify Record
    Database-->Backend: Record Updated
    Backend-->Orders Service: Record Updated
    Orders Service-->Frontend: Record Updated
    Admin->Frontend: Delete Info
    Frontend->Orders Service: Delete Record
    Orders Service->Backend: Delete Record
    Backend->Database: Remove Record
    Database-->Backend: Record Deleted
    Backend-->Orders Service: Record Deleted
    Orders Service-->Frontend: Record Deleted
```

## Detailed Sequence Diagram - Scenario 1

```mermaid
sequenceDiagram
    title Scenario 1 - Light User Load Monolith

    participant U as User
    participant Api as API
    participant App as Monolithic Application
    participant DB as Database
    %% participant Sel as Selenium

    U->>App: Browse Tickets
    App->>DB: Fetch Data
    DB-->>App: Data
    App-->>U: Data

    U->>App: Navigate to 'Events'
    App->>DB: Retrieve 'Events' data
    DB-->>App: 'Events' data
    App-->>U: Display 'Events' page

    U->>App: Navigate to 'Concert'
    App->>DB: Retrieve 'Concert' data
    DB-->>App: 'Concert' data
    App-->>U: Display 'Concert' page

    U->>App: Navigate to 'Rock concert of the decade'
    App->>DB: Retrieve 'Rock concert of the decade' data
    DB-->>App: 'Rock concert of the decade' data
    App-->>U: Display 'Rock concert of the decade' page

    U->>App: Provide order details (e.g., email, dropdown, quantity)
    App->>DB: Save order details
    DB-->>App: Confirmation of order details
    App-->>U: Order details processed

    U->>App: Click 'Add tickets'
    App->>DB: Add tickets to the order
    DB-->>App: Ticket added
    App-->>U: Tickets added to the order

    U->>App: Click 'Checkout'
    App->>DB: Process checkout
    DB-->>App: Checkout completed
    App-->>U: Checkout success

    % API Testing Part

    U->>Api: Get Events
    Api->>DB: Retrieve Events
    DB-->>Api: Events data
    Api-->>U: Events retrieved

    U->>Api: Get Event by ID
    Api->>DB: Retrieve Event by ID
    DB-->>Api: Event data
    Api-->>U: Event by ID retrieved

    U->>Api: Get Venues
    Api->>DB: Retrieve Venues
    DB-->>Api: Venues data
    Api-->>U: Venues retrieved

    U->>Api: Get Categories
    Api->>DB: Retrieve Categories
    DB-->>Api: Categories data
    Api-->>U: Categories retrieved

    U->>Api: Get Sections
    Api->>DB: Retrieve Sections
    DB-->>Api: Sections data
    Api-->>U: Sections retrieved

    U->>Api: Get Performances
    Api->>DB: Retrieve Performances
    DB-->>Api: Performances data
    Api-->>U: Performances retrieved
```

```mermaid
sequenceDiagram
    title Scenario 1 - Microservices Architecture

    participant U as User
    participant Frontend as Frontend Service
    participant Backend as Backend Service
    participant Database as Database
    participant Orders as Orders Service
    participant API as API Service

    U->>Frontend: Browse Tickets
    Frontend->>Backend: Request Ticket Information
    Backend->>Database: Fetch Data
    Database-->>Backend: Data
    Backend-->>Frontend: Ticket Information
    Frontend-->>U: Display Ticket Information


    U->>Frontend: Navigate to 'Events'
    Frontend->>Backend: Request Events Data
    Backend->>Database: Fetch Events Data
    Database-->>Backend: Events Data
    Backend-->>Frontend: Events Data
    Frontend-->>U: Display 'Events' page

    U->>Frontend: Navigate to 'Concert'
    Frontend->>Backend: Request Concert Data
    Backend->>Database: Fetch Concert Data
    Database-->>Backend: Concert Data
    Backend-->>Frontend: Concert Data
    Frontend-->>U: Display 'Concert' page

    U->>Frontend: Navigate to 'Rock concert of the decade'
    Frontend->>Backend: Request Rock Concert Data
    Backend->>Database: Fetch Rock Concert Data
    Database-->>Backend: Rock Concert Data
    Backend-->>Frontend: Rock Concert Data
    Frontend-->>U: Display 'Rock concert of the decade' page

    U->>Frontend: Provide order details (e.g., email, dropdown, quantity)
    Frontend->>Backend: Submit Order Details
    Backend->>Orders: Create Order
    Orders->>Database: Save Order Details
    Database-->>Orders: Order Details
    Orders-->>Backend: Order Created
    Backend-->>Frontend: Order Confirmation
    Frontend-->>U: Order Confirmation

    U->>Frontend: Click 'Add tickets'
    Frontend->>Backend: Request Add Tickets
    Backend->>Orders: Add Tickets to Order
    Orders->>Database: Update Order
    Database-->>Orders: Updated Order
    Orders-->>Backend: Tickets Added
    Backend-->>Frontend: Tickets Added
    Frontend-->>U: Tickets Added

    U->>Frontend: Click 'Checkout'
    Frontend->>Backend: Request Checkout
    Backend->>Orders: Process Checkout
    Orders->>Database: Update Order Status
    Database-->>Orders: Updated Order Status
    Orders-->>Backend: Checkout Completed
    Backend-->>Frontend: Checkout Success
    Frontend-->>U: Checkout Success

    % API Testing Part

    U->>API: Get Events
    API->>Backend: Request Events
    Backend->>Database: Fetch Events Data
    Database-->>Backend: Events Data
    Backend-->>API: Events Data
    API-->>U: Events Retrieved

    U->>API: Get Event by ID
    API->>Backend: Request Event by ID
    Backend->>Database: Fetch Event Data by ID
    Database-->>Backend: Event Data
    Backend-->>API: Event Data
    API-->>U: Event by ID Retrieved

    U->>API: Get Venues
    API->>Backend: Request Venues
    Backend->>Database: Fetch Venues Data
    Database-->>Backend: Venues Data
    Backend-->>API: Venues Data
    API-->>U: Venues Retrieved

    U->>API: Get Categories
    API->>Backend: Request Categories
    Backend->>Database: Fetch Categories Data
    Database-->>Backend: Categories Data
    Backend-->>API: Categories Data
    API-->>U: Categories Retrieved

    U->>API: Get Sections
    API->>Backend: Request Sections
    Backend->>Database: Fetch Sections Data
    Database-->>Backend: Sections Data
    Backend-->>API: Sections Data
    API-->>U: Sections Retrieved

    U->>API: Get Performances
    API->>Backend: Request Performances
    Backend->>Database: Fetch Performances Data
    Database-->>Backend: Performances Data
    Backend-->>API: Performances Data
    API-->>U: Performances Retrieved

```

## Some more sequence diagrams

```mermaid
sequenceDiagram
  participant User
  participant Monolith
  participant Database

  User->>Monolith: Purchase Ticket
  Monolith->>Database: Process Purchase
  Database-->>Monolith: Purchase Confirmation
  Monolith-->>User: Display Purchase Confirmation
```

```mermaid
sequenceDiagram
  participant User
  participant Frontend
  participant Backend
  participant OrdersService
  participant Database

  User->>Frontend: Purchase Ticket
  Frontend->>Backend: Send Ticket Purchase Request
  Backend->>OrdersService: Process Order
  OrdersService->>Database: Save Order Information
  Database-->>OrdersService: Order Confirmation
  OrdersService-->>Backend: Purchase Confirmation
  Backend-->>Frontend: Purchase Confirmation
  Frontend-->>User: Display Purchase Confirmation
```

## New Architecture

```mermaid

```
