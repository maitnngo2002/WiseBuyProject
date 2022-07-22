# WiseBuyProject

## Overview
### Description
This application scans items' barcodes and displays most popular deals found on the Internet
### App Evaluation

- **Category:** Shopping
- **Mobile:** This application is mobile oriented as it uses the phone camera to scan barcodes
- **Story:** Help users to find a better deal for their current items to save money
- **Market:** People who wants to minimize their spending for the next time
- **Habit:** User could scan to see prices whenever they want
- **Scope:** This app uses the phone camera

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can register for an account
* User can log in/ sign up for an account
* User can use the phone camera to scan the barcode
* User can see the deals related to that item
* User can see the details of a deal
* User can go to the seller site to buy the item
* User can swipe to save/unsave a deal to their profile

**Optional Nice-to-have Stories**

* User can recommend deals
* User can add/remove friends
* User can see a feed of deals posted by his/her friends
* User can search their scanning history
* User can change the money currency

### 2. Screen Archetypes

* Login
    * User is able to login/ log out of his/her account
* Register
    * User is able to register for an account
* Creation
    * User can use the phone camera and scan a barcode
* Stream
    * User can see deals for the scanned barcode
* Details
    * User can see a specific deal for the scanned barcode
### 3. Navigation

Tab Navigation (Tab to Screen)

  * Barcode Scan
  * Profile

Flow Navigation (Screen to Screen)

  * Login Screen
      * Creation
      * Register Screen
  * Creation
      * Profile
  * Creation
      * Stream
  * Stream
      * Details
  * Details
      * Seller site


## Wireframes

![wireframes](https://user-images.githubusercontent.com/63086003/177377172-9d53415e-c768-49b4-9e30-e8b56fbf188b.jpeg)

## Schema 

# Model

# Deal

| Property | Type | Description |
| :---         |     :---:      |          ---: |
| Name  | String  | Name of the item |
| Description  | String  | Information of the item |
| Seller site  | String  | Name of the place selling that item |
| Item URL  | URL  | Link to buy the item |
| Image  | URL  | Image of the item |

# User

| Property | Type | Description |
| :---         |     :---:      |          ---: |
| Name  | String  | Name of the user |
| Email  | String  | User's email |
| Password  | String  | User's password |
| Deals  | Array  | List of saved deals |


# Item

| Property | Type | Description |
| :---         |     :---:      |          ---: |
| Name  | String  | Name of the item |
| Image  | URL  | Link to the image of item |
| Barcode  | String  | Barcode of the item |



