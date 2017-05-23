# vkucukcakar/runit

runit Docker image for service supervision and zombie reaping

* runit used for service supervision
* tini running as PID 1 to overcome zombie process issue
* Alpine and Debian based images
  
## Supported tags

* alpine, latest
* debian

## Examples

This image is not designed as a standalone image but a parent image.

*Child image Dockerfile*

	FROM vkucukcakar/runit:alpine
	
	RUN mkdir -p /etc/service/example/
	COPY alpine/example.run /etc/service/example/run
	RUN chmod 755 /etc/service/example/run
	
*See the bundled alpine/example.run runit service file comments for instructions*

*See vkucukcakar/rsyslog and vkucukcakar/cron images for other working examples*

