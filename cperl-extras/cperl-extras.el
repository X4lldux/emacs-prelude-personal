(require 'thingatpt)
(require 'perl-things)
(require 'my-macros)
(require 'cperl-test-increment)
(require 'cperl-dump)
(require 'cperl-use)
(require 'cperl-misc)
(require 'cperl-project)
(require 'cperl-moose)
(require 'cperl-reindent)

(defvar cperl-last-test nil
  "The last test run via `cperl-run-tests-in-eshell'")

(defun cperl-run-tests-in-eshell (&optional prefix)
  (interactive "p")
  (let ((name (file-relative-name (buffer-file-name) (eproject-root))))
    (if (string-match ".t$" name)
        (progn (setq cperl-last-test name)
               (cperl-run-tests-in-eshell-1 prefix name))
      (cperl-run-tests-in-eshell-1 prefix))))

(defun cperl-run-last-test-in-eshell (&optional prefix)
  (interactive "p")
  (if cperl-last-test
      (cperl-run-tests-in-eshell-1 prefix cperl-last-test)
    (cperl-run-tests-in-eshell prefix)))

(defun cperl-run-tests-test-command (test)
  (if (eproject-attribute :xs-project-p)
      (format "perl -Mblib %s" test)
    (format "perl -Ilib %s" test)))

(defun cperl-run-tests-prove-command ()
  (if (eproject-attribute :xs-project-p)
      "make test"
    "prove --lib -r -j3 t"))

(defun cperl-run-tests-in-eshell-1 (prefix &optional test)
  "Run the named test in the visible eshell.

<picture of cat using eshell with caption: VISIBLE ESHELL>.

PREFIX is the prefix arg to pass to `eproject-eshell-cd-here',
TEST is the test to run, or NIL for all of them."
  (let ((command (if test
                     (cperl-run-tests-test-command test)
                 (cperl-run-tests-prove-command))))
    (with-current-buffer (eproject-eshell-cd-here prefix)
      (eshell-preinput-scroll-to-bottom)
      (goto-char (point-max))
      (insert command)
      (eshell-send-input nil t)
      (goto-char (point-max))
      (ignore-errors
        (set-window-point (get-buffer-window) (point-max))))))


(add-hook 'cperl-mode-hook
          (lambda ()
            ;; (local-set-key "\C-cT" 'increment-test-counter)
            (local-set-key "\C-c\C-u" 'add-use)
            (local-set-key "\C-cmu" 'add-Makefile.PL-requires)
            (local-set-key "\C-cmv" 'visit-Makefile.PL)
            (local-set-key "\C-c\C-d" 'perl-insert-debug-statement)
            (local-set-key "\C-c\C-s" 'insert-self-shift)
            ;; (local-set-key "\C-cT" 'find-tests)
            (local-set-key "\C-cw" 'swap-strict-and-moose)
            ;; (local-set-key "\C-c\C-f" 'ifind-perl-project-file)
            ;; (local-set-key "\C-c\C-p" 'ifind-perl-projects)
            ;; (local-set-key "\C-c510" 'kill-5.10)
            ;; (local-set-key (quote [M-tab]) 'cperl-reindent-hash)
            (local-set-key (kbd "M-C-i") 'cperl-reindent-hash)
            (local-set-key "\C-cq" 'find-module)))

(add-hook 'tt-mode-hook
          (lambda ()
            (local-set-key "\C-c\C-f" 'ifind-perl-project-file)))

(add-hook 'perl-project-file-visit-hook
          (lambda ()
            (local-set-key (kbd "C-c C-l") 'cperl-run-tests-in-eshell)
            (local-set-key (kbd "C-c l") 'cperl-run-last-test-in-eshell)))

(global-set-key "\C-c\C-p" 'ifind-perl-projects)

(provide 'cperl-extras)
