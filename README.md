dough-unified-credential-example
================================

### Overview

Mini application to demonstrate how to make valid requests to Dough Unified Credentialing Server ("DUCS"). This example application uses faraday as its HTTP client library.

To spin up a new faraday client in a REPL shell:

```
DoughUnifiedCredential::Client.new(options) # options include port (i.e. 3000) for the DUCS and logger (i.e. true / false) which logs requests to STDOUT for easier debugging.
```

### Setup

**Note:** Before ANYTHING, start DUCS server locally on port specified by files (specs: port 3001, examples.rb: port 3000)

You must first setup a valid client domain with an api token via DUCS admin portal. Pull down the repo for DUCS, start it up and navigate to /admin and enter your admin credentials.

**First Time Users:** In DUCS rails console, create a new AdminUser and then use the credentials to log in as admin at /admin. Alternatively, you can create a client domain directly in the console and manually create an api token as a string.

Once logged in, create a new client domain (in active admin top nav section), including an api token.

Copy and paste the api token and domain name into this repo's config/secret.yml with API_TOKEN and DOMAIN_NAME as key names. These values are instantiated into the environment for this mini application through environment.rb.

Note: If you get a Faraday connection refused, your DUCS probably isn't on the same port as the faraday client.

### DUCS Routes

All DUCS routes are currently viewable in config/routes.yml. For convenience, helpers are created for each route for DoughUnifiedCredential::Client.

To view the routes as helper methods, run:

```
client = DoughUnifiedCredential::Client.new(port: 3000)
client.routes # will output all helper routes which take a payload as an argument
```

Then call the route directly on the client and pass a payload to the route.

```
payload = {email: "example@bomb.com", password: "password"}
client.send(:desired_route, payload)
```

### Running Specs:

All specs:

```
rspec
```

Specific spec file:

```
rspec spec/[your_file_spec].rb
```

### Examples:

Examples.rb holds a few examples on how make some common requests to the DUCS.

To run:

```
ruby examples.rb
```