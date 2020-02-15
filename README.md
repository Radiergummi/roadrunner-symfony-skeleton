Roadrunner Symfony Skeleton
===========================
> A bare-bones skeleton project, prepared to run Symfony 5, served by [Roadrunner](https://roadrunner.dev/), 
> in a Docker image.

Features
--------
The image includes only what's actually required to wire things up. It provides:

 - Pre-configured Symfony integration using 
   [baldinof/symfony-roadrunner-bundle](https://github.com/Baldinof/roadrunner-bundle)
 - Automatic worker reloading after each request, so you can live-edit in development
 - Easy configuration: All config files in the project root
 - Working docker-compose development environment, project is mounted into the image
 - [Working Sessions](https://github.com/spiral/roadrunner/issues/18)

Installation
------------
**via Composer:**  
```bash
composer create-project --prefer-dist radiergummi/roadrunner-symfony-skeleton your_app
```

**via Git:**
```bash
git clone https://github.com/Radiergummi/roadrunner-symfony-skeleton.git your_app
cd your_app

# install dependencies
composer install

# init config
composer init-config
```

Usage
-----
Start the container:
```bash
docker-compose up
```

...then open [localhost:8080](http://localhost:8080), and you're ready to go.

Configuration
-------------
The project exposes multiple configuration files:

 - `.rr.yaml`: The Roadrunner configuration file. It only includes the directives required for the project setup to work
   properly. You can find the reference at [roadrunner.dev/docs/intro-config](https://roadrunner.dev/docs/intro-config).
 - `php.ini`: The main PHP configuration file. By default, it only includes the configuration recommended by Symfony, 
   but you can change this file however you want.
 - `Dockerfile`: The Dockerfile is split into a _builder_ image that downloads the roadrunner binary and the actual 
   image (that's called a [multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/)). If you
   need to make changes, you'll want to add them to the bottom image.
 - `docker-compose.yaml`: The docker-compose configuration file. By default, it's configured to serve a development 
   stack, with the project directory being mounted into the image working directory, essentially overriding the built 
   files. This allows you to live-edit the files within the container while it runs. It also exposes the metrics and 
   health services to the outside world on their default ports.  
   Lastly, it overrides the default entry point to add the `debug` and `verbose` flags and restart the worker after 
   every request.
 - `config/packages/baldinof_road_runner.yaml`: The configuration file for the bridge bundle. You can find a reference
   at [github.com/baldinof/roadrunner-bundle](https://github.com/baldinof/roadrunner-bundle#configuration), but it works
   fine with the defaults.
