# The Little Letter

The Little Letter is a Ruby on Rails ecommerce project for a fictional Winnipeg stationery shop. Shoppers can browse stationery, build a cart, and place a guest order. Staff use a separate sign-in to manage the catalogue.

**Course** WEBD-3011 Full Stack Ecommerce Project
**Source** [The Little Letter on GitHub](https://github.com/rosieguillen/the-little-letter)

## Run locally

The project uses Ruby 3.4.13, Rails 8.1.4.1, PostgreSQL, and Bundler. The development setup is Debian in WSL.

From the project directory in Debian:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 3001
```

- [Storefront](http://localhost:3001/)
- [Shopping cart](http://localhost:3001/cart)
- [Staff sign-in](http://localhost:3001/admin/sign-in)

If Ruby isn't available in a new Debian tab on the development machine, run `export PATH="$HOME/.local/share/mise/installs/ruby/3.4.13/bin:$PATH"`. Use `pg_isready` to confirm PostgreSQL is accepting connections. The seed creates 100 sample listings across four categories and tax records for all 13 Canadian provinces and territories.

### Staff account on a fresh database

If the local `staff` account already exists, use it. Otherwise, run the following once. It prompts for a password without showing it on screen.

```bash
bin/rails runner 'require "io/console"; print "Staff password: "; password = STDIN.noecho(&:gets).chomp; puts; Admin.create!(username: "staff", password: password)'
```

## Instructor demo

Start with the storefront in one browser session. Use a separate browser profile or private window for staff sign-in so the shopper's cart stays available while you switch between roles.

1. **Browse and search.** Open the homepage, choose **Pens & Pencils**, and open a product detail page. Return to the homepage and search for **gel** using the **Pens & Pencils** dropdown. Clear the search and go to page 2 to show pagination.
2. **Build a cart.** Add two different products. Set one item's quantity to **3** and show its updated line total. Remove the other item using the separate **Remove** button. Refresh to show that the remaining item stays in the session.
3. **Compare checkout taxes.** For an easy example, use two regular-price **$4.95** pens and a fictional delivery address. Select **MB** to show a **$9.90** subtotal, **$0.50 GST**, **$0.69 PST**, and **$11.09** total. Repeat with **ON** to show **$1.29 HST** and an **$11.19** total. Use `shopper@example.com` as the email and leave the optional phone blank.
4. **Place the order.** Click **Place order**, point out the order number and saved total, and reopen the cart to show it is empty. The confirmation records a guest order without taking payment.
5. **Show staff controls.** In the staff browser session, visit `/admin` while signed out to show the redirect. Sign in and create a disposable product. Edit its description, confirm the change on the public page, then delete the disposable listing. Use **Manage categories** to create or rename a category, and show that staff can assign it on the product form.
6. **Explain how old orders retain their totals.** `CheckoutOrder` saves the customer, order, and line items in one transaction. The order holds the checkout tax rates and amounts. Each line holds the product name, quantity, and unit price at the time of purchase. A later product price change leaves those saved values intact.

### Rubric features to queue for marking

| Feature | What to show |
| --- | --- |
| 1.1, 1.2, 1.5 | Protected staff dashboard, product create/edit/delete, category management and assignment |
| 1.6 | Catalogue seed in `db/seeds.rb` |
| 2.1, 2.2, 2.3 | Storefront, category browsing, and product detail pages |
| 2.5, 2.6 | Pagination and keyword search with an optional category |
| 3.1.1, 3.1.2, 3.1.3 | Session cart, independent quantity and removal controls, itemized checkout and saved orders |
| 3.3.2 | Saved unit prices, tax rates, and tax amounts on completed orders |
| 4.1.4, 4.2.2 | Shared view partials and database associations, including orders and products through order items |
| 1.4 | Public About and Contact pages edited from protected staff forms |
| 3.2.1, 3.2.3 | Staff order history and tax-rate editing |
| 4.1.3 | Home, category, and product breadcrumbs |
| 1.3, 4.2.4, 5.2 | Active Storage uploads and resized product images |
| 5.1 | GitHub history and feature branches |

### Pre-demo checks

- Prepare a discounted product and a recently created product to demonstrate both filters.
- Upload and replace a sample photo through the staff form. The seed includes generated product mockups, generally shared across colour options.
- Rehearse the catalogue, cart, and checkout at desktop, tablet, and mobile widths.
- Product details currently display the regular price. The catalogue and cart use the configured sale price.

## Tests and source control

```bash
bin/rails test
git rev-list --count --no-merges origin/main
git log --oneline --merges origin/main
git branch -r
```

The history includes more than 32 non-merge commits and three feature merges for the catalogue, admin, and cart branches. Run the commands above for current counts. Automated tests cover the homepage, checkout, protected order history, tax editing, breadcrumbs, category management, and editable store pages.

## Current scope

The app runs locally with guest checkout. Staff can review order history, edit province and territory tax rates, and update public About and Contact pages. Customer sign-in, payment processing, and public deployment are outside the current build.
