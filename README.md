# Smart Parking Management System (SmartPark Pro)

A complete, production-ready, highly secure, and visually stunning Smart Parking Management and Enforcement System built using the **PERN/MERN-equivalent** architecture (Node.js/Express, MySQL, Bootstrap 5, and Vanilla JavaScript).

---

## 1. System Architecture

```mermaid
graph TD
    User[Client Browser / Attendant Portal] -->|HTTP / HTTPS REST APIs| ExpressServer[Express.js API Gateway]
    
    subgraph Security Layer (Middlewares)
        ExpressServer --> CORSMiddleware[CORS Guard]
        CORSMiddleware --> InputSanitizer[Validation & Sanitization]
        InputSanitizer --> JWTAccess[JWT Auth & RBAC Check]
        JWTAccess --> ErrorBoundary[Global Error Boundary]
      end
      
    subgraph Business Logic (Routes & Controllers)
        JWTAccess --> AuthRouter[Auth Router]
        JWTAccess --> CheckinRouter[Vehicle Check-In Router]
        JWTAccess --> CheckoutRouter[Vehicle Check-Out Router]
        JWTAccess --> PaymentRouter[Payment Settle Router]
        JWTAccess --> CRUDRouters[CRUD Operators / Slots / Attendants]
    end

    subgraph Persistence Layer
        AuthRouter --> DB[(MySQL Relational Database)]
        CheckinRouter --> DB
        CheckoutRouter --> DB
        PaymentRouter --> DB
        CRUDRouters --> DB
    end
```

---

