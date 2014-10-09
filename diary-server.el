;;; diary-server.el --- server for agenda json

;; Copyright (C) 2014  Nic Ferrier

;; Author: Nic Ferrier <nferrier@ferrier.me.uk>
;; Keywords: processes

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 's)
(require 'cl)
(require 'noflet)
(require 'dash)

(defun* diary-server/date-list (&key (daystart :today)
                                     (days 10))
  "Return the DAYS number of diary events from DAYSTART.

DAYSTART could be `:today' or it could be a date like
\"2014-08-01\".

Returns a list of alists with each having the keys described in
`org-batch-agenda-csv'."
  (let ((org-agenda-window-setup 'diary-server-special)) ; override so we don't open windows
    (noflet ((org-pop-to-buffer-same-window (buf)))
      (with-temp-buffer
        (org-agenda-list
         days
         (time-to-days
          (if (eq daystart :today)
              (current-time)
              (org-read-date nil t daystart))))
        (let ((org-agenda-buffer-name (buffer-name))
              (h (s-split
                  ","
                  ;; this comes from the doc for org-batch-agenda-csv
                  "category,head,type,todo,tags,date,time,extra,priority-l,priority-n")))
          (apply
           'list
           (--map
            (-zip h (s-split "," it))
            (--filter
             (> (length it) 0)
             (s-split
              "\n"
              (with-output-to-string
                  (org-batch-agenda-csv "e")))))))))))

(defun diary-server/json-list (&rest args)
  (--map
   (json-encode it)
   (apply 'diary-server/date-list args)))

(provide 'diary-server)

;;; server.el ends here
