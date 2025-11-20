FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=take
ARG USER_UID=1000
ARG USER_GID=1000

WORKDIR /root

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential pkg-config locales tzdata \
    python3.10-dev neovim python3-neovim git curl jq less \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen ja_JP.UTF-8

ENV LANG=ja_JP.UTF-8
ENV TZ=Asia/Tokyo

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
 && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Add sudo support. Omit if you don't need to install software after connecting.
RUN apt-get update \
 && apt-get install -y sudo \
 && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
 && chmod 0440 /etc/sudoers.d/$USERNAME

RUN mkdir -p /workspaces/ihLDA
COPY . /workspaces/ihLDA
RUN chown -R $USERNAME:$USERNAME /workspaces

WORKDIR /workspaces/ihLDA

RUN git config --global --add safe.directory /workspaces/ihLDA

USER $USERNAME

ENV PATH="${PATH}:/home/${USERNAME}/.local/bin"

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN echo 'eval "$(uv generate-shell-completion bash)"' >> $HOME/.bashrc
#RUN uv sync --reinstall

CMD ["uv", "run", "jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--ServerApp.token=''", "--no-browser"]
