# README

# Tiny Ledger API
Tiny Ledger API is a very small Ruby on Rails API for performing core ledger transactions.  The API requires minimal setup to be ran locally.  There is no database, all  ledger data is stored in memory and will persist until the application stops running.  The API assumes the ledger is speicific to one account/entity/person, multi-account functionality is not supported.    

## Supported Core Functionality 
- Create Deposit or Withdrawl 
- View Current Balance
- View Transaction History

## Relevant Files 
These are the files that support the core implementation of the API: 

[`config/routes.rb`](./config/routes.rb)
* Defines API Endpoints
* Maps requests to controller actions

[`app/controllers/transactions_controller.rb`](./app/controllers/transactions_controller.rb): 
 * Implements all API actions: 
  * POST `/transactions`, GET `/balance` & GET `/transaction_history`

[`app/models/ledger.rb`](./app/models/ledger.rb)
 * Defines Singleton Ledger Class
 * In-memory transcations and running balance
 * Updates Ledger transactions 
 * Updates balance  

[`app/models/transaction.rb`](./app/models/transaction.rb)
 * Defines a single transaction
 * Performs validations on a transaction 
 * Computes amount of transaction in relation to balance

[`spec/`](./spec/)
* Test Suite
* Controller tests: [`spec/controllers/transactions_controller_spec.rb`](./spec/controllers/transactions_controller_spec.rb)
* Ledger & Transaction tests: [`spec/models`](./spec/models/)

## Getting started 

### Prerequisites 
- Ruby 3.x
- Rails 8.x

1. Clone the repo: 
```bash
    git clone https://github.com/WesleyRS89/Tiny-Ledger-Api.git
    cd Tiny-Ledger-Api
```

2. Install dependencies 
A few basic rails dependencies are needed to install.  The only additional out of the box library that was added is Rspec (testing framework).
```bash
bundle install 
```

3. Start the server 
```bash
rails server
```

4. Run Test Suite (Optional)
Running the test suite provides additional context into the functionality of the API.  The following command will run the tests in document mode, providing for readable test cases. 
```bash
rspec -fd 
```


## Endpoints 

### Create Transaction 

**POST** `/transactions`

This endpoint can create two different types of transactions: deposit or withdraw. 
Note: Timestamp is an optional field, if not specified the timestamp of the transaction will be the current time. 

**Request Body**
```json
{
  "transaction": {
    "amount": 100.0,
    "transaction_type": "deposit",
    "timestamp": "2025-05-16 12:00:00" // optional
  }
}
```

**Success Responses**
- `200 OK` Status
```json 
 {
    "current_balance": "15.00",
    "success": true,
    "transaction_amount": "5.00",
    "transaction_type": "deposit"
}

```
Valid Transaction Example:
```bash
curl -X POST http://localhost:3000/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "amount": 100.0,
      "transaction_type": "deposit",
      "timestamp": "2025-05-16 12:00:00"
    }
  }'
```

**Error Response**
`422 Unprocessable Entity` on validation errors or missing required fields
```json
{ 
    "success": false, 
    "error": "Amount must be a non negative numeric value."
}
```
Invalid Transaction Request Example:
```bash
curl -X POST http://localhost:3000/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "amount": -5.0,
      "transaction_type": "withddraw",
      "timestamp": "not-a-date"
    }
}'
```

### Get Balance 

**GET** `/balance`
Returns balance for entire ledger. 
Request Example: 
```bash 
curl http://localhost:3000/balance
```
**Responses**
```json
{
    "balance": "150.00"
}
```

## Get Transaction History

**GET** /transaction_history

Returns all the transactions (deposits and withdrawls) on ledger. 

Request Example: 
```bash 
curl http://localhost:3000/transaction_history
```

**Response**
```json
{
  "transactions": [
    {
      "amount": "100.0",
      "transaction_type": "deposit",
      "timestamp": "2025-05-16 12:00:00"
    },
    {
      "amount": "50.0",
      "transaction_type": "withdrawl",
      "timestamp": "2025-05-16 12:00:00"
    }
  ]
}
```


## Future Enhancements to Consider  
* Multiple Account Support
* Unique UUIDs and Labels for Transactions 
* Fetch balance for a given date 
* Filter for history for transactions by type, date or amount threshold

