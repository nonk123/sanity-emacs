# sanity-emacs

Rudimentary [sanity live-server](https://github.com/nonk123/sanity) support for GNU/Emacs.

## Installation

If you're using `use-package` and [`straight.el`](https://github.com/radian-software/straight.el), just add the following to your init-file:

```elisp
(use-package sanity
  :straight (:type git :host github :repo "nonk123/sanity-emacs")
  :custom (sanity-mode 1))
```

Automated installation with a different package-manager should be trivial to derive from the snippet above: just point yours to [this GitHub repo](https://github.com/nonk123/sanity-emacs).

## Usage

Make sure to customize the following variables:

- `sanity-mode`: enable this to auto-start `sanity` inside projects that contain a `www` directory. It is a global minor-mode.

Then try the following commands, available for/at your convenience:

- `M-x sanity-install`: auto-install the live-server to `~/.emacs.d/sanity/sanity`. `.exe` extension is appended on Windose.
- `M-x sanity-mode`: toggle `sanity-mode`, which auto-starts `sanity` inside supported projects.
- `M-x sanity-run`: manually run the live-server, prompting to auto-install it if it's missing.
- `M-x sanity-stop`: stop the live-server. More convenient to call this than to kill the process-buffer manually.
