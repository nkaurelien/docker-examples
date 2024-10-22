# Install

composer install

#  Run


## build and exec 
docker compose up --build

## see help

docker compose exec drupal ls /opt/drupal
docker compose exec drupal cat /var/www/html/core/INSTALL.txt


docker compose exec drupal php /var/www/html/core/scripts/drupal quick-start --help

## genrate site

docker compose exec drupal php -d memory_limit=256M /var/www/html/core/scripts/drupal quick-start demo_umami --langcode fr
 

# See more

- Install with nginx , cerbot
https://www.digitalocean.com/community/tutorials/how-to-install-drupal-with-docker-compose