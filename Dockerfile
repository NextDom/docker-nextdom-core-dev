FROM debian:stretch-slim
MAINTAINER info@nextdom.com
EXPOSE 80
#VOLUME /usr/share/nextdom
ENV locale-gen fr_FR.UTF-8
ENV APACHE_PORT 80
ENV APACHE_PORT 443
ENV MODE_HOST 0
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ARG MODE
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install --yes --no-install-recommends systemd systemd-sysv mysql-server sed
RUN echo "127.0.1.1 $HOSTNAME" >> /etc/hosts && \
    apt-get install --yes --no-install-recommends software-properties-common gnupg wget && \
    add-apt-repository non-free && \
    wget -qO - http://debian.nextdom.org/debian/nextdom.gpg.key | apt-key add - && \
    echo "deb http://debian.nextdom.org/debian nextdom main" >/etc/apt/sources.list.d/nextdom.list
RUN if [ "${MODE}" = "dev" ]; then \
	apt-get update && \
    	apt-get --yes install nextdom-common; \
    else \
	apt-get update && \
	apt-get --yes install nextdom; \
    fi
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -fr /var/lib/{apt,dpkg,cache,log}/
RUN if [ "${MODE}" = "demo" ]; then \
    sed -i '/disable_functions =/c\disable_functions=exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source' /etc/php/7.0/apache2/php.ini; \
    fi
RUN echo "Nextdom Installation completed"

CMD ["/sbin/init"]
