# Gemgento - Rails to Magento Bridge
## Installation:
If you don't already have an instance of Magento running, we recommend using our open source version:  

http://github.com/mauinewyork/mauigento  

It includes API bug fixes for checkout that otherwise have to be applied to an existing version of Magento.  If you run, ubuntu you can set this up in one step with:  
  
    curl http://get.mauigento.com | bash -s

Before configuring the Rails app, make sure you are able to access the Magento Admin Panel that will serve as the backend of your ecommerce site.

Then, in your Rails 4 app's Gemfile, add:

    gem 'gemgento'

Then from your Rails root, run:

    bundle install

##Configuration:
In config/gemgento_config.yml

Like Rails' database.yml, gemgento.yml is specified by Rails environment.  Here is the minimum needed to connect Rails to Magento.

````
production: 
  site:
    name: Your Shop
    url:  yourshop.com

  magento:
    url:  magento.yourshop.com 
    username:  gemgento
    api_key:  XXXXXXXXXXXXX
    api_type: soap
    api_version:  2
    debug: false
    encryption: 4de6a444ff58bf44013f3bc05256f1b3
````

##TODO:  Add these sections:

####Creating Gemgento's API User in Magento:

####Synching:

####Images:

####Active Admin - Gemgento's Rails CMS:








