{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  phpFpmSocketLocation = "/run/php-fpm.sock";
  omeka-s = fetchFromGitHub {
    owner = "omeka";
    repo = "omeka-s";
    rev = "v3.1.0";
    hash = "sha256-zWkgcRyihgeughynqcuvMdBMjiTh1DD694A0sCEM3oU=";
  };
  databaseConfig = writeText "database.ini" ''
    user     = "omeka"
    password = "xie7Hiuf"
    dbname   = "omeka"
    host     = "database"
  '';
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
        location / {
          root /webroot;
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
      chmod a+rwx webroot/config
      cp ${databaseConfig} webroot/config/database.ini
      chmod a-w webroot/config
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
