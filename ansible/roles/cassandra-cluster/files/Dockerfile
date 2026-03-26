FROM cassandra:5.0.0

ARG SSH_KEY_PUB_NAME
ARG SUDO_PASSWORD

RUN useradd -m -s /bin/bash devuser && \
    echo "devuser:${SUDO_PASSWORD}" | chpasswd

RUN apt-get update && \
    apt-get install -y openssh-server sudo && \
    usermod -aG sudo devuser && \
    mkdir -p /var/run/sshd && \
    rm -rf /var/lib/apt/lists/*

COPY ${SSH_KEY_PUB_NAME} /home/devuser/.ssh/authorized_keys
RUN chown -R devuser:devuser /home/devuser/.ssh && \
    chmod 700 /home/devuser/.ssh && \
    chmod 600 /home/devuser/.ssh/authorized_keys

COPY sshd_config /etc/ssh/sshd_config

RUN service ssh start

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
