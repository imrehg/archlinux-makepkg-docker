FROM archlinux/base as base

RUN pacman -Syuq --noconfirm git base-devel sudo

RUN echo "Defaults         lecture = never" > /etc/sudoers.d/privacy \
 && echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel \
 && useradd -m -G wheel -s /bin/bash builder

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git \
 && cd yay \
 && makepkg -s --noconfirm

######
# Runtime container
######
FROM archlinux/base

RUN pacman -Syuq --noconfirm git base-devel sudo namcap \
 && rm -rf /var/cache/pacman/pkg/*

RUN echo "Defaults         lecture = never" > /etc/sudoers.d/privacy \
 && echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel \
 && useradd -m -G wheel -s /bin/bash builder

USER builder
WORKDIR /home/builder

COPY --from=base /home/builder/yay/*.pkg.tar.* /home/builder/pkg/

RUN sudo pacman -U --noconfirm /home/builder/pkg/*.pkg.tar.*
