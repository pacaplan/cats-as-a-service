```text
                          +--------------------------+
                          |         SHOPPERS         |
                          +--------------------------+

                          (Web UI / API Gateway)

===============================================================================
|                                   |                                       |
v                                   v                                       v

+-----------------------------------+    uses cat data     +------------------------------+
|       CATS & CONTENT BC (LEFT)    |<---------------------|     COMMERCE BC (RIGHT)      |
|-----------------------------------|                      |------------------------------|
| * Premade "Cat-alog"              |                      | * Cart & guest checkout      |
|   - Cat traits, photos            |                      | * Orders & order lifecycle   |
|   - Base pricing                  |                      | * Payment processing         |
|   - Inventory & availability      |                      | * Order-update email delivery|
|                                   |                      | * Email templates            |
| * Custom Cat records              |                      |                              |
|   - Create / view / archive       |                      |                              |
+-----------------------------------+                      +------------------------------+
             ^                                                           ^
             |                                                   checks identity &
             |                                              email-preferences status
             |                                                           |
             |                                                           v
             |              +--------------------------------------------------------+
             |              |       IDENTITY & SUBSCRIPTIONS BC                      |
             |              |--------------------------------------------------------|
             +--------------| * Authentication (login/logout)                        |
                            | * User accounts / identities                           |
                            | * Email preferences / subscription state                |
                            |   - Opt-in / opt-out for order-related emails          |
                            |   - Unsubscribe endpoints                               |
                            +--------------------------------------------------------+
```

