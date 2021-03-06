#!/usr/bin/env bash
setopt interactive_comments
export DOMAIN=dev.example.com
export TRAEFIK_USERNAME='traefik'
export TRAEFIK_PASSWD='yairohchahKoo0haem0d'

export DB_NAME=db_example
export DB_USER=user_example
export DB_PASS=password_example
export DB_EXTERNAL_PORT=30432

export REDIS_PASS=password_example

if [[ -z ${REGISTRY_USERNAME} ]] ; then
  echo "Please enter the REGISTRY_USERNAME or set the env variable: "
  read -r REGISTRY_USERNAME
else
  echo "Read REGISTRY_USERNAME from env"
fi

if [[ -z ${REGISTRY_PASSWORD} ]] ; then
  echo "Please enter the REGISTRY_PASSWORD or set the env variable: "
  read -r REGISTRY_PASSWORD
else
  echo "Read REGISTRY_PASSWORD from env"
fi

export REGISTRY_URL='https://index.docker.io/v2/'
export REGISTRY_NAME='docker-hub'

export APP_KEY=base64:8dQ7xw/kM9EYMV4cUkzKgET8jF4P0M0TOmmqN05RN2w=
export APP_NAME=HaakCo Wave
export APP_ENV=local
export APP_DEBUG=true
export APP_LOG_LEVEL=debug
export DOMAIN_NAME=$DOMAIN
export DB_HOST=wave-postgresql
export DB_NAME=$DB_NAME
export DB_USER=$DB_USER
export DB_PASS=$DB_PASS
export REDIS_HOST=wave-redis-master
export REDIS_PASS=$REDIS_PASS
export MAIL_HOST=smtp.mailtrap.io
export MAIL_PORT=2525
export MAIL_USERNAME=
export MAIL_PASSWORD=
export MAIL_ENCRYPTION=null
export TRUSTED_PROXIES='10.0.0.0/8,172.16.0.0./12,192.168.0.0/16'
export JWT_SECRET=Jrsweag3Mf0srOqDizRkhjWm5CEFcrBy

WAVE_DIR=$(realpath "${PWD}/../../../deploying-laravel-app-ubuntu-20.04-php7.4-lv-wave")
export WAVE_DIR

kubectl create namespace wave

kubectl \
  --namespace wave \
  create secret \
  docker-registry "${REGISTRY_NAME}" \
  --docker-server="${REGISTRY_URL}" \
  --docker-username="${REGISTRY_USERNAME}" \
  --docker-password="${REGISTRY_PASSWORD}" \
  --docker-email=""

kubectl apply --namespace wave -f ./wave/postgresql-pvc.yaml

cat ./wave/postgresql-values.tmpl.yaml | envsubst > ./wave/postgresql-values.env.yaml
helm upgrade \
  --install \
  wave-postgresql \
  --namespace wave \
  --version 10.4.8 \
  -f ./wave/postgresql-values.env.yaml \
  bitnami/postgresql

kubectl apply --namespace wave -f ./wave/redis-pvc.yaml

cat ./wave/redis-values.tmpl.yaml | envsubst > ./wave/redis-values.env.yaml
helm upgrade \
  --install \
  wave-redis \
  --namespace wave \
  --version 14.3.3 \
  -f ./wave/redis-values.env.yaml \
  bitnami/redis

cat ./wave/wave.deploy.tmpl.yaml | envsubst > ./wave/wave.deploy.env.yaml
kubectl apply --namespace wave -f ./wave/wave.deploy.env.yaml

cat ./wave/rediscommander.deploy.tmpl.yaml | envsubst > ./wave/rediscommander.deploy.env.yaml
kubectl apply --namespace wave -f ./wave/rediscommander.deploy.env.yaml

#kubectl exec --tty --namespace wave -i $(kubectl get pods --namespace wave | grep wave-lv-example | awk '{print $1}') -- bash -c 'su - www-data'

#cd /var/www/site
#yes | php artisan migrate
#yes | php artisan db:seed

echo 'kubectl exec --tty --namespace wave -i $(kubectl get pods --namespace wave | grep wave-lv-example | awk '"'"'{print $1}'"'"'} -- bash -c '"'"'su - www-data'"'"
echo ""
echo "cd /var/www/site"
echo "yes | php artisan migrate"
echo "yes | php artisan db:seed"
