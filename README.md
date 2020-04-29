# vkucukcakar/runit

runit Docker image for service supervision & graceful shutdown (especially for images running multiple processes), zombie process reaping

vkucukcakar/rsyslog which runs multiple processes (a log daemon and a logrotate cron) is a working example of use case.

* runit used for service supervision (restart crashed services, dependent services etc...)
* Graceful shutdown (when TERM signal is received from Docker, sends HUP signal to processes and manages cleanup)
* tini running as PID 1 to solve zombie process issue
* Alpine based image
  
## Supported tags

* alpine, latest

## Examples

This image is not designed as a standalone image but a parent image.

*Child image Dockerfile*

	FROM vkucukcakar/runit:alpine
	
	RUN mkdir -p /etc/service/example/
	COPY alpine/example.run /etc/service/example/run
	RUN chmod 755 /etc/service/example/run
	
*See the bundled alpine/example.run runit service file comments for instructions*

*See vkucukcakar/rsyslog for a working example*

## Notice

Support for Debian based image has reached it's end-of-life.
Debian related file(s) were moved to "legacy" folder for documentary purposes.
Sorry, but it's not easy for me to maintain both Alpine and Debian based images.

If you really need the Debian based image, please use previous versions up to v1.0.4.
