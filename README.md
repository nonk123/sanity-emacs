# sanity-emacs

Rudimentary [sanity live-server](https://github.com/nonk123/sanity) support for GNU/Emacs.

## Installation

If you have `use-package` and [`straight.el`](https://github.com/radian-software/straight.el), add the following to your init-file:

```lisp
(use-package sanity
  :straight (:type git :host github :repo "nonk123/sanity-emacs"))
```

Automated installation with a different package-manager should be trivial to derive from the snippet above: just point yours to [this GitHub repo](https://github.com/nonk123/sanity-emacs).

## Usage

Try the following commands, available for/at your convenience:

- `M-x sanity-run` runs the live-server, prompting you to auto-install it if you don't have it.
- `M-x sanity-install` auto-installs the live-server to `~/.emacs.d/sanity/sanity`. `.exe` extension is appended on Windose.

Make sure to customize the following options:

- `sanity-autorun?`: set to nil to prevent this package from auto-starting `sanity` inside projects that contain a `www` directory.
