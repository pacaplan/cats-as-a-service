# Identity & Profile — Architecture Diagrams

Generated from `/Users/pcaplan/paul/cats-as-a-service/architecture/identity.json` on 2025-12-24T02:56:33.310Z

---

## L1: System Context

![L1 System Context](images/identity_l1_context.svg)

---

## L3: Capability Flows


### RegisterShopper


Create a new shopper account with email and password


![RegisterShopper](images/identity_l3_register_shopper.svg)


### SignInShopper


Authenticate a shopper using email and password, establishing a session


![SignInShopper](images/identity_l3_sign_in_shopper.svg)


### SignInShopperWithGoogle


Authenticate a shopper via Google OAuth; creates or links account automatically


![SignInShopperWithGoogle](images/identity_l3_sign_in_shopper_with_google.svg)


### SignOutShopper


Invalidate the shopper's current session


![SignOutShopper](images/identity_l3_sign_out_shopper.svg)


### GetShopperSession


Return current authentication state and minimal profile for the Vercel frontend


![GetShopperSession](images/identity_l3_get_shopper_session.svg)


### SignInAdmin


Authenticate an admin using username and password for the Rails admin UI


![SignInAdmin](images/identity_l3_sign_in_admin.svg)


### SignOutAdmin


Invalidate the admin's current session


![SignOutAdmin](images/identity_l3_sign_out_admin.svg)


### ProvisionAdmin


Create a new admin account via server-side script; not exposed via web endpoints


![ProvisionAdmin](images/identity_l3_provision_admin.svg)



