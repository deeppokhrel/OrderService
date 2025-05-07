
# 🔗 Distributed Notification System with Kafka

This project consists of four interconnected microservices that communicate via **Kafka** and handle user registration, order management, stock updates, and user notifications through email.


![Screenshot 2025-05-07 at 08 44 32](https://github.com/user-attachments/assets/97ea7ecb-0318-49da-a765-b217e21bd162)


---

## 🧱 Services Overview

### 1. `Customer_Service`
- RESTful API to **Create, Read, Update, Delete (CRUD)** users.
- On user creation:
  - Sends a **Kafka event** to `Notification_Service` to send a welcome email.
  - Replicates user data to the `Order_Service`.

### 2. `Order_Service`
- Provides an endpoint `POST /orders` to create an order.
- On order creation:
  - Sends a **Kafka event** to:
    - `Notification_Service` — to notify the user about order details via email.
    - `Inventory_Service` — to update the stock balance.

### 3. `Inventory_Service`
- Listens for order events.
- Updates the stock count in the `Inventory` model based on order quantity.

### 4. `Notification_Service`
- Listens for events from both `Customer_Service` and `Order_Service`.
- Sends out:
  - Welcome email upon user creation.
  - Order confirmation email upon order creation.

---

## 🛠 Setup Instructions (macOS only)

### 1. ✅ Install Kafka with Homebrew

```bash
brew install kafka
brew services start kafka
```

You can also start Kafka manually after starting ZooKeeper:

```bash
brew services start zookeeper
kafka-server-start /usr/local/etc/kafka/server.properties
```

### 2. 🧾 Set Kafka Environment Variable

Each service expects a `KAFKA_BROKERS` environment variable.

```bash
export KAFKA_BROKERS=localhost:9092
```

You can also add this to a `.env` file if you use `dotenv`.

---

## ✉️ Notification Service SMTP Setup

To enable email delivery via Gmail SMTP in the `Notification_Service`, add the following to `config/environments/development.rb` or `production.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: "gmail.com",
  authentication: "plain",
  enable_starttls_auto: true,
  user_name: "<USER_NAME>",
  password: "<APP_PASSWORD">"
}
```

> ⚠️ **Security Note:** The password must be an [App Password](https://support.google.com/accounts/answer/185833) generated from your Gmail account — **not** your regular Gmail password.

### 🔐 .env Example

```env
KAFKA_BROKERS=localhost:9092
```

---

## ▶️ Running the Apps

Each app is a standalone Ruby on Rails service. Navigate to the project root of each and run:

```bash
bundle install
rails db:setup
rails server
```

Make sure Kafka is running before starting the services.

---

## 🔄 Workflow Summary

```plaintext
User Creation (Customer_Service)
│
├──> Notification_Service (sends welcome email)
└──> Order_Service (replicates user)

Order Creation (Order_Service)
│
├──> Inventory_Service (updates stock)
└──> Notification_Service (sends order confirmation email)
```

---

## 📫 Contributions

Feel free to fork and contribute! Please open a PR for improvements or bug fixes.

---

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).
