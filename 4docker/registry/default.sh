upstream docker-registry {
  server registry:5000;
}

upstream docker-registry {
  server registry:5000;
}

server {
  listen 443;
  server_name dokk.co;

  ssl on;
  ssl_certificate /etc/ssl/certs/docker-registry;
  ssl_certificate_key /etc/ssl/private/docker-registry;

  proxy_set_header  Host           $http_host;   # required for docker client's sake
  proxy_set_header  X-Real-IP      $remote_addr; # pass on real client's IP
  proxy_set_header  Authorization  ""; # see https://github.com/dotcloud/docker-registry/issues/170
  proxy_read_timeout               900;

  client_max_body_size 0;                  # disable any limits to avoid HTTP 413 for large image uploads
  chunked_transfer_encoding on;            # required to avoid HTTP 411: see Issue #1486 (https://github.com/dotcloud/docker/issues/1486)

  root  /usr/local/nginx/html;
  index  index.html index.htm;

  location / {
    auth_basic            "Restricted";
    auth_basic_user_file  docker-registry.htpasswd;  # testuser:testpasswd & larrycai:passwd
    proxy_pass                http://docker-registry;
  }

  location /auth {
    auth_basic            "Restricted";
    auth_basic_user_file  docker-registry.htpasswd;  # testuser:testpasswd & larrycai:passwd
    proxy_pass                http://docker-registry;
  }


  location /v1/_ping {
    auth_basic off;
    proxy_pass                http://docker-registry;
  }

  location /_ping {
    auth_basic off;
    proxy_pass                http://docker-registry;
  }

}