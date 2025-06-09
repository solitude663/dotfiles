# To set up hibernation on Arch

- Ensure you have swap. Check with (swapon --show)
- Get the UUID of the partition with (sudo blkid | grep swap)
- In /etc/default/grub.cfg
  1. Edit this line to add the resume value:
     GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet resume=UUID={ACTUAL ID}"
- Regenerate the GRUB config with (sudo grub-mkconfig -o /boot/grub/grub.cfg)
- Add resume to the initramfs
  1. Edit the file /etc/mkinitcpio.conf
  2. Add 'resume' to the HOOKS array
  3. HOOKS=(base udev autodetect modconf block filesystems resume fsck)
  4. Regenerate initramfs (sudo mkinitcpio -P)

# Setting up SSH (why the fuck don't they just give proper instructions???)
- ssh-keygen -t ed25519 -C "your_email@example.com"
- eval "$(ssh-agent -s)"
- sudo pacman -S keychain
- Add to ~/.bashrc (eval `keychain --eval id_ed25519`)
- cat ~/.ssh/id_ed25519.pub | wl-copy
- ssh -T git@github.com