## 2. Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    Users ||--o| Parking_Attendants : "has profile details"
    Parking_Areas ||--o{ Parking_Slots : "contains"
    Vehicles ||--o{ Parking_Records : "parks"
    Parking_Slots ||--o{ Parking_Records : "assigned to"
    Users ||--o{ Parking_Records : "recorded check-in by"
    Parking_Records ||--|| Payments : "settled by"

    Users {
        int id PK "Auto Increment"
        string username UNIQUE "Login Username"
        string password_hash "Bcrypt Encrypted"
        string email UNIQUE
        enum role "Admin / Attendant"
        enum status "Active / Inactive"
        timestamp created_at
    }

    Parking_Attendants {
        int id PK "Auto Increment"
        int user_id FK "Users.id"
        string name "Full Name"
        string phone "10-15 digits"
        text address
        date hire_date
        timestamp created_at
    }

    Parking_Areas {
        int id PK "Auto Increment"
        string name UNIQUE
        string location "Physical Block Floor"
        int slot_count "Current slot capacity"
        decimal base_price "Hourly rate (Default ₹20)"
        timestamp created_at
    }

    Parking_Slots {
        int id PK "Auto Increment"
        int area_id FK "Parking_Areas.id"
        string slot_number "Unique in Area"
        enum type "Two-Wheeler / Four-Wheeler / Heavy"
        enum status "Available / Occupied / Maintenance"
        timestamp created_at
    }

    Vehicles {
        int id PK "Auto Increment"
        string license_plate UNIQUE "Uppercase Normalization"
        enum type "Two-Wheeler / Four-Wheeler / Heavy"
        string owner_name "Optional"
        string owner_phone "Optional"
        timestamp created_at
    }

    Parking_Records {
        int id PK "Auto Increment"
        int vehicle_id FK "Vehicles.id"
        int slot_id FK "Parking_Slots.id"
        int attendant_id FK "Users.id"
        timestamp entry_time "Check-in stamp"
        timestamp exit_time "Checkout stamp"
        decimal calculated_fee "Billed hours * Area rate"
        enum status "Active / Completed"
        timestamp created_at
    }

    Payments {
        int id PK "Auto Increment"
        int record_id FK "Parking_Records.id"
        decimal amount "Settled cash amount"
        enum payment_method "Cash / UPI / Card"
        timestamp payment_date "Settlement stamp"
        string transaction_id UNIQUE "Secure references key"
    }
```

---

## 3. Swagger / OpenAPI 3.0 API Documentation

A brief description of key REST API Endpoints exposed by the backend Express server. All routes under `/api/*` (except `/login`) require the headers: `Authorization: Bearer <JWT_TOKEN>`.

### Authentication Endpoints

#### `POST /api/login`
- **Desc**: Authenticate credentials and return standard JWT.
- **Payload**:
  ```json
  { "username": "admin", "password": "admin123" }
  ```
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "token": "eyJhbGciOi...",
    "user": { "username": "admin", "role": "Admin", "name": "System Admin" }
  }
  ```

---

### Dashboard Metrics Endpoints

#### `GET /api/dashboard/stats`
- **Desc**: Retrieve overall system counts and revenue figures for stat cards.
- **Access**: Private (Admin & Attendant)
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "slots": { "total": 30, "available": 26, "occupied": 2, "maintenance": 2 },
      "total_vehicles": 4,
      "active_sessions": 2,
      "revenue": { "today": 80.00, "monthly": 80.00 },
      "recent_transactions": [...]
    }
  }
  ```

---

### Parking Operations Flow

#### `POST /api/entry`
- **Desc**: Create vehicle entry record (Check-In). Slot switches to `Occupied`.
- **Payload**:
  ```json
  {
    "license_plate": "DL3CAN1234",
    "slot_id": 2,
    "type": "Four-Wheeler",
    "owner_name": "John Doe",
    "owner_phone": "9876543210"
  }
  ```

#### `PUT /api/exit`
- **Desc**: Process vehicle checkout. Exit timestamp is recorded, duration computed, slot released to `Available`.
- **Payload**:
  ```json
  { "license_plate": "DL3CAN1234" } // or slot_id / record_id
  ```

#### `POST /api/payment`
- **Desc**: Process billing. Save settled cash transaction and generate a finalized tax invoice.
- **Payload**:
  ```json
  {
    "record_id": 1,
    "amount": 60.00,
    "payment_method": "UPI",
    "transaction_id": "UPI98765432"
  }
  ```

---

### Core CRUD Registries

- **Attendants (Admin Only)**:
  - `GET /api/attendants` — Read all operators.
  - `POST /api/attendants` — Create Operator user credentials and bio details.
  - `PUT /api/attendants/:id` — Update bio details or change password / block access.
  - `DELETE /api/attendants/:id` — Delete Operator User.
- **Areas**:
  - `GET /api/areas` / `POST /api/areas` / `PUT /api/areas/:id` / `DELETE /api/areas/:id`
- **Slots**:
  - `GET /api/slots` / `POST /api/slots` / `PUT /api/slots/:id` / `DELETE /api/slots/:id`
- **Vehicles**:
  - `GET /api/vehicles` / `POST /api/vehicles` / `PUT /api/vehicles/:id` / `DELETE /api/vehicles/:id`
- **Records (Logs)**:
  - `GET /api/records` — Fetch active or historical sessions with license plate filters.

---

## 4. Design & Screenshots Mockup Layouts

The frontend interface utilizes a highly polished, responsive dark-glassmorphism scheme tailored with Bootstrap 5 utility frames and styled with Outfit typography. 

### Page View Guides

1. **Dashboard Interface**: 
   - Displays a grid of statistics cards (Available Slots, Billed Revenue, Active Sessions) topped with a dynamic clock ticker.
   - Hosts a **Live Interactive Slot Grid Map**: Click an `Available` (Green) slot to check-in, or click an `Occupied` (Amber) slot to automatically check out the vehicle!
2. **Check-In Ticket Receipt Console**:
   - Split layout: Form on the left, a **Printable Check-In Ticket Slip** on the right featuring dashed outlines, and barcode simulations.
3. **Checkout Fees Summary**:
   - Displays duration (e.g. `2 hours 15 minutes`) and calculates precise parking fees (rounding up to the next hour based on base block rates).
4. **Billing & Tax Invoice Panel**:
   - Simulates UPI QR or Card Swipes, processes records bookkeeping, and displays the clean tax invoice.

---

## 5. Comprehensive Setup & Installation Guide

### Prerequisites
- Node.js (v18.0.0 or higher recommended)
- MySQL Server (v8.0 or higher)

### Step 1: Database Initialization
1. Start your local MySQL instance.
2. Import the `database/smart_parking.sql` schema:
   ```bash
   mysql -u root -p < database/smart_parking.sql
   ```
   *(By default, this will create the `smart_parking` database and seed default logins, locations, slots, and test logs).*

### Step 2: Backend Configuration
1. Open the backend configuration file: `backend/.env`.
2. Review database credentials:
   ```env
   PORT=5000
   DB_HOST=127.0.0.1
   DB_USER=root
   DB_PASS=YOUR_MYSQL_PASSWORD_HERE
   DB_NAME=smart_parking
   JWT_SECRET=super_secret_parking_jwt_key_2026
   ```

### Step 3: Run the Application
1. Navigate to the backend directory and launch the server:
   ```bash
   cd backend
   # Start the Express server
   npm start
   ```
2. Open your web browser and navigate to: **`http://localhost:5000`** (or open the file `frontend/login.html` directly).

---

## 6. System Verification & Test Cases

Verify correct operations by running through these manual test protocols:

| Test Case ID | Test Category | Description / Preconditions | Step-by-Step Actions | Expected Result | Pass / Fail |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **TC-SEC-01** | Security / Auth | Authenticate with invalid inputs | Enter `admin` / `wrongpassword` | Displays `Invalid credentials` alert. JWT token is empty. | **Pass** |
| **TC-SEC-02** | Security / Auth | Authenticate with valid inputs | Enter `admin` / `admin123` | Login successful! Token is saved in LocalStorage; routes dashboard. | **Pass** |
| **TC-SEC-03** | Security / Guard | Protected routes bypass check | Navigate to `areas.html` as Attendant | Access denied popup. Redirects back to dashboard.html safely. | **Pass** |
| **TC-OPS-01** | Check-in / Entry | Vehicle check-in flow | Search A-02 slot on check-in, enter license plate `DL3CAN9999` | Reserve ticket printed. Database slot updates to `Occupied` instantly. | **Pass** |
| **TC-OPS-02** | Checkout / Exit | Billed fee computation | Settle exit checkout for vehicle after 1 hr 15 mins. Rate: ₹20/hr | Computes duration as 2 rounded hours. Total Fee matches ₹40. | **Pass** |
| **TC-OPS-03** | Billing / Invoice | Payment collection bookkeeping | Settle ₹40 payment via Cash | Creates transaction in Payments, frees slot back to `Available`. | **Pass** |

---

## 7. Deployment Instructions (Production)

### Cloud Deploy (Node.js & MySQL)
1. **Containerization**: Define `Dockerfile` in the root folder exposing port 5000.
2. **Reverse Proxy (HTTPS)**: Host under secure reverse proxy frameworks like Nginx or AWS ALB matching SSL configurations:
   - Configure Nginx reverse proxy `proxy_pass http://localhost:5000;` under port `443`.
3. **Database Cloud Migrations**: Deploy standard RDS instances on AWS or Cloud SQL on Google Cloud. Set environment variables on your cloud hosts to point to the secure production database endpoint.
# Smart-Parking-System
