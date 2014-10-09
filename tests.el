;;; tests  -*- lexical-binding: t -*-

(require 'ert)

(defmacro diary-server/fake (&rest body)
  (declare (debug (&rest form)))
  `(noflet ((current-time () ; time travel
             (apply
              'encode-time
              (parse-time-string "2014-09-28 11:46:00 55"))))
     (let ((org-agenda-files `("./diarytest.org"))) ; need better locator than ./
       ,@body)))

(ert-deftest diary-server/date-list ()
  "Test the date listing works on the test file."
  (diary-server/fake
   (should
    (equal
     '("2014-10-2" "test one")
     (match
      (elt (diary-server/date-list :daystart :today) 0)
      ((alist "date" date "head" head) (list date head)))))
   (should 
    (equal
     '("2014-11-15" "test two")
     (match 
      (elt (diary-server/date-list :daystart "2014-11-06") 0)
      ((alist "date" date "head" head) (list date head)))))))

(ert-deftest diary-server/json-list ()
  (diary-server/fake
   (let ((val (match
               (let ((json-key-type 'string))
                 (json-read-from-string
                  (elt (diary-server/json-list :daystart :today) 0)))
               ((alist "date" date "head" head) (list date head)))))
     (should (equal '("2014-10-2" "test one") val)))))

;;; tests.el ends here
