# 🚗 Smart Parking Management System

## 📌 Overview

This project is a **Smart Parking Management System** designed to manage parking places, clients, subscriptions, reservations, payments, and tickets.
It uses **Oracle Database (SQL & PL/SQL)** for backend logic and **Flask (Python)** as a web interface.

The system supports **role-based access control** (Admin & Agent) and automates parking operations using **functions, procedures, and triggers**.

---

## 🧠 Key Features

* Client management (PMR & non-PMR)
* Subscription management (Abonné / Non-Abonné)
* Automatic parking place assignment
* Reservation & ticket generation
* Entry & exit validation
* Payment processing
* Real-time statistics (revenue, occupancy rate)
* Role-based security (Admin / Agent)
* Automated logic using PL/SQL triggers

---

## 🏗️ System Architecture

```
Flask (Python)
     |
     v
Oracle Database
(SQL + PL/SQL)
```

---

## 🛠️ Technologies Used

* **Backend Database**: Oracle SQL / PL-SQL
* **Web Framework**: Flask (Python)
* **Database Driver**: cx_Oracle / oracledb
* **Security**: Oracle Roles & Privileges
* **Version Control**: Git & GitHub

---

## 👥 User Roles

### 🔑 Admin (R_ADMIN)

* Full access to all tables
* Manage tariffs
* View statistics
* Manage users, subscriptions, places

### 🎫 Agent (R_AGENT)

* Register clients
* Handle entries & exits
* Process payments
* Manage reservations and tickets

---

## 🗄️ Database Structure

### Main Tables

* `CLIENT`
* `ABONNEMENT`
* `PLACE`
* `TARIF`
* `RESERVATION`
* `TICKET`
* `PAIEMENT`

### Sequences

* `seq_client`
* `seq_abonnement`
* `seq_place`
* `seq_reservation`
* `seq_ticket`
* `seq_paiement`

---

## ⚙️ PL/SQL Components

### Functions

* `Ajouter_client`
* `verifier_abonnement`
* `chercher_place_libre`
* `Determiner_tarif`
* `calculer_duree`
* `calculer_montant`
* `revenu_d_jour`
* `taux_d_occup_places`
* `total_clients`
* `total_abonnes`

### Procedures

* `s_abonner`
* `ajouter_entree`
* `valider_sortie`
* `mettre_a_jour_tarifs`

### Triggers

* Prevent double booking
* Automatically free parking places
* Ensure one active subscription per client
* Enforce parking availability

---

## 🌐 Flask Integration

Flask is used to:

* Connect to the Oracle database
* Call PL/SQL procedures & functions
* Provide a web interface for Admin & Agent
* Display statistics and parking status

Example (Python):

```python
cursor.callproc("ajouter_entree", [nom, prenom, telephone, pmr])
```

---

## ▶️ How to Run the Project

### 1️⃣ Database Setup

* Run the SQL script in Oracle SQL Developer
* Make sure users & roles are created

### 2️⃣ Flask Setup

```bash
pip install flask oracledb
python app.py
```

### 3️⃣ Access

* Admin dashboard
* Agent dashboard

---

## 📊 Sample Outputs

* Daily revenue
* Occupancy rate
* Number of active subscriptions
* Available parking places

---

## 🔐 Security

* Oracle roles & privileges
* Restricted access per role
* Transaction management (COMMIT / ROLLBACK)

---

## 🚀 Future Improvements

* QR Code tickets
* Real-time dashboard
* Mobile application
* Payment gateway integration
* Logs & audit system

---

## 👩‍💻 Author

**Omayma Ajahoud**
Smart Parking Database & Flask Project
2025

---

## 📜 License

This project is for **educational and academic purposes**.
