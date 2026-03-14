FROM owasp/modsecurity:nginx-alpine

RUN apk add --no-cache \
    curl \
    wget \
    git \
    bash

ARG CRS_VERSION=v3.3.5
RUN cd /opt && \
    git clone --depth 1 --branch ${CRS_VERSION} https://github.com/coreruleset/coreruleset.git && \
    mkdir -p /opt/owasp-modsecurity-crs && \
    cp coreruleset/crs-setup.conf.example /opt/owasp-modsecurity-crs/crs-setup.conf && \
    cp -r coreruleset/rules /opt/owasp-modsecurity-crs/

# Copy nginx config as template (so entrypoint processes it instead of overwriting)
RUN mkdir -p /etc/nginx/templates
COPY nginx.conf /etc/nginx/templates/nginx.conf.template

# Copy ModSecurity configuration
COPY modsecurity.conf /etc/modsecurity/modsecurity.conf
COPY unicode.mapping /etc/modsecurity/unicode.mapping
# Create custom rules directory
# RUN mkdir -p /opt/owasp-modsecurity-crs/rules

# Create custom ModSecurity directory (separate from CRS to avoid duplicate loading)
# RUN mkdir -p /opt/modsecurity

# Copy keyword detection lists
# COPY rules/sql_keywords.txt /opt/owasp-modsecurity-crs/rules/sql_keywords.txt
# COPY rules/xss_keywords.txt /opt/owasp-modsecurity-crs/rules/xss_keywords.txt
# COPY rules/xss_advanced.txt /opt/owasp-modsecurity-crs/rules/xss_advanced.txt

# Copy custom DetectionRules (to separate directory to prevent double-loading)
COPY rules/custom_rules.conf /opt/modsecurity/custom_rules.conf

# Create logs directory with proper permissions for nginx user
RUN mkdir -p /var/log/modsecurity && \
    mkdir -p /var/log/nginx && \
    chmod 777 /var/log/modsecurity && \
    chmod 777 /var/log/nginx && \
    touch /var/log/nginx/error.log && \
    touch /var/log/nginx/access.log && \
    chmod 666 /var/log/nginx/*.log

# Fix ModSecurity configuration for alpine
RUN sed -i 's|^SecDataDir|#SecDataDir|' /etc/modsecurity/modsecurity.conf && \
    echo 'SecDataDir /tmp/modsecurity' >> /etc/modsecurity/modsecurity.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]