{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  phpFpmSocketLocation = "/run/php-fpm.sock";
  version = "3.1.1";
  omeka-s = callPackage ./omeka-s.nix {};
  omeka-s-modules = callPackage ./omeka-s-modules.nix {};
  nginxPort = "8080";
  nginxConf = writeText "nginx.conf" ''
    user root nobody;
    daemon off;
    error_log /dev/stdout info;
    pid /dev/null;
    events {}
    http {
      access_log /dev/stdout;
      include ${nginx}/conf/mime.types;
      server {
        listen ${nginxPort};
        index index.php;
        root /webroot;
        location / {
          try_files $uri /index.php?$args;
        }
        location /install {
          try_files $uri /index.php?$args;
        }
        location ~ \.php {
          fastcgi_pass unix:${phpFpmSocketLocation};
          fastcgi_param SCRIPT_FILENAME /webroot$fastcgi_script_name;
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          include ${nginx}/conf/fastcgi_params;
        }
      }
    }
  '';
  phpFpmCfg = writeText "php-fpm.conf" ''
    [global]
    daemonize=yes
    error_log=/proc/self/fd/2

    [www]
    user = nobody
    group = nobody
    listen = ${phpFpmSocketLocation}
    pm = static
    pm.max_children = 5

    ; to read e.g. the database config passed in via the env.
    ; there is nothing (more) sensitive in there anyway:
    clear_env=no

    access.log=/proc/self/fd/2
    catch_workers_output = yes
    php_flag[display_errors] = on
    php_admin_value[error_log] = /proc/self/fd/2
    php_admin_flag[log_errors] = on
  '';
  phpIni = writeText "php.ini" ''
    post_max_size = 32M
    upload_max_filesize = 32M
    openssl.cafile=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';
  startScript = writeScript "start.sh" ''
    #!${bash}/bin/sh
    ${php}/bin/php-fpm -y ${phpFpmCfg} -c ${phpIni}
    exec "${nginx}/bin/nginx" "-c" ${nginxConf}
  '';
  omeka-s-image = dockerTools.buildLayeredImage {
    name = "raboof/omeka-s";
    tag = "latest";
    contents = [
      dockerTools.fakeNss
      # Needed to create thumbnails
      imagemagick
      # Seems to be needed to invoke imagemagick
      bash
      # just for development/debugging, to be removed again
      # vim coreutils findutils
    ];
    extraCommands = ''
      # nginx still tries to read this directory even if error_log
      # directive is specifying another file :/
      mkdir -p var/log/nginx
      mkdir -p var/cache/nginx
      mkdir -p run
      touch run/php-fpm.sock

      # php-fpm lock file,
      # media file upload PHP temporary directory
      # conversions temporary directory
      mkdir -p tmp
      chmod a+rwx tmp

      # the 'installer' wants to write to the app, so copy
      # it for now.
      mkdir webroot
      cp -ra ${omeka-s}/* webroot

      # We copy the config from the repo into the container.
      # Some modules can be configured from the web UI, and
      # write some of that config into /config. If you want
      # to use that, mount it as a volume: this way, you can
      # inspect and version-control any such changes.
      # Doing the same for 'regular' Laminas module configuration
      # options is a TODO ;)
      chmod -R a+rwx webroot/config
      rm -r webroot/config
      cp -r ${./config} webroot/config

      chmod a+rwx webroot/files

      # Can also be mounted for easier access
      chmod a+rwx webroot/logs
      chmod a+rwx webroot/logs/*

      chmod a+rwx webroot/modules
      cp -r ${omeka-s-modules.value-suggest} webroot/modules/ValueSuggest
      cp -r ${omeka-s-modules.generic} webroot/modules/Generic
      cp -r ${omeka-s-modules.clean-url} webroot/modules/CleanUrl
      cp -r ${omeka-s-modules.unapi} webroot/modules/UnApi
      cp -r ${omeka-s-modules.custom-ontology} webroot/modules/CustomOntology
      chmod a-w webroot/modules
    '';
    config = {
      Cmd = [ "${startScript}" ];
      ExposedPorts = {
        "${nginxPort}/tcp" = {};
      };
    };
  };
in
  omeka-s-image 
