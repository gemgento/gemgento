# Gemgento - Rails to Magento Bridge

##Configuration:
In config/gemgento_config.yml

Like Rails' database.yml, gemgento.yml is specified by Rails environment.  Here is the minimum needed to connect Rails to Magento.

````
production: 
  magento:
    url:  magento.yourshop.com
    username:  gemgento
    api_key:  XXXXXXXXXXXXX
    ip_whitelist: 127.0.0.1,MAGENTO.SERVER.IP
````






